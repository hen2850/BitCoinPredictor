//
//  APIData.swift
//  BitcoinPredictor
//
//  Created by Henry Van Laeren on 27/7/2025.
//

import Foundation

struct Result: Codable {
    let market_data: Market_Data
}

struct Market_Data: Codable {
    let current_price: MarketPrice
    let ath: Ath
    let price_change_percentage_24h: Double
    let total_volume: Volume
    let price_change_percentage_7d: Double
}

struct MarketPrice: Codable {
    let usd: Double
}

struct Ath: Codable {
    let usd: Double
}

struct Volume: Codable {
    let btc: Double
}
