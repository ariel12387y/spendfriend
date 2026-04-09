import SwiftUI

struct PortfolioView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var selectedTab = "Stats"
    
    let tabs = ["Stats", "Assets", "History"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker Header
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: { withAnimation { selectedTab = tab } }) {
                        VStack(spacing: 12) {
                            Text(tab)
                                .font(.system(size: 16, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.4))
                            
                            Rectangle()
                                .fill(selectedTab == tab ? Theme.accent : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    if selectedTab == "Stats" {
                        StatsTabView(networkManager: networkManager)
                    } else if selectedTab == "Assets" {
                        AssetsTabView(networkManager: networkManager)
                    } else {
                        HistoryTabView(networkManager: networkManager)
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Stats Tab
struct StatsTabView: View {
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Next Milestone").font(.headline)
                
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("$\(networkManager.account?.equity ?? "0.00")").font(.title.bold())
                            Text("Total Value").font(.caption).foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                            Spacer()
                            Text("4.80K / $10,000") // Mocked goal for UI
                        }
                        .font(.caption.bold())
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.1))
                                Capsule()
                                    .fill(LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * 0.48) // 4.8k / 10k
                            }
                        }
                        .frame(height: 30)
                    }
                    
                    Text("CRUSHING IT")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Theme.accent)
                        .padding(.top, 10)
                }
                .padding(24)
                .background(Theme.secondaryBackground)
                .cornerRadius(24)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Invested Streak").font(.headline)
                // Simple Grid for Calendar Mockup
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)")
                            .font(.caption)
                            .frame(width: 30, height: 30)
                            .background(day < 7 ? Theme.accent : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(day < 7 ? .white : .white.opacity(0.6))
                    }
                }
                .padding(20)
                .background(Theme.secondaryBackground)
                .cornerRadius(24)
            }
        }
    }
}

// MARK: - Assets Tab
struct AssetsTabView: View {
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(spacing: 24) {
            DonutChartCard(
                totalValue: "$\(networkManager.account?.longMarketValue ?? "0.00")",
                segments: networkManager.positions.map { 
                    DonutSegment(label: $0.symbol, value: Double($0.marketValue) ?? 0, color: Theme.accent)
                }
            )
            
            VStack(alignment: .leading, spacing: 15) {
                Text("INDIVIDUAL STAKES").font(.caption.bold()).foregroundColor(Theme.textSecondary)
                
                ForEach(networkManager.positions) { position in
                    HStack {
                        Circle()
                            .fill(Theme.accent.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(Text(position.symbol.prefix(1)).bold())
                        
                        VStack(alignment: .leading) {
                            Text(position.symbol).font(.headline)
                            Text("\(position.qty) shares").font(.caption).foregroundColor(Theme.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("$\(position.marketValue)").font(.subheadline.bold())
                            Text("\(position.unrealizedPlpc)%").font(.caption).foregroundColor(Theme.success)
                        }
                    }
                    .padding(16)
                    .background(Theme.secondaryBackground)
                    .cornerRadius(20)
                }
            }
        }
    }
}

// MARK: - History Tab
struct HistoryTabView: View {
    @ObservedObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("ORDER HISTORY").font(.caption.bold()).foregroundColor(Theme.textSecondary)
            
            ForEach(networkManager.history) { item in
                HStack {
                    Image(systemName: "cart.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Theme.accent)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(item.brandName).font(.headline)
                        Text("\(item.stockTicker) • \(item.createdAt.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundColor(Theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("$\(item.investedAmount, specifier: "%.2f")").font(.subheadline.bold())
                        Text(item.status).font(.system(size: 10, weight: .bold)).foregroundColor(Theme.success)
                    }
                }
                .padding(16)
                .background(Theme.secondaryBackground)
                .cornerRadius(20)
            }
        }
    }
}
