import SwiftUI

// MARK: - Date Extensions

extension Date {
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var flightDateString: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}

// MARK: - Double Extensions

extension Double {
    var formattedDistance: String {
        if self >= 1000 {
            return String(format: "%.0f km", self)
        }
        return String(format: "%.0f m", self * 1000)
    }
}
