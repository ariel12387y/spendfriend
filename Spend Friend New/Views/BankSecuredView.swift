import SwiftUI

struct BankSecuredView: View {
    @ObservedObject var networkManager: NetworkManager
    @Binding var currentStep: OnboardingStep
    @State private var showPlaidLink = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Bank Logo Cloud
            ZStack {
                Circle()
                    .fill(Color(hex: "1A2333"))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.accent)
                    )
                    .shadow(color: Theme.accent.opacity(0.3), radius: 20)
                
                BankLogoView(name: "Chase", color: .blue, offset: CGSize(width: 0, height: -120))
                BankLogoView(name: "Wells Fargo", color: .red, offset: CGSize(width: -130, height: -40))
                BankLogoView(name: "Capital One", color: .black, offset: CGSize(width: 130, height: -40))
                BankLogoView(name: "Citi", color: .blue, offset: CGSize(width: -80, height: 80))
                BankLogoView(name: "BofA", color: .red, offset: CGSize(width: 80, height: 80))
            }
            .frame(height: 300)
            
            VStack(spacing: 15) {
                Text("Bank Secured")
                    .font(.system(size: 34, weight: .bold))
                
                Text(networkManager.isPlaidConnected ? "Your bank is securely connected." : "Securely link your bank account via Plaid\nto monitor transactions.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                if networkManager.isPlaidConnected {
                    withAnimation { currentStep = .chooseBrands }
                } else {
                    showPlaidLink = true
                }
            }) {
                HStack {
                    Text(networkManager.isPlaidConnected ? "Continue" : "Connect Bank")
                    Image(systemName: networkManager.isPlaidConnected ? "arrow.right" : "lock.fill")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(networkManager.isPlaidConnected ? Theme.success : Theme.accent)
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showPlaidLink) {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if let error = networkManager.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Dismiss") { showPlaidLink = false }
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(12)
                    }
                } else {
                    #if canImport(LinkKit)
                    if let handler = networkManager.linkHandler {
                        PlaidLinkWrapper(handler: handler)
                    } else {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Theme.accent)
                            Text("Connecting to Plaid...")
                                .font(.headline)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .onAppear {
                            networkManager.fetchPlaidLinkToken { token in
                                if let token = token {
                                    networkManager.createPlaidHandler(token: token, onSuccess: { publicToken, _ in
                                        networkManager.exchangePublicToken(publicToken: publicToken) { success in
                                            if success {
                                                showPlaidLink = false
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    withAnimation { currentStep = .chooseBrands }
                                                }
                                            }
                                        }
                                    }, onExit: {
                                        showPlaidLink = false
                                    })
                                }
                            }
                        }
                    }
                    #else
                    Text("Plaid SDK Not Linked")
                    #endif
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct BankLogoView: View {
    let name: String
    let color: Color
    let offset: CGSize
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(name.prefix(1))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )
                .background(
                    Circle().stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
            
            Text(name)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Theme.textSecondary)
        }
        .offset(offset)
    }
}
