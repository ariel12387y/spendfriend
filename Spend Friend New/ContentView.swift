import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        Group {
            if !authManager.isLoggedIn || !authManager.isUnlocked {
                LoginView(authManager: authManager)
            } else if !authManager.hasCompletedOnboarding {
                OnboardingView(networkManager: networkManager, authManager: authManager)
            } else {
                MainAppView(networkManager: networkManager, authManager: authManager, selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Set up the bridge between Auth and Network services
            AuthManager.onUserAuthenticated = { userId in
                networkManager.setUserId(userId)
            }
            
            if authManager.isLoggedIn && !authManager.isUnlocked {
                authManager.authenticateWithBiometrics { _ in }
            }
        }
    }
}

struct MainAppView: View {
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var authManager: AuthManager
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            HStack {
                Text(selectedTab.title)
                    .font(.largeTitle.bold())
                Spacer()
                Button(action: { /* Profile Action */ }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Main Content
            ZStack {
                switch selectedTab {
                case .dashboard:
                    DashboardView(networkManager: networkManager)
                case .portfolio:
                    PortfolioView(networkManager: networkManager)
                case .transactions:
                    HistoryTabView(networkManager: networkManager)
                        .padding(20)
                case .settings:
                    SettingsView(networkManager: networkManager, authManager: authManager)
                }
            }
            
            // Floating Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .onAppear {
            networkManager.fetchAllData()
        }
    }
}

struct SettingsView: View {
    @ObservedObject var networkManager: NetworkManager
    @ObservedObject var authManager: AuthManager
    @State private var showAlpacaSheet = false
    @State private var alpacaKey = ""
    @State private var alpacaSecret = ""
    @State private var showPlaidLink = false
    
    var body: some View {
        List {
            Section("Connections") {
                Button(action: { showPlaidLink = true }) {
                    HStack {
                        Label("Plaid Banking", systemImage: "building.columns.fill")
                        Spacer()
                        if networkManager.isPlaidConnected {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.success)
                        } else {
                            Text("Connect").foregroundColor(Theme.accent)
                        }
                    }
                }
                
                Button(action: { showAlpacaSheet = true }) {
                    HStack {
                        Label("Alpaca Broker", systemImage: "bolt.fill")
                        Spacer()
                        if networkManager.isAlpacaConnected {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.success)
                        } else {
                            Text("Connect").foregroundColor(Theme.accent)
                        }
                    }
                }
            }
            
            Section("Account") {
                Button("Log Out") {
                    authManager.logout()
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(.insetGrouped)
        .sheet(isPresented: $showAlpacaSheet) {
            Form {
                Section(header: Text("Alpaca Broker API (Paper)")) {
                    TextField("API Key ID", text: $alpacaKey)
                    SecureField("Secret Key", text: $alpacaSecret)
                }
                Button("Connect Account") {
                    networkManager.connectAlpaca(key: alpacaKey, secret: alpacaSecret) { success in
                        if success { showAlpacaSheet = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showPlaidLink) {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                #if canImport(LinkKit)
                if let handler = networkManager.linkHandler {
                    PlaidLinkWrapper(handler: handler)
                } else {
                    VStack {
                        ProgressView()
                        Text("Fetching Link Token...")
                    }
                    .onAppear {
                        networkManager.fetchPlaidLinkToken { token in
                            if let token = token {
                                networkManager.createPlaidHandler(token: token, onSuccess: { publicToken, _ in
                                    networkManager.exchangePublicToken(publicToken: publicToken) { success in
                                        showPlaidLink = false
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
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}
