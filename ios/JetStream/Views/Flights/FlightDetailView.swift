import SwiftUI

struct FlightDetailView: View {
    let flight: Flight

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Flight header
                    VStack(spacing: Theme.Spacing.sm) {
                        Text(flight.airlineName)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Color.textSecondary)
                        Text(flight.flightNumber)
                            .font(Theme.Typography.largeTitle)
                            .foregroundStyle(.white)
                        StatusBadge(status: flight.status)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.card)
                    .padding(.horizontal)

                    // Route card
                    HStack {
                        // Departure
                        VStack(spacing: Theme.Spacing.xs) {
                            Text(flight.departureAirportCode)
                                .font(Theme.Typography.title)
                                .foregroundStyle(.white)
                            Text(flight.departureCity)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                            Text(flight.scheduledDeparture, style: .time)
                                .font(Theme.Typography.subheadlineMedium)
                                .foregroundStyle(Color.skyBlue)
                        }

                        Spacer()

                        // Route line
                        VStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "airplane")
                                .foregroundStyle(Color.skyBlue)
                            Text(flight.durationFormatted)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        // Arrival
                        VStack(spacing: Theme.Spacing.xs) {
                            Text(flight.arrivalAirportCode)
                                .font(Theme.Typography.title)
                                .foregroundStyle(.white)
                            Text(flight.arrivalCity)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                            Text(flight.scheduledArrival, style: .time)
                                .font(Theme.Typography.subheadlineMedium)
                                .foregroundStyle(Color.skyBlue)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.card)
                    .padding(.horizontal)

                    // Details grid
                    VStack(spacing: Theme.Spacing.md) {
                        DetailRow(label: "Date", value: flight.scheduledDeparture.formatted(date: .long, time: .omitted))
                        DetailRow(label: "Cabin", value: flight.cabinClass.displayName)
                        if let seat = flight.seatNumber {
                            DetailRow(label: "Seat", value: seat)
                        }
                        if let aircraft = flight.aircraftType {
                            DetailRow(label: "Aircraft", value: aircraft)
                        }
                        if let terminal = flight.departureTerminal {
                            DetailRow(label: "Terminal", value: terminal)
                        }
                        if let gate = flight.departureGate {
                            DetailRow(label: "Gate", value: gate)
                        }
                        DetailRow(label: "Distance", value: String(format: "%.0f km", flight.distanceKm))
                        if let pnr = flight.pnr {
                            DetailRow(label: "PNR", value: pnr)
                        }
                        if let ref = flight.bookingReference {
                            DetailRow(label: "Booking Ref", value: ref)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.card)
                    .padding(.horizontal)

                    // Notes
                    if let notes = flight.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Notes")
                                .font(Theme.Typography.headline)
                                .foregroundStyle(.white)
                            Text(notes)
                                .font(Theme.Typography.body)
                                .foregroundStyle(Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(Theme.CornerRadius.card)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct StatusBadge: View {
    let status: FlightStatus

    private var color: Color {
        switch status {
        case .scheduled, .landed: return .skyBlue
        case .boarding, .delayed, .diverted: return .amber
        case .departed, .inAir: return .emerald
        case .cancelled: return .jetRed
        }
    }

    var body: some View {
        Text(status.displayName)
            .font(Theme.Typography.captionMedium)
            .foregroundStyle(color)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(color.opacity(0.15))
            .cornerRadius(Theme.CornerRadius.small)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.subheadlineMedium)
                .foregroundStyle(.white)
        }
    }
}
