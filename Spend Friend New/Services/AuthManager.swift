import Foundation
import Combine
import LocalAuthentication
import AuthenticationServices
import SwiftUI

class AuthManager: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var isUnlocked: Bool = false
    @Published var currentUserIdentifier: String?
    
    static let shared = AuthManager()
    static var onUserAuthenticated: ((String) -> Void)?
    
    init() {
        // If not logged in at all, obviously not unlocked
        if !isLoggedIn {
            isUnlocked = false
        }
    }
    
    // MARK: - Biometrics (FaceID)
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        let reason = "Authenticate to unlock your Spend Friend profile."
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            // Device does not support biometrics (or not enrolled)
            // Fallback to pin or just let them in if they are already "logged in" for simplicity in this demo
            DispatchQueue.main.async {
                self.isUnlocked = true
                completion(true)
            }
        }
    }
    
    // MARK: - Apple Sign In
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                guard let identityTokenData = appleIDCredential.identityToken,
                      let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                    print("AuthManager: Failed to get identity token")
                    return
                }
                
                let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                verifyWithBackend(identityToken: identityToken, fullName: fullName, email: appleIDCredential.email)
            }
        case .failure(let error):
            print("Apple Sign In Error: \(error.localizedDescription)")
        }
    }
    
    private func verifyWithBackend(identityToken: String, fullName: String, email: String?) {
        let url = URL(string: "https://spendfriend-api.onrender.com/api/auth/apple")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "identityToken": identityToken,
            "fullName": fullName,
            "email": email as Any
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Backend Verification Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool, success {
                    
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                        self.isUnlocked = true
                        
                        if let userId = json["userId"] as? String {
                            // Link the authenticated ID to the network services
                            AuthManager.onUserAuthenticated?(userId)
                        }
                        print("Backend Verification Success")
                    }
                }
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Backend Verification Failed. Raw Response: \(responseString)")
                }
                print("Failed to parse backend response: \(error)")
            }
        }.resume()
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.isUnlocked = false
            self.hasCompletedOnboarding = false // Optional: Clear setup if you want fresh start on logout
        }
    }
}
