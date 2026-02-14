import SwiftUI

struct FlightCard: View {
    let flight: Flight

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Top row: airline + status
            HStack {
                Text(flight.airlineName)
                    .font(Theme.Typography.captionMedium)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                StatusBadge(status: flight.status)
            }

            // Route
            HStack {
                VStack(alignment: .leading) {
                    Text(flight.departureAirportCode)
                        .font(Theme.Typography.title2)
                        .foregroundStyle(.white)
                    Text(flight.departureCity)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                VStack(spacing: Theme.Spacing.xs) {
                    Text(flight.flightNumber)
                        .font(Theme.Typography.captionMedium)
                        .foregroundStyle(Color.skyBlue)
                    Image(systemName: "airplane")
                        .foregroundStyle(Color.skyBlue)
                        .font(.caption)
                    Text(flight.durationFormatted)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(flight.arrivalAirportCode)
                        .font(Theme.Typography.title2)
                        .foregroundStyle(.white)
                    Text(flight.arrivalCity)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            // Bottom: date + cabin
            HStack {
                Text(flight.scheduledDeparture.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(flight.cabinClass.displayName)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
