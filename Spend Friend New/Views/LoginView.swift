import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @State private var animateCircles = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // Background Liquid Effect
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: animateCircles ? 100 : -100, y: animateCircles ? -100 : 100)
                
                Circle()
                    .fill(Theme.accent.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: animateCircles ? -150 : 150, y: animateCircles ? 150 : -150)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    animateCircles.toggle()
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 16) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.accent)
                        .shadow(color: Theme.accent.opacity(0.5), radius: 20)
                    
                    Text("Spend Friend")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Automate your wealth.")
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                // Login Options
                VStack(spacing: 20) {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            authManager.handleAppleSignIn(result: result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .cornerRadius(16)
                    .padding(.horizontal, 30)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    
                    if authManager.isLoggedIn {
                        Button(action: {
                            authManager.authenticateWithBiometrics { _ in }
                        }) {
                            HStack {
                                Image(systemName: "faceid")
                                Text("Unlock with FaceID")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 30)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    LoginView(authManager: AuthManager.shared)
}
