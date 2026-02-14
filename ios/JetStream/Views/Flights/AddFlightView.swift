import SwiftUI

struct AddFlightView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Flight Search").tag(0)
                        Text("Manual Entry").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    if selectedTab == 0 {
                        FlightSearchView()
                    } else {
                        ManualFlightEntryView()
                    }
                }
            }
            .navigationTitle("Add Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.skyBlue)
                }
            }
        }
    }
}

struct ManualFlightEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var flightNumber = ""
    @State private var airlineCode = ""
    @State private var airlineName = ""
    @State private var departureCode = ""
    @State private var departureName = ""
    @State private var departureCity = ""
    @State private var arrivalCode = ""
    @State private var arrivalName = ""
    @State private var arrivalCity = ""
    @State private var departureDate = Date()
    @State private var arrivalDate = Date()
    @State private var cabinClass: CabinClass = .economy
    @State private var seatNumber = ""
    @State private var notes = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let flightService = FlightService()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                Group {
                    TextField("", text: $flightNumber, prompt: Text("Flight Number (e.g. AI101)").foregroundStyle(Color.textSecondary))
                    TextField("", text: $airlineCode, prompt: Text("Airline Code (e.g. AI)").foregroundStyle(Color.textSecondary))
                    TextField("", text: $airlineName, prompt: Text("Airline Name").foregroundStyle(Color.textSecondary))
                }
                .textFieldStyle(JetStreamTextFieldStyle())

                Group {
                    TextField("", text: $departureCode, prompt: Text("Departure Airport (e.g. DEL)").foregroundStyle(Color.textSecondary))
                    TextField("", text: $departureName, prompt: Text("Airport Name").foregroundStyle(Color.textSecondary))
                    TextField("", text: $departureCity, prompt: Text("Departure City").foregroundStyle(Color.textSecondary))
                }
                .textFieldStyle(JetStreamTextFieldStyle())
                .textInputAutocapitalization(.characters)

                Group {
                    TextField("", text: $arrivalCode, prompt: Text("Arrival Airport (e.g. BOM)").foregroundStyle(Color.textSecondary))
                    TextField("", text: $arrivalName, prompt: Text("Airport Name").foregroundStyle(Color.textSecondary))
                    TextField("", text: $arrivalCity, prompt: Text("Arrival City").foregroundStyle(Color.textSecondary))
                }
                .textFieldStyle(JetStreamTextFieldStyle())
                .textInputAutocapitalization(.characters)

                DatePicker("Departure", selection: $departureDate)
                    .tint(Color.skyBlue)
                    .foregroundStyle(.white)
                DatePicker("Arrival", selection: $arrivalDate)
                    .tint(Color.skyBlue)
                    .foregroundStyle(.white)

                Picker("Cabin Class", selection: $cabinClass) {
                    ForEach(CabinClass.allCases, id: \.self) { cabin in
                        Text(cabin.displayName).tag(cabin)
                    }
                }
                .tint(Color.skyBlue)
                .foregroundStyle(.white)

                TextField("", text: $seatNumber, prompt: Text("Seat Number").foregroundStyle(Color.textSecondary))
                    .textFieldStyle(JetStreamTextFieldStyle())

                TextField("", text: $notes, prompt: Text("Notes").foregroundStyle(Color.textSecondary))
                    .textFieldStyle(JetStreamTextFieldStyle())

                if let error = errorMessage {
                    Text(error)
                        .font(Theme.Typography.footnote)
                        .foregroundStyle(Color.jetRed)
                }

                Button {
                    Task { await saveFlight() }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView().tint(.white)
                        }
                        Text("Add Flight")
                            .font(Theme.Typography.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.skyBlue)
                    .foregroundStyle(.white)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                .disabled(flightNumber.isEmpty || departureCode.isEmpty || arrivalCode.isEmpty || isSaving)
            }
            .padding()
        }
    }

    private func saveFlight() async {
        isSaving = true
        errorMessage = nil
        let duration = Int(arrivalDate.timeIntervalSince(departureDate) / 60)

        let request = FlightCreateRequest(
            pnr: nil,
            flightNumber: flightNumber.uppercased(),
            airlineCode: airlineCode.uppercased(),
            airlineName: airlineName,
            departureAirport: departureCode.uppercased(),
            departureCity: departureCity.isEmpty ? nil : departureCity,
            arrivalAirport: arrivalCode.uppercased(),
            arrivalCity: arrivalCity.isEmpty ? nil : arrivalCity,
            scheduledDeparture: departureDate,
            scheduledArrival: arrivalDate,
            cabinClass: cabinClass.rawValue,
            seatNumber: seatNumber.isEmpty ? nil : seatNumber,
            notes: notes.isEmpty ? nil : notes,
            isManualEntry: true,
            durationMinutes: max(duration, 0)
        )

        do {
            _ = try await flightService.createFlight(request)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
