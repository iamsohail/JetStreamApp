import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            if authService.isCheckingAuth {
                ZStack {
                    Color.darkBackground.ignoresSafeArea()
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "airplane")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.skyBlue)
                        Text("JetStream")
                            .font(Theme.Typography.title)
                            .foregroundStyle(.white)
                        ProgressView()
                            .tint(Color.skyBlue)
                    }
                }
            } else if authService.isAuthenticated {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
        .animation(.easeInOut, value: authService.isCheckingAuth)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "airplane.circle.fill")
                }

            FlightListView()
                .tabItem {
                    Label("Flights", systemImage: "list.bullet")
                }

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color.skyBlue)
    }
}
