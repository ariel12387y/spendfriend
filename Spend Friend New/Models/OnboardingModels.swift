import SwiftUI

struct Brand: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let logoName: String
    var isEnabled: Bool = false
    var investmentAmount: Double = 5.0
    
    static let allBrands: [Brand] = [
        Brand(name: "Apple", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-11"),
        Brand(name: "Amazon", logoName: "ChatGPT Image Mar 4, 2026 at 11_12_29 AM-2"),
        Brand(name: "Chipotle", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-10"),
        Brand(name: "Costco", logoName: "ChatGPT Image Mar 4, 2026 at 11_13_38 AM-2"),
        Brand(name: "Google", logoName: "ChatGPT Image Mar 4, 2026 at 11_15_56 AM-2"),
        Brand(name: "Home Depot", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-2"),
        Brand(name: "Lowe's", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-3"),
        Brand(name: "McDonald's", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-4"),
        Brand(name: "Microsoft", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-5"),
        Brand(name: "Netflix", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-6"),
        Brand(name: "Nvidia", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-7"),
        Brand(name: "Starbucks", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-8"),
        Brand(name: "Walmart", logoName: "ChatGPT Image Mar 4, 2026 at 11_20_49 AM-9"),
        // Additional brands can use generic placeholders or we can map more if available
    ]
}

enum OnboardingStep: Int, CaseIterable {
    case paywall = 0
    case howItWorks = 1
    case bankSecured = 2
    case chooseBrands = 3
    case amountConfig = 4
}
