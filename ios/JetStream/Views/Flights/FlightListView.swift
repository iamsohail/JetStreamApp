import SwiftUI
import SwiftData

struct FlightListView: View {
    @Query(sort: \Flight.scheduledDeparture, order: .reverse) var flights: [Flight]
    @State private var selectedTab = 0
    @State private var showAddFlight = false

    private var upcomingFlights: [Flight] {
        flights.filter { $0.isUpcoming }
    }

    private var pastFlights: [Flight] {
        flights.filter { $0.isPast }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented control
                    Picker("", selection: $selectedTab) {
                        Text("Upcoming").tag(0)
                        Text("Past").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    let displayFlights = selectedTab == 0 ? upcomingFlights : pastFlights

                    if displayFlights.isEmpty {
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
                                ForEach(displayFlights) { flight in
                                    NavigationLink(destination: FlightDetailView(flight: flight)) {
                                        FlightCard(flight: flight)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
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
        }
    }
}
