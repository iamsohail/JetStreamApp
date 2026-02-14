import SwiftUI

struct FlightListView: View {
    @State private var flights: [FlightResponse] = []
    @State private var selectedTab = 0
    @State private var showAddFlight = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let flightService = FlightService()

    private var upcomingFlights: [FlightResponse] {
        flights.filter { $0.isUpcoming }
    }

    private var pastFlights: [FlightResponse] {
        flights.filter { $0.isPast }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Upcoming").tag(0)
                        Text("Past").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    let displayFlights = selectedTab == 0 ? upcomingFlights : pastFlights

                    if isLoading && flights.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(Color.skyBlue)
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let error = errorMessage, flights.isEmpty {
                        Spacer()
                        VStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.amber)
                            Text(error)
                                .font(Theme.Typography.subheadline)
                                .foregroundStyle(Color.textSecondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task { await loadFlights() }
                            }
                            .foregroundStyle(Color.skyBlue)
                        }
                        Spacer()
                    } else if displayFlights.isEmpty {
                        Spacer()
                        VStack(spacing: Theme.Spacing.md) {
                            Image(systemName: selectedTab == 0 ? "airplane.departure" : "airplane.arrival")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.textSecondary)
                            Text(selectedTab == 0 ? "No upcoming flights" : "No past flights")
                                .font(Theme.Typography.headline)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Theme.Spacing.sm) {
                                ForEach(displayFlights, id: \.displayId) { flight in
                                    NavigationLink(destination: FlightDetailView(flight: flight)) {
                                        FlightCardView(flight: flight)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .refreshable {
                            await loadFlights()
                        }
                    }
                }
            }
            .navigationTitle("Flights")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddFlight = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.skyBlue)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddFlight) {
                AddFlightView()
            }
            .onChange(of: showAddFlight) { _, isShowing in
                if !isShowing {
                    Task { await loadFlights() }
                }
            }
            .task {
                await loadFlights()
            }
        }
    }

    private func loadFlights() async {
        isLoading = true
        errorMessage = nil
        do {
            flights = try await flightService.getFlights()
        } catch {
            if flights.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
