import SwiftUI
import SwiftData

struct AddFlightView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("PNR Lookup").tag(0)
                        Text("Manual Entry").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    if selectedTab == 0 {
                        PNRLookupView()
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
    @Environment(\.modelContext) var modelContext
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

                Button {
                    saveFlight()
                } label: {
                    Text("Add Flight")
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.skyBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                .disabled(flightNumber.isEmpty || departureCode.isEmpty || arrivalCode.isEmpty)
            }
            .padding()
        }
    }

    private func saveFlight() {
        let duration = Int(arrivalDate.timeIntervalSince(departureDate) / 60)
        let flight = Flight(
            flightNumber: flightNumber.uppercased(),
            airlineCode: airlineCode.uppercased(),
            airlineName: airlineName,
            departureAirportCode: departureCode.uppercased(),
            departureAirportName: departureName,
            departureCity: departureCity,
            arrivalAirportCode: arrivalCode.uppercased(),
            arrivalAirportName: arrivalName,
            arrivalCity: arrivalCity,
            scheduledDeparture: departureDate,
            scheduledArrival: arrivalDate,
            seatNumber: seatNumber.isEmpty ? nil : seatNumber,
            cabinClass: cabinClass,
            durationMinutes: max(duration, 0),
            notes: notes.isEmpty ? nil : notes,
            isManualEntry: true
        )
        modelContext.insert(flight)
        dismiss()
    }
}
