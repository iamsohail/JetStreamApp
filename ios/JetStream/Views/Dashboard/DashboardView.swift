import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var summary: AnalyticsSummary?
    @State private var recentFlights: [FlightResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let flightService = FlightService()

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

                        if isLoading && summary == nil {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .tint(Color.skyBlue)
                                    .scaleEffect(1.5)
                                Spacer()
                            }
                            .frame(height: 200)
                        } else if let error = errorMessage, summary == nil {
                            VStack(spacing: Theme.Spacing.md) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.amber)
                                Text(error)
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(Color.textSecondary)
                                Button("Retry") {
                                    Task { await loadData() }
                                }
                                .foregroundStyle(Color.skyBlue)
                            }
                            .padding(.vertical, Theme.Spacing.xxl)
                        } else {
                            // Stats grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                                StatCard(title: "Total Flights", value: "\(summary?.flightCount ?? 0)", icon: "airplane", color: .skyBlue)
                                StatCard(title: "Distance", value: String(format: "%.0f km", summary?.distanceKm ?? 0), icon: "globe", color: .emerald)
                                StatCard(title: "Flight Hours", value: "\(summary?.totalHours ?? 0)h", icon: "clock.fill", color: .amber)
                                StatCard(title: "Airports", value: "\(summary?.uniqueAirports ?? "0")", icon: "mappin.circle.fill", color: .skyBlue)
                            }
                            .padding(.horizontal)

                            // Upcoming flights
                            let upcoming = recentFlights.filter { $0.isUpcoming }.prefix(5)
                            if !upcoming.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Upcoming Flights")
                                        .font(Theme.Typography.headline)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal)

                                    ForEach(Array(upcoming), id: \.displayId) { flight in
                                        NavigationLink(destination: FlightDetailView(flight: flight)) {
                                            FlightCardView(flight: flight)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            } else {
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
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await loadData()
                }
            }
            .navigationTitle("Dashboard")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let summaryTask = flightService.getAnalyticsSummary()
            async let flightsTask = flightService.getFlights()
            summary = try await summaryTask
            recentFlights = try await flightsTask
        } catch {
            if summary == nil {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
