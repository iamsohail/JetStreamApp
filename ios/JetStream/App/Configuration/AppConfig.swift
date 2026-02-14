import Foundation

final class AppConfig {
    static let shared = AppConfig()

    private init() {}

    // MARK: - API Configuration
    var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "http://192.168.1.9:3000/api/v1")!
        #else
        return URL(string: "https://api.jetstream.app/api/v1")!
        #endif
    }

    var networkTimeout: TimeInterval { 30 }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
