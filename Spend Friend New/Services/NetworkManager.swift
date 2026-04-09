import Foundation
import Combine
#if canImport(LinkKit)
import LinkKit
#endif

class NetworkManager: ObservableObject {
    let baseURL = "https://spendfriend-api.onrender.com/api"
    
    // Auth & Connection State
    @Published var plaidLinkToken: String?
    @Published var errorMessage: String?
    @Published var isPlaidConnected = false
    @Published var isAlpacaConnected = false
    
    // Retained Plaid Link Handler
    #if canImport(LinkKit)
    var linkHandler: Handler?
    #endif
    
    // Live Dashboard Data
    @Published var account: AlpacaAccount?
    @Published var positions: [AlpacaPosition] = []
    @Published var history: [InvestmentHistoryItem] = []
    
    // Loading States
    @Published var isLoading = false
    
    // The Active User ID (set after Apple Login)
    private var userId: String = "mock_user_123"
    
    func setUserId(_ id: String) {
        self.userId = id
        print("NetworkManager: Active User ID set to \(id)")
    }
    
    func fetchAllData() {
        guard !isLoading else { return }
        isLoading = true
        
        // Fetch all live data in parallel
        let group = DispatchGroup()
        
        group.enter()
        fetchAccount { group.leave() }
        
        group.enter()
        fetchPositions { group.leave() }
        
        group.enter()
        fetchHistory { group.leave() }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func fetchAccount(completion: @escaping () -> Void) {
        Task {
            guard let url = URL(string: "\(baseURL)/alpaca/account?userId=\(userId)") else { completion(); return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let account = try JSONDecoder().decode(AlpacaAccount.self, from: data)
                
                await MainActor.run {
                    self.account = account
                    self.isAlpacaConnected = true
                }
            } catch {
                print("Failed to fetch account: \(error)")
            }
            completion()
        }
    }
    
    private func fetchPositions(completion: @escaping () -> Void) {
        Task {
            guard let url = URL(string: "\(baseURL)/alpaca/positions?userId=\(userId)") else { completion(); return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let positions = try JSONDecoder().decode([AlpacaPosition].self, from: data)
                
                await MainActor.run {
                    self.positions = positions
                }
            } catch {
                print("Failed to fetch positions: \(error)")
            }
            completion()
        }
    }
    
    private func fetchHistory(completion: @escaping () -> Void) {
        Task {
            guard let url = URL(string: "\(baseURL)/plaid/history?userId=\(userId)") else { completion(); return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let history = try decoder.decode([InvestmentHistoryItem].self, from: data)
                
                await MainActor.run {
                    self.history = history
                }
            } catch {
                print("Failed to fetch history: \(error)")
            }
            completion()
        }
    }
    
    // Plaid Token Logic
    func fetchPlaidLinkToken(completion: @escaping (String?) -> Void = { _ in }) {
        print("NetworkManager: Fetching Plaid Link Token...")
        self.errorMessage = nil
        self.plaidLinkToken = nil
        
        guard let url = URL(string: "\(baseURL)/plaid/create_link_token") else { 
            self.errorMessage = "Invalid URL"
            completion(nil)
            return 
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["userId": userId])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("NetworkManager Error: \(error.localizedDescription)")
                DispatchQueue.main.async { 
                    self.errorMessage = "Network error: \(error.localizedDescription)" 
                    completion(nil)
                }
                return
            }
            
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode != 200 {
                print("NetworkManager Backend Error: Status \(httpRes.statusCode)")
                DispatchQueue.main.async { 
                    self.errorMessage = "Backend Error: Status \(httpRes.statusCode)" 
                    completion(nil)
                }
                return
            }
            
            guard let data = data else { 
                print("NetworkManager: No data received")
                completion(nil)
                return 
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let linkToken = json["link_token"] as? String {
                    print("NetworkManager: Received Link Token successfully")
                    DispatchQueue.main.async { 
                        self.plaidLinkToken = linkToken 
                        completion(linkToken)
                    }
                } else {
                    print("NetworkManager: JSON format mismatch")
                    DispatchQueue.main.async { 
                        self.errorMessage = "Failed to parse token" 
                        completion(nil)
                    }
                }
            } catch {
                print("NetworkManager: JSON Decode Error: \(error)")
                DispatchQueue.main.async { 
                    self.errorMessage = "Invalid response from server" 
                    completion(nil)
                }
            }
        }.resume()
    }
    
    #if canImport(LinkKit)
    func createPlaidHandler(token: String, onSuccess: @escaping (String, String) -> Void, onExit: @escaping () -> Void) {
        let configuration = LinkTokenConfiguration(token: token) { success in
            onSuccess(success.publicToken, success.metadata.institution.id)
        }
        
        let result = Plaid.create(configuration)
        switch result {
        case .failure(let error):
            print("Plaid Link Creation Error: \(error)")
            self.errorMessage = "Plaid creation failed: \(error.localizedDescription)"
        case .success(let handler):
            self.linkHandler = handler
        }
    }
    #endif
    
    func exchangePublicToken(publicToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/plaid/set_access_token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["public_token": publicToken, "userId": userId])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.isPlaidConnected = true
                    completion(true)
                } else {
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
        request.httpBody = try? JSONEncoder().encode([
            "userId": userId,
            "alpacaKey": key,
            "alpacaSecret": secret
        ])
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 {
                    self.isAlpacaConnected = true
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
