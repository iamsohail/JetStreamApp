import SwiftUI

struct FlightSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var flightNumber = ""
    @State private var useDate = false
    @State private var searchDate = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchResults: [FlightResponse] = []
    @State private var isSaving = false

    private let flightService = FlightService()

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.amber)

                Text("Search by Flight Number")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)

                Text("Enter a flight number to find details")
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: Theme.Spacing.md) {
                TextField("", text: $flightNumber, prompt: Text("Flight Number (e.g. AI101)").foregroundStyle(Color.textSecondary))
                    .textFieldStyle(JetStreamTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .padding(.horizontal)

                Toggle(isOn: $useDate) {
                    Text("Specific date")
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.white)
                }
                .tint(Color.skyBlue)
                .padding(.horizontal)

                if useDate {
                    DatePicker("Date", selection: $searchDate, displayedComponents: .date)
                        .tint(Color.skyBlue)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Color.jetRed)
            }

            Button {
                Task { await searchFlight() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    }
                    Text("Search")
                        .font(Theme.Typography.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.skyBlue)
                .foregroundStyle(.white)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            .disabled(flightNumber.count < 3 || isLoading)
            .padding(.horizontal)

            if !searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(searchResults, id: \.flightNumber) { flight in
                            FlightSearchResultCard(flight: flight, isSaving: $isSaving) {
                                await addFlight(flight)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Spacer()
            }
        }
        .padding(.top, Theme.Spacing.lg)
    }

    private func searchFlight() async {
        isLoading = true
        errorMessage = nil
        searchResults = []

        do {
            let dateStr = useDate ? searchDate.formatted(.iso8601.year().month().day()) : nil
            searchResults = try await flightService.searchByFlightNumber(flightNumber.uppercased(), date: dateStr)
            if searchResults.isEmpty {
                errorMessage = "No flights found for \(flightNumber.uppercased())"
            }
        } catch {
            errorMessage = "Could not find flight: \(flightNumber.uppercased())"
        }

        isLoading = false
    }

    private func addFlight(_ flight: FlightResponse) async {
        isSaving = true
        do {
            let request = FlightCreateRequest(
                pnr: nil,
                flightNumber: flight.flightNumber,
                airlineCode: flight.airlineCode,
                airlineName: flight.airlineName,
                departureAirport: flight.departureAirport,
                departureCity: flight.departureCity,
                arrivalAirport: flight.arrivalAirport,
                arrivalCity: flight.arrivalCity,
                scheduledDeparture: flight.scheduledDeparture,
                scheduledArrival: flight.scheduledArrival,
                cabinClass: nil,
                seatNumber: nil,
                notes: nil,
                isManualEntry: false
            )
            try await flightService.createFlight(request)
            dismiss()
        } catch {
            errorMessage = "Failed to save flight"
        }
        isSaving = false
    }
}

struct FlightSearchResultCard: View {
    let flight: FlightResponse
    @Binding var isSaving: Bool
    let onAdd: () async -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack {
                Text(flight.airlineName)
                    .font(Theme.Typography.captionMedium)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(flight.flightNumber)
                    .font(Theme.Typography.subheadlineMedium)
                    .foregroundStyle(Color.skyBlue)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(flight.departureAirport)
                        .font(Theme.Typography.title2)
                        .foregroundStyle(.white)
                    Text(flight.departureCity ?? "")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Image(systemName: "airplane")
                    .foregroundStyle(Color.skyBlue)

                Spacer()

                VStack(alignment: .trailing) {
                    Text(flight.arrivalAirport)
                        .font(Theme.Typography.title2)
                        .foregroundStyle(.white)
                    Text(flight.arrivalCity ?? "")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            HStack {
                Text(flight.scheduledDeparture.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Button {
                    Task { await onAdd() }
                } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        if isSaving {
                            ProgressView().tint(.white).controlSize(.small)
                        }
                        Text("Add")
                            .font(Theme.Typography.captionMedium)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Color.skyBlue)
                    .foregroundStyle(.white)
                    .cornerRadius(Theme.CornerRadius.small)
                }
                .disabled(isSaving)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.card)
    }
}
