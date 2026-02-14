import SwiftUI

enum Theme {
    enum Typography {
        static let largeTitle: Font = .system(size: 34, weight: .bold)
        static let title: Font = .system(size: 28, weight: .bold)
        static let title2: Font = .system(size: 22, weight: .bold)
        static let title3: Font = .system(size: 20, weight: .semibold)
        static let headline: Font = .system(size: 17, weight: .semibold)
        static let body: Font = .system(size: 17, weight: .regular)
        static let subheadline: Font = .system(size: 15, weight: .regular)
        static let subheadlineMedium: Font = .system(size: 15, weight: .medium)
        static let subheadlineSemibold: Font = .system(size: 15, weight: .semibold)
        static let footnote: Font = .system(size: 13, weight: .regular)
        static let caption: Font = .system(size: 12, weight: .regular)
        static let captionMedium: Font = .system(size: 12, weight: .medium)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let card: CGFloat = 20
    }

    // Aviation gradients
    static var skyGradient: LinearGradient {
        LinearGradient(
            colors: [Color.darkBackground, Color(hex: "1A2744")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Aviation Color Palette

extension Color {
    // Primary
    static let skyBlue = Color(hex: "0A84FF")
    // Accent
    static let amber = Color(hex: "FFD60A")
    // Status
    static let emerald = Color(hex: "30D158")
    static let jetRed = Color(hex: "FF453A")
    // Backgrounds
    static let darkBackground = Color(hex: "0A0E1A")
    static let cardBackground = Color(hex: "141B2D")
    // Text
    static let textSecondary = Color(hex: "8E8E93")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

extension View {
    func aviationCard() -> some View {
        self
            .padding(Theme.Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(Theme.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}
