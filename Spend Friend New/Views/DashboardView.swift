import SwiftUI

struct DashboardView: View {
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header & Primary Chart
                LineChartCard(
                    title: "TOTAL VALUE",
                    value: "$\(networkManager.account?.equity ?? "0.00")",
                    diff: "+$1,100.00 (+29.70%)", // Mocked for now, will calculate later
                    data: [4200, 4300, 4250, 4400, 4600, 4550, 4800],
                    color: Theme.success
                )
                
                // Time selector (Mocked for UI)
                HStack(spacing: 12) {
                    ForEach(["1D", "1W", "1M", "3M", "1Y", "ALL"], id: \.self) { range in
                        Text(range)
                            .font(.system(size: 12, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(range == "1W" ? Theme.accent : Color.white.opacity(0.05))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 4)
                
                // Grid Stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        title: "Invested",
                        value: "$\(networkManager.account?.longMarketValue ?? "0.00")",
                        icon: "arrow.up.right",
                        iconColor: Theme.accent
                    )
                    
                    StatCard(
                        title: "This Month's Investment",
                        value: "$53.75",
                        icon: "calendar.badge.plus",
                        iconColor: Theme.success
                    )
                    
                    StatCard(
                        title: "PROFIT",
                        value: "$1,100.00",
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: Color.green,
                        badge: "+29.7%"
                    )
                    
                    StatCard(
                        title: "BUYING POWER",
                        value: "$\(networkManager.account?.buyingPower ?? "0.00")",
                        icon: "bolt.fill",
                        iconColor: Theme.accent
                    )
                }
            }
            .padding(20)
            .padding(.bottom, 100)
        }
        .onAppear {
            networkManager.fetchAllData()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    var badge: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(iconColor)
                    .clipShape(Circle())
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption.bold())
                        .foregroundColor(Theme.success)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(Theme.textSecondary)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
        }
        .padding(16)
        .background(Theme.secondaryBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
