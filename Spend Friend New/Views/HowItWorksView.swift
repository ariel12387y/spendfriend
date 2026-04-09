import SwiftUI

struct HowItWorksView: View {
    @Binding var currentStep: OnboardingStep
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 15) {
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Theme.accent)
                    .clipShape(Circle())
                    .shadow(color: Theme.accent.opacity(0.5), radius: 10)
                
                VStack(alignment: .leading) {
                    Text("How It Works")
                        .font(.title2.bold())
                    Text("Simple path to ownership.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            Spacer().frame(height: 40)
            
            // Steps List
            VStack(spacing: 0) {
                StepRow(number: 1, icon: "building.2.fill", title: "Choose companies", subtitle: "Pick the brands you use\nevery day", isLast: false)
                StepRow(number: 2, icon: "dollarsign.circle.fill", title: "Choose dollar amount", subtitle: "Decide how much to invest\nper purchase", isLast: false)
                StepRow(number: 3, icon: "cart.fill", title: "Make a purchase", subtitle: "Buy anything you\nalready love", isLast: false)
                StepRow(number: 4, icon: "bolt.fill", title: "Investment triggered", subtitle: "SpendFriend automatically\ninitiates a trade", isLast: false)
                StepRow(number: 5, icon: "chart.line.uptrend.xyaxis", title: "Portfolio grows", subtitle: "Watch your ownership build\nover time", isLast: true)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                withAnimation { currentStep = .bankSecured }
            }) {
                Text("Start investing")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

struct StepRow: View {
    let number: Int
    let icon: String
    let title: String
    let subtitle: String
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold))
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 2, height: 60)
                }
            }
            
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Theme.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}
