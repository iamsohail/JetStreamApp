import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var summary: AnalyticsSummary?
    @State private var airlines: [AirlineBreakdown] = []
    @State private var airports: [AirportStat] = []
    @State private var records: RecordsData?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let flightService = FlightService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                if isLoading && summary == nil {
                    ProgressView()
                        .tint(Color.skyBlue)
                        .scaleEffect(1.5)
                } else if let error = errorMessage, summary == nil {
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.amber)
                        Text(error)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Color.textSecondary)
                        Button("Retry") {
                            Task { await loadData() }
                        }
                        .foregroundStyle(Color.skyBlue)
                    }
                } else if summary?.flightCount == 0 {
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.textSecondary)
                        Text("No analytics yet")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(.white)
                        Text("Add flights to see your travel stats")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.lg) {
                            // Summary stats
                            if let summary = summary {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                                    StatCard(title: "Total Flights", value: "\(summary.flightCount)", icon: "airplane", color: .skyBlue)
                                    StatCard(title: "Distance", value: String(format: "%.0f km", summary.distanceKm), icon: "globe", color: .emerald)
                                    StatCard(title: "Flight Hours", value: "\(summary.totalHours)h", icon: "clock.fill", color: .amber)
                                    StatCard(title: "Airlines", value: "\(airlines.count)", icon: "building.2", color: .skyBlue)
                                }
                                .padding(.horizontal)
                            }

                            // Airlines chart
                            if !airlines.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Flights by Airline")
                                        .font(Theme.Typography.headline)
                                        .foregroundStyle(.white)

                                    Chart(airlines) { item in
                                        BarMark(
                                            x: .value("Flights", item.count),
                                            y: .value("Airline", item.airlineName)
                                        )
                                        .foregroundStyle(Color.skyBlue.gradient)
                                    }
                                    .chartXAxis {
                                        AxisMarks { _ in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                                .foregroundStyle(Color.white.opacity(0.1))
                                            AxisValueLabel()
                                                .foregroundStyle(Color.textSecondary)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks { _ in
                                            AxisValueLabel()
                                                .foregroundStyle(Color.textSecondary)
                                        }
                                    }
                                    .frame(height: CGFloat(airlines.count * 44 + 20))
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(Theme.CornerRadius.card)
                                .padding(.horizontal)
                            }

                            // Top airports
                            if !airports.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Top Airports")
                                        .font(Theme.Typography.headline)
                                        .foregroundStyle(.white)

                                    ForEach(airports.prefix(5)) { item in
                                        HStack {
                                            Text(item.airport)
                                                .font(Theme.Typography.subheadlineMedium)
                                                .foregroundStyle(Color.skyBlue)
                                            Text(item.city ?? "")
                                                .font(Theme.Typography.subheadline)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Text("\(item.count) visits")
                                                .font(Theme.Typography.caption)
                                                .foregroundStyle(Color.textSecondary)
                                        }
                                        .padding(.vertical, Theme.Spacing.xs)
                                    }
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(Theme.CornerRadius.card)
                                .padding(.horizontal)
                            }

                            // Records
                            if let records = records {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Records")
                                        .font(Theme.Typography.headline)
                                        .foregroundStyle(.white)

                                    if let longest = records.longestFlight {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Longest Flight")
                                                    .font(Theme.Typography.caption)
                                                    .foregroundStyle(Color.textSecondary)
                                                Text(longest.route)
                                                    .font(Theme.Typography.subheadlineMedium)
                                                    .foregroundStyle(.white)
                                            }
                                            Spacer()
                                            if let dist = longest.distanceKm {
                                                Text("\(dist) km")
                                                    .font(Theme.Typography.captionMedium)
                                                    .foregroundStyle(Color.amber)
                                            }
                                        }
                                    }

                                    if let shortest = records.shortestFlight {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Shortest Flight")
                                                    .font(Theme.Typography.caption)
                                                    .foregroundStyle(Color.textSecondary)
                                                Text(shortest.route)
                                                    .font(Theme.Typography.subheadlineMedium)
                                                    .foregroundStyle(.white)
                                            }
                                            Spacer()
                                            if let dist = shortest.distanceKm {
                                                Text("\(dist) km")
                                                    .font(Theme.Typography.captionMedium)
                                                    .foregroundStyle(Color.emerald)
                                            }
                                        }
                                    }

                                    if let most = records.mostFlownRoute {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Most Flown Route")
                                                    .font(Theme.Typography.caption)
                                                    .foregroundStyle(Color.textSecondary)
                                                Text(most.route)
                                                    .font(Theme.Typography.subheadlineMedium)
                                                    .foregroundStyle(.white)
                                            }
                                            Spacer()
                                            Text("\(most.flightCount)x")
                                                .font(Theme.Typography.captionMedium)
                                                .foregroundStyle(Color.skyBlue)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(Theme.CornerRadius.card)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await loadData()
                    }
                }
            }
            .navigationTitle("Analytics")
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
            async let airlinesTask = flightService.getAirlineBreakdown()
            async let airportsTask = flightService.getAirportStats()
            async let recordsTask = flightService.getRecords()

            summary = try await summaryTask
            airlines = try await airlinesTask
            airports = try await airportsTask
            records = try await recordsTask
        } catch {
            if summary == nil {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
