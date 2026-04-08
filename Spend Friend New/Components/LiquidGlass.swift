import SwiftUI

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient(colors: [.white.opacity(0.5), .clear, .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}

struct LiquidBackground: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(red: 8/255, green: 8/255, blue: 8/255).ignoresSafeArea() // #080808 Deep dark
            
            // Orbs for liquid glass effect
            Circle()
                .fill(Color.orange.opacity(0.6))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: isAnimating ? 100 : -100, y: isAnimating ? -150 : 150)
            
            Circle()
                .fill(Color.purple.opacity(0.6))
                .blur(radius: 100)
                .frame(width: 300, height: 300)
                .offset(x: isAnimating ? -100 : 100, y: isAnimating ? 150 : -150)
            
            Circle()
                .fill(Color.blue.opacity(0.5))
                .blur(radius: 120)
                .frame(width: 400, height: 400)
                .offset(x: 0, y: isAnimating ? 200 : -200)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
