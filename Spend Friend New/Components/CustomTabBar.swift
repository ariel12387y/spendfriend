import SwiftUI

enum Tab: String, CaseIterable {
    case dashboard = "square.grid.2x2.fill"
    case portfolio = "bolt.fill"
    case transactions = "list.bullet.rectangle.fill"
    case settings = "gearshape.fill"
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .portfolio: return "Portfolio"
        case .transactions: return "Transactions"
        case .settings: return "Settings"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 20))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? Theme.accent : .white.opacity(0.4))
                }
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Theme.secondaryBackground.opacity(0.9))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
    }
}
