import SwiftUI

struct FlightDetailView: View {
    let flight: FlightResponse
    @State private var liveStatus: FlightStatusResponse?
    @State private var isLoadingStatus = false

    private let flightService = FlightService()

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
                        StatusBadge(status: flight.flightStatus)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(Theme.CornerRadius.card)
                    .padding(.horizontal)

                    // Route card
                    HStack {
                        VStack(spacing: Theme.Spacing.xs) {
                            Text(flight.departureAirport)
                                .font(Theme.Typography.title)
                                .foregroundStyle(.white)
                            Text(flight.departureCity ?? "")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                            Text(flight.scheduledDeparture, style: .time)
                                .font(Theme.Typography.subheadlineMedium)
                                .foregroundStyle(Color.skyBlue)
                        }

                        Spacer()

                        VStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "airplane")
                                .foregroundStyle(Color.skyBlue)
                            Text(flight.durationFormatted)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        }

                        Spacer()

                        VStack(spacing: Theme.Spacing.xs) {
                            Text(flight.arrivalAirport)
                                .font(Theme.Typography.title)
                                .foregroundStyle(.white)
                            Text(flight.arrivalCity ?? "")
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

                    // Live status
                    if let live = liveStatus {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            HStack {
                                Text("Live Status")
                                    .font(Theme.Typography.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                if isLoadingStatus {
                                    ProgressView().tint(Color.skyBlue).controlSize(.small)
                                }
                            }
                            if let delay = live.delayMinutes, delay > 0 {
                                DetailRow(label: "Delay", value: "\(delay) min")
                            }
                            if let gate = live.departureGate {
                                DetailRow(label: "Dep. Gate", value: gate)
                            }
                            if let gate = live.arrivalGate {
                                DetailRow(label: "Arr. Gate", value: gate)
                            }
                            if let terminal = live.departureTerminal {
                                DetailRow(label: "Dep. Terminal", value: terminal)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(Theme.CornerRadius.card)
                        .padding(.horizontal)
                    }

                    // Details grid
                    VStack(spacing: Theme.Spacing.md) {
                        DetailRow(label: "Date", value: flight.scheduledDeparture.formatted(date: .long, time: .omitted))
                        DetailRow(label: "Cabin", value: flight.cabin.displayName)
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
                        if let dist = flight.distanceKm {
                            DetailRow(label: "Distance", value: String(format: "%.0f km", dist))
                        }
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
        .task {
            await fetchLiveStatus()
        }
    }

    private func fetchLiveStatus() async {
        guard let id = flight.id, flight.isUpcoming else { return }
        isLoadingStatus = true
        do {
            liveStatus = try await flightService.getFlightStatus(id: id)
        } catch {
            // Silently fail — live status is optional
        }
        isLoadingStatus = false
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
