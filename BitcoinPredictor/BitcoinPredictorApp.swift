//
//  BitcoinPredictorApp.swift
//  BitcoinPredictor
//
//  Created by Henry Van Laeren on 27/7/2025.
//

import SwiftUI
import SwiftData

@main
struct BitcoinPredictorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Prediction.self)
        }
    }
}
