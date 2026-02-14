import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Logo
                    VStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 70))
                            .foregroundStyle(Color.skyBlue)
                        Text("JetStream")
                            .font(Theme.Typography.largeTitle)
                            .foregroundStyle(.white)
                        Text("Track your flights, explore your journey")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xxl)

                    // Form
                    VStack(spacing: Theme.Spacing.md) {
                        if isSignUp {
                            TextField("", text: $name, prompt: Text("Full Name").foregroundStyle(Color.textSecondary))
                                .textFieldStyle(JetStreamTextFieldStyle())
                                .textContentType(.name)
                        }

                        TextField("", text: $email, prompt: Text("Email").foregroundStyle(Color.textSecondary))
                            .textFieldStyle(JetStreamTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        SecureField("", text: $password, prompt: Text("Password").foregroundStyle(Color.textSecondary))
                            .textFieldStyle(JetStreamTextFieldStyle())
                            .textContentType(isSignUp ? .newPassword : .password)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Error message
                    if let error = authService.errorMessage {
                        Text(error)
                            .font(Theme.Typography.footnote)
                            .foregroundStyle(Color.jetRed)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Primary button
                    Button {
                        Task {
                            if isSignUp {
                                await authService.signUp(email: email, password: password, name: name)
                            } else {
                                await authService.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        HStack {
                            if authService.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(Theme.Typography.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.skyBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(Theme.CornerRadius.medium)
                    }
                    .disabled(authService.isLoading)
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(Color.textSecondary.opacity(0.3))
                        Text("or").font(Theme.Typography.caption).foregroundStyle(Color.textSecondary)
                        Rectangle().frame(height: 1).foregroundStyle(Color.textSecondary.opacity(0.3))
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Social buttons
                    VStack(spacing: Theme.Spacing.sm) {
                        // Google
                        Button {
                            Task { await authService.signInWithGoogle() }
                        } label: {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Continue with Google")
                                    .font(Theme.Typography.subheadlineMedium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cardBackground)
                            .foregroundStyle(.white)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }

                        // Apple
                        SignInWithAppleButton(.signIn) { request in
                            authService.handleSignInWithAppleRequest(request)
                        } onCompletion: { result in
                            authService.handleSignInWithAppleCompletion(result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(Theme.CornerRadius.medium)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Toggle sign in / sign up
                    Button {
                        withAnimation { isSignUp.toggle() }
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(Theme.Typography.footnote)
                            .foregroundStyle(Color.skyBlue)
                    }
                }
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
    }
}

struct JetStreamTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.cardBackground)
            .foregroundStyle(.white)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
