import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query var flights: [Flight]

    private var totalDistance: Double {
        flights.reduce(0) { $0 + $1.distanceKm }
    }

    private var totalHours: Int {
        flights.reduce(0) { $0 + $1.durationMinutes } / 60
    }

    private var airlineBreakdown: [(name: String, count: Int)] {
        Dictionary(grouping: flights, by: { $0.airlineName })
            .map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var topRoutes: [(route: String, count: Int)] {
        Dictionary(grouping: flights, by: { $0.route })
            .map { (route: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                if flights.isEmpty {
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
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                                StatCard(title: "Total Flights", value: "\(flights.count)", icon: "airplane", color: .skyBlue)
                                StatCard(title: "Distance", value: String(format: "%.0f km", totalDistance), icon: "globe", color: .emerald)
                                StatCard(title: "Flight Hours", value: "\(totalHours)h", icon: "clock.fill", color: .amber)
                                StatCard(title: "Airlines", value: "\(airlineBreakdown.count)", icon: "building.2", color: .skyBlue)
                            }
                            .padding(.horizontal)

                            // Airlines chart
                            if !airlineBreakdown.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Flights by Airline")
                                        .font(Theme.Typography.headline)
                                        .foregroundStyle(.white)

                                    Chart(airlineBreakdown, id: \.name) { item in
                                        BarMark(
                                            x: .value("Flights", item.count),
                                            y: .value("Airline", item.name)
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
                                    .frame(height: CGFloat(airlineBreakdown.count * 44 + 20))
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(Theme.CornerRadius.card)
                                .padding(.horizontal)
                            }

                            // Top routes
                            if !topRoutes.isEmpty {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Top Routes")
                                        .font(Theme.Typography.headline)
                                        .foregroundStyle(.white)

                                    ForEach(topRoutes, id: \.route) { item in
                                        HStack {
                                            Text(item.route)
                                                .font(Theme.Typography.subheadlineMedium)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Text("\(item.count) flights")
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
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Analytics")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
