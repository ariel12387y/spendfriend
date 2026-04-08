import SwiftUI
import Combine

#if canImport(LinkKit)
import LinkKit
// Create a wrapper for Plaid Link
struct PlaidLinkWrapper: UIViewControllerRepresentable {
    let linkToken: String
    let onSuccess: (String, String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let configuration = LinkTokenConfiguration(token: linkToken) { success in
            onSuccess(success.publicToken, success.metadata.institution.id)
        }
        let result = Plaid.create(configuration)
        switch result {
        case .failure(let error):
            print("Plaid Link Error: \(error)")
            return UIViewController()
        case .success(let handler):
            let vc = UIViewController()
            // Present from the VC after a slight delay
            DispatchQueue.main.async {
                handler.open(presentUsing: .viewController(vc))
            }
            return vc
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    let baseURL = "https://spendfriend-api.onrender.com/api"
    
    @Published var plaidLinkToken: String?
    @Published var errorMessage: String?
    
    func fetchPlaidLinkToken() {
        guard let url = URL(string: "\(baseURL)/plaid/create_link_token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["userId": "mock_user_123"]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = "Network error: \(error.localizedDescription)" }
                return
            }
            
            guard let data = data else { 
                DispatchQueue.main.async { self.errorMessage = "No data from backend" }
                return 
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Backend Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let bodyString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Error Body: \(bodyString)")
                    DispatchQueue.main.async { self.errorMessage = "Backend error (\(httpResponse.statusCode))" }
                    return
                }
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let linkToken = json["link_token"] as? String {
                    DispatchQueue.main.async { 
                        self.plaidLinkToken = linkToken
                        self.errorMessage = nil
                    }
                } else {
                    DispatchQueue.main.async { self.errorMessage = "Response missing link_token" }
                }
            } catch {
                let bodyPreview = String(data: data.prefix(100), encoding: .utf8) ?? ""
                print("Failed to parse JSON. Body starts with: \(bodyPreview)")
                DispatchQueue.main.async { self.errorMessage = "Invalid JSON (Check if Render is serving HTML)" }
            }
        }.resume()
    }
    
    func exchangePublicToken(publicToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/plaid/set_access_token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["public_token": publicToken, "userId": "mock_user_123"]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { 
                    self.errorMessage = "Failed to exchange Plaid token"
                    completion(false) 
                }
            }
        }.resume()
    }
    
    func connectAlpaca(key: String, secret: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/alpaca/connect") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [
            "userId": "mock_user_123",
            "alpacaKey": key,
            "alpacaSecret": secret
        ]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { 
                    self.errorMessage = "Alpaca connection failed: \(error.localizedDescription)"
                    completion(false) 
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async { 
                    self.errorMessage = "Invalid Alpaca keys or backend error"
                    completion(false) 
                }
                return
            }
            
            DispatchQueue.main.async { completion(true) }
        }.resume()
    }
}

// MARK: - App Views
struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            if isAuthenticated {
                DashboardView(isAuthenticated: $isAuthenticated)
            } else {
                OnboardingView(isAuthenticated: $isAuthenticated)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Spend Friend")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("Invest automatically when you spend at your favorite places.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)
            
            Spacer().frame(height: 50)
            
            Button(action: {
                withAnimation { isAuthenticated = true }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.orange, .purple], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .shadow(color: .orange.opacity(0.4), radius: 10)
        }
        .padding()
        .liquidGlass()
        .padding(30)
    }
}

struct DashboardView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var networkManager = NetworkManager()
    
    @State private var showAlpacaSheet = false
    @State private var alpacaKey = ""
    @State private var alpacaSecret = ""
    @State private var isAlpacaConnected = false
    @State private var isPlaidConnected = false
    
    @State private var isFetchingToken = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Dashboard")
                    .font(.largeTitle.bold())
                Spacer()
                Button("Log Out") {
                    withAnimation { isAuthenticated = false }
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            
            if let error = networkManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Connections Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Connections").font(.headline)
                        
                        HStack {
                            Image(systemName: "building.columns")
                            Text(isPlaidConnected ? "Plaid: Connected" : "Plaid: Not Connected")
                            Spacer()
                            if !isPlaidConnected {
                                if isFetchingToken {
                                    ProgressView().tint(.white)
                                } else {
                                    Button("Connect") {
                                        isFetchingToken = true
                                        networkManager.fetchPlaidLinkToken()
                                    }
                                }
                            } else {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text(isAlpacaConnected ? "Alpaca: Connected" : "Alpaca: Not Connected")
                            Spacer()
                            if !isAlpacaConnected {
                                Button("Connect") { showAlpacaSheet = true }
                            } else {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            }
                        }
                    }
                    .liquidGlass()
                    
                    // Rules Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("My Rules").font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Starbucks").font(.system(size: 18, weight: .semibold))
                                Text("Invest $5.00 on purchase").font(.subheadline).foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Toggle("", isOn: .constant(true)).labelsHidden()
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add New Rule")
                            }
                            .foregroundColor(.orange)
                        }
                        .padding(.top, 10)
                    }
                    .liquidGlass()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAlpacaSheet) {
            Form {
                Section(header: Text("Alpaca Broker API")) {
                    TextField("API Key ID", text: $alpacaKey)
                    SecureField("Secret Key", text: $alpacaSecret)
                }
                Button("Connect Account") {
                    networkManager.connectAlpaca(key: alpacaKey, secret: alpacaSecret) { success in
                        if success {
                            isAlpacaConnected = true
                            showAlpacaSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { networkManager.plaidLinkToken != nil },
            set: { _ in networkManager.plaidLinkToken = nil }
        )) {
            #if canImport(LinkKit)
            if let token = networkManager.plaidLinkToken {
                PlaidLinkWrapper(linkToken: token) { publicToken, institutionId in
                    isFetchingToken = false
                    networkManager.exchangePublicToken(publicToken: publicToken) { success in
                        isPlaidConnected = success
                    }
                }
            }
            #else
            VStack {
                Text("Plaid LinkKit Missing")
                Text("Please install Plaid SDK via Swift Package Manager.")
            }
            #endif
        }
    }
}

#Preview {
    ContentView()
}

