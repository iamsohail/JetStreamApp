import SwiftUI
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
import GoogleSignIn

struct AuthResponse: Codable {
    let user: AuthUser
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct AuthUser: Codable {
    let id: String
    let email: String
    let name: String
}

struct UserProfile {
    var name: String
    var email: String?
    var avatarUrl: String?

    var isProfileComplete: Bool {
        !name.isEmpty && email != nil
    }
}

@MainActor
class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isCheckingAuth = true
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private var pendingSignUpName: String?
    private let keychainManager = KeychainManager()
    private let apiClient = APIClient()

    init() {
        Task { @MainActor [weak self] in
            self?.registerAuthStateHandler()
        }
    }

    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            Task { @MainActor in
                self.user = user

                if let user = user {
                    self.userProfile = UserProfile(
                        name: self.pendingSignUpName ?? user.displayName ?? "",
                        email: user.email,
                        avatarUrl: user.photoURL?.absoluteString
                    )
                    self.pendingSignUpName = nil

                    // Exchange Firebase token for backend JWT
                    await self.exchangeFirebaseToken(user: user)
                } else {
                    self.isAuthenticated = false
                    self.userProfile = nil
                    self.keychainManager.clearTokens()
                }
                self.isCheckingAuth = false
            }
        }
    }

    private func exchangeFirebaseToken(user: User) async {
        do {
            let idToken = try await user.getIDToken()
            let provider = user.providerData.first?.providerID ?? "email"
            let providerName: String
            switch provider {
            case "google.com": providerName = "google"
            case "apple.com": providerName = "apple"
            default: providerName = "email"
            }

            let response: AuthResponse = try await apiClient.request(
                AuthEndpoint.socialLogin(provider: providerName, token: idToken)
            )
            keychainManager.saveTokens(access: response.accessToken, refresh: response.refreshToken)
            isAuthenticated = true
        } catch {
            // Backend might be unavailable — still allow Firebase-only auth
            print("Backend token exchange failed: \(error.localizedDescription)")
            isAuthenticated = true
        }
    }

    // MARK: - Email/Password

    func signIn(email: String, password: String) async {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String, name: String) async {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        isLoading = true
        errorMessage = nil
        pendingSignUpName = name

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
        } catch {
            pendingSignUpName = nil
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Google Sign In

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Google Client ID"
            isLoading = false
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Cannot find root view controller"
            isLoading = false
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token"
                isLoading = false
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            try await Auth.auth().signIn(with: credential)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Apple Sign In

    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce,
                      let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    errorMessage = "Unable to process Apple Sign In"
                    return
                }

                if let fullName = appleIDCredential.fullName {
                    pendingSignUpName = fullName.formatted()
                }

                let credential = OAuthProvider.appleCredential(
                    withIDToken: idTokenString,
                    rawNonce: nonce,
                    fullName: appleIDCredential.fullName
                )

                Task { await signInWithCredential(credential) }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func signInWithCredential(_ credential: AuthCredential) async {
        isLoading = true
        errorMessage = nil
        do {
            try await Auth.auth().signIn(with: credential)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            keychainManager.clearTokens()
            userProfile = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: pattern) != nil
    }

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            randomBytes = (0..<length).map { _ in UInt8.random(in: 0...255) }
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
