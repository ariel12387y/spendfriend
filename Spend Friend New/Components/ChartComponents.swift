import SwiftUI
import Charts

// MARK: - Line Chart Component
struct LineChartCard: View {
    let title: String
    let value: String
    let diff: String
    let data: [Double]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(Theme.textSecondary)
                .kerning(1.2)
            
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            
            Text(diff)
                .font(.subheadline.bold())
                .foregroundColor(color)
            
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, element in
                    AreaMark(
                        x: .value("Time", index),
                        y: .value("Value", element)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Time", index),
                        y: .value("Value", element)
                    )
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 180)
            .padding(.top, 10)
        }
        .padding(24)
        .background(Theme.secondaryBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Donut Chart Component
struct DonutChartCard: View {
    let totalValue: String
    let segments: [DonutSegment]
    
    var body: some View {
        ZStack {
            Chart(segments) { segment in
                SectorMark(
                    angle: .value("Value", segment.value),
                    innerRadius: .ratio(0.7),
                    angularInset: 2
                )
                .foregroundStyle(segment.color)
                .cornerRadius(5)
            }
            .frame(height: 250)
            
            VStack {
                Text("TOTAL VALUE")
                    .font(.caption.bold())
                    .foregroundColor(Theme.textSecondary)
                Text(totalValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
        }
        .padding(24)
        .background(Theme.secondaryBackground)
        .cornerRadius(32)
    }
}

struct DonutSegment: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}
