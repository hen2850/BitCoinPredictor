//
//  Prediction.swift
//  BitcoinPredictor
//
//  Created by Henry Van Laeren on 3/8/2025.
//

import Foundation
import SwiftData

@Model
class Prediction: Identifiable {
    var id = UUID()
    var date: Date
    var price: Double
    var prediction: Double
    var random: Double
    var predictionResult: Bool?
    var randomResult: Bool?
    
    init(id: UUID = UUID(), date: Date, price: Double, prediction: Double, random: Double, predictionResult: Bool? = nil, randomResult: Bool? = nil) {
        self.id = id
        self.date = date
        self.price = price
        self.prediction = prediction
        self.random = random
        self.predictionResult = predictionResult
        self.randomResult = randomResult
    }
    
}
