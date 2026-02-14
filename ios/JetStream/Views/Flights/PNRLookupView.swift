import SwiftUI
import SwiftData

struct PNRLookupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var pnr = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.amber)

                Text("Enter your PNR/Booking Reference")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(.white)

                Text("We'll fetch your flight details automatically")
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Color.textSecondary)
            }

            TextField("", text: $pnr, prompt: Text("PNR Code (e.g. ABC123)").foregroundStyle(Color.textSecondary))
                .textFieldStyle(JetStreamTextFieldStyle())
                .textInputAutocapitalization(.characters)
                .padding(.horizontal)

            if let error = errorMessage {
                Text(error)
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Color.jetRed)
            }

            Button {
                Task { await lookupPNR() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                    }
                    Text("Look Up Flight")
                        .font(Theme.Typography.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.skyBlue)
                .foregroundStyle(.white)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            .disabled(pnr.count < 5 || isLoading)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, Theme.Spacing.xl)
    }

    private func lookupPNR() async {
        isLoading = true
        errorMessage = nil

        do {
            let flightService = FlightService()
            let flightData: FlightResponse = try await flightService.lookupPNR(pnr: pnr)

            let flight = Flight(
                pnr: pnr,
                flightNumber: flightData.flightNumber,
                airlineCode: flightData.airlineCode,
                airlineName: flightData.airlineName,
                departureAirportCode: flightData.departureAirport,
                departureAirportName: flightData.departureAirportName ?? "",
                departureCity: flightData.departureCity ?? "",
                arrivalAirportCode: flightData.arrivalAirport,
                arrivalAirportName: flightData.arrivalAirportName ?? "",
                arrivalCity: flightData.arrivalCity ?? "",
                scheduledDeparture: flightData.scheduledDeparture,
                scheduledArrival: flightData.scheduledArrival,
                aircraftType: flightData.aircraftType,
                distanceKm: flightData.distanceKm ?? 0,
                durationMinutes: flightData.durationMinutes ?? 0
            )
            modelContext.insert(flight)
            dismiss()
        } catch {
            errorMessage = "Could not find flight for PNR: \(pnr)"
        }

        isLoading = false
    }
}
