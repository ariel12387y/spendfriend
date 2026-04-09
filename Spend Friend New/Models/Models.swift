import Foundation

struct AlpacaAccount: Codable, Sendable {
    let id: String
    let status: String
    let currency: String
    let buyingPower: String
    let cash: String
    let portfolioValue: String
    let equity: String
    let longMarketValue: String
    let shortMarketValue: String
    let initialMargin: String
    let maintenanceMargin: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, status, currency, cash, equity
        case buyingPower = "buying_power"
        case portfolioValue = "portfolio_value"
        case longMarketValue = "long_market_value"
        case shortMarketValue = "short_market_value"
        case initialMargin = "initial_margin"
        case maintenanceMargin = "maintenance_margin"
        case createdAt = "created_at"
    }
}

struct AlpacaPosition: Codable, Identifiable, Sendable {
    var id: String { symbol }
    let symbol: String
    let exchange: String
    let assetClass: String
    let qty: String
    let avgEntryPrice: String
    let side: String
    let marketValue: String
    let costBasis: String
    let unrealizedPl: String
    let unrealizedPlpc: String
    let currentPrice: String
    let lastdayPrice: String
    let changeToday: String
    
    enum CodingKeys: String, CodingKey {
        case symbol, exchange, qty, side
        case assetClass = "asset_class"
        case avgEntryPrice = "avg_entry_price"
        case marketValue = "market_value"
        case costBasis = "cost_basis"
        case unrealizedPl = "unrealized_pl"
        case unrealizedPlpc = "unrealized_plpc"
        case currentPrice = "current_price"
        case lastdayPrice = "lastday_price"
        case changeToday = "change_today"
    }
}

struct InvestmentHistoryItem: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    let brandName: String
    let stockTicker: String
    let purchaseAmount: Double
    let investedAmount: Double
    let status: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case userId = "user_id"
        case brandName = "merchant_name"
        case stockTicker = "stock_ticker"
        case purchaseAmount = "transaction_amount"
        case investedAmount = "investment_amount"
        case createdAt = "created_at"
    }
}
