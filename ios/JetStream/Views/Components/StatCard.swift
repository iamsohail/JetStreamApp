import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(Theme.Typography.title2)
                .foregroundStyle(.white)

            Text(title)
                .font(Theme.Typography.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
