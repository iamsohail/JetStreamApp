import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct JetStreamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthenticationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Flight.self])
    }
}
