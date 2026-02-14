import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Query(sort: \Flight.scheduledDeparture, order: .forward) var flights: [Flight]

    private var upcomingFlights: [Flight] {
        flights.filter { $0.isUpcoming }.prefix(5).map { $0 }
    }

    private var totalDistance: Double {
        flights.reduce(0) { $0 + $1.distanceKm }
    }

    private var totalHours: Int {
        flights.reduce(0) { $0 + $1.durationMinutes } / 60
    }

    private var uniqueCountries: Int {
        Set(flights.flatMap { [$0.departureCity, $0.arrivalCity] }).count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Greeting
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("Welcome back")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(Color.textSecondary)
                                Text(authService.userProfile?.name ?? "Traveler")
                                    .font(Theme.Typography.title2)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            Image(systemName: "airplane.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.skyBlue)
                        }
                        .padding(.horizontal)

                        // Stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                            StatCard(title: "Total Flights", value: "\(flights.count)", icon: "airplane", color: .skyBlue)
                            StatCard(title: "Distance", value: String(format: "%.0f km", totalDistance), icon: "globe", color: .emerald)
                            StatCard(title: "Flight Hours", value: "\(totalHours)h", icon: "clock.fill", color: .amber)
                            StatCard(title: "Cities", value: "\(uniqueCountries)", icon: "mappin.circle.fill", color: .skyBlue)
                        }
                        .padding(.horizontal)

                        // Upcoming flights
                        if !upcomingFlights.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Upcoming Flights")
                                    .font(Theme.Typography.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)

                                ForEach(upcomingFlights) { flight in
                                    NavigationLink(destination: FlightDetailView(flight: flight)) {
                                        FlightCard(flight: flight)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else {
                            // Empty state
                            VStack(spacing: Theme.Spacing.md) {
                                Image(systemName: "airplane.departure")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.textSecondary)
                                Text("No upcoming flights")
                                    .font(Theme.Typography.headline)
                                    .foregroundStyle(.white)
                                Text("Add a flight to get started")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.xxl)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Dashboard")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
