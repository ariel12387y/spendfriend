import SwiftUI

struct PaywallView: View {
    @Binding var currentStep: OnboardingStep
    @Binding var isYearly: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.accent)
                
                Text("Unlock Premium")
                    .font(.system(size: 34, weight: .bold))
                
                Text("Enjoy these benefits when you upgrade\nto the premium plan.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, 40)
            
            // Benefits
            VStack(alignment: .leading, spacing: 20) {
                BenefitItem(text: "Unlimited Auto-Investments")
                BenefitItem(text: "Priority Plaid Sync")
                BenefitItem(text: "Advanced Spending Insights")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Plan Selector
            VStack(spacing: 12) {
                PlanCard(
                    title: "Yearly",
                    subtitle: "2 MONTHS FREE INCLUDED",
                    price: "$49.99/year",
                    isSelected: isYearly,
                    badge: "SAVE 20%"
                ) { isYearly = true }
                
                PlanCard(
                    title: "Monthly",
                    subtitle: nil,
                    price: "$4.99/month",
                    isSelected: !isYearly,
                    badge: nil
                ) { isYearly = false }
            }
            .padding(.horizontal, 24)
            
            Text("Billed after 14 days. Cancel anytime.")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            
            // CTA Button
            Button(action: {
                withAnimation { currentStep = .howItWorks }
            }) {
                Text("Start 14-Day Free Trial")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [Theme.accent, Color(hex: "00B4D8")], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .shadow(color: Theme.accent.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Footer
            HStack(spacing: 20) {
                Text("Restore Purchase")
                Text("Privacy Policy")
                Text("Terms of Use")
            }
            .font(.system(size: 12))
            .foregroundColor(Theme.textSecondary)
            .padding(.bottom, 20)
        }
    }
}

struct BenefitItem: View {
    let text: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.white.opacity(0.3))
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct PlanCard: View {
    let title: String
    let subtitle: String?
    let price: String
    let isSelected: Bool
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 2)
                    if isSelected {
                        Circle().fill(Theme.accent).padding(4)
                        Circle().stroke(Theme.accent, lineWidth: 2)
                    }
                }
                .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundColor(.white)
                    if let sub = subtitle {
                        Text(sub).font(.caption.bold()).foregroundColor(Theme.accent)
                    }
                }
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.2))
                        .foregroundColor(Theme.accent)
                        .cornerRadius(20)
                }
                
                Spacer()
                
                Text(price).font(.subheadline).foregroundColor(.white)
            }
            .padding(20)
            .background(Theme.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Theme.accent : Color.clear, lineWidth: 2)
            )
        }
    }
}
