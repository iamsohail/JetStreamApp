import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Avatar
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(Color.skyBlue)

                            Text(authService.userProfile?.name ?? "Traveler")
                                .font(Theme.Typography.title2)
                                .foregroundStyle(.white)

                            Text(authService.userProfile?.email ?? "")
                                .font(Theme.Typography.subheadline)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.top, Theme.Spacing.lg)

                        // Settings sections
                        VStack(spacing: Theme.Spacing.sm) {
                            ProfileRow(icon: "person.fill", title: "Edit Profile", color: .skyBlue)
                            ProfileRow(icon: "bell.fill", title: "Notifications", color: .amber)
                            ProfileRow(icon: "globe", title: "Units & Preferences", color: .emerald)
                            ProfileRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .textSecondary)
                        }
                        .padding(.horizontal)

                        // Sign out
                        Button {
                            authService.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .font(Theme.Typography.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.jetRed.opacity(0.15))
                            .foregroundStyle(Color.jetRed)
                            .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .padding(.horizontal)

                        Text("JetStream v\(AppConfig.shared.appVersion)")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            Text(title)
                .font(Theme.Typography.body)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(Theme.Typography.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}
