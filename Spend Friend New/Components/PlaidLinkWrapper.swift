import SwiftUI

#if canImport(LinkKit)
import LinkKit

struct PlaidLinkWrapper: UIViewControllerRepresentable {
    let handler: Handler
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            handler.open(presentUsing: .viewController(vc))
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#else
struct PlaidLinkWrapper: View {
    let linkToken: String
    let onSuccess: (String, String) -> Void
    let onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text("Plaid SDK Not Found")
                .font(.headline)
            Text("Please add 'https://github.com/plaid/plaid-link-ios' to your project via Swift Package Manager.")
                .multilineTextAlignment(.center)
                .padding()
            Button("Dismiss") { onExit() }
        }
        .preferredColorScheme(.dark)
    }
}
#endif
