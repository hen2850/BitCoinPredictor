//
//  GetCryptoInfo.swift
//  BitcoinPredictor
//
//  Created by Henry Van Laeren on 27/7/2025.
//

import Foundation
import SwiftUI

final class CryptoViewModel: ObservableObject {
    @Published var marketData: Market_Data?
    
    private let key = "XX"
    
    @MainActor
    func fetchData() async {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "x-cg-pro-api-key": key
        ]
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode(Result.self, from: data)
            print("Successfull fetched crypto data and decoded it")
            self.marketData = result.market_data        // publish so the view updates
        } catch {
            print("🔴 CryptoViewModel.fetchData error:", error)
        }
    }
}
