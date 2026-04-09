import SwiftUI

struct OnboardingView: View {
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var authManager: AuthManager
    @State private var currentStep: OnboardingStep = .paywall
    @State private var selectedBrands: [Brand] = Brand.allBrands
    @State private var isYearlyPlan = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack {
                // Progress Indicator (for steps 1-4)
                if currentStep != .paywall {
                    ProgressDots(currentStep: currentStep)
                        .padding(.top, 20)
                }
                
                Spacer()
                
                // Step Views
                ZStack {
                    switch currentStep {
                    case .paywall:
                        PaywallView(currentStep: $currentStep, isYearly: $isYearlyPlan)
                    case .howItWorks:
                        HowItWorksView(currentStep: $currentStep)
                    case .bankSecured:
                        BankSecuredView(networkManager: networkManager, currentStep: $currentStep)
                    case .chooseBrands:
                        BrandSelectionView(currentStep: $currentStep, brands: $selectedBrands)
// ...
                    case .amountConfig:
                        AmountConfigurationView(currentStep: $currentStep, brands: $selectedBrands, onComplete: {
                            withAnimation { authManager.hasCompletedOnboarding = true }
                        })
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
                Spacer()
                
                // Skip Button (Fixed at bottom for all but paywall)
                if currentStep != .paywall {
                    Button("Skip") {
                        if currentStep == .amountConfig {
                            withAnimation { authManager.hasCompletedOnboarding = true }
                        } else {
                            withAnimation { currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? .amountConfig }
                        }
                    }
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct ProgressDots: View {
    let currentStep: OnboardingStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...4, id: \.self) { index in
                Circle()
                    .fill(currentStep.rawValue >= index ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
