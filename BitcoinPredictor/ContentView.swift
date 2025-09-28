//
//  ContentView.swift
//  BitcoinPredictor
//
//  Created by Henry Van Laeren on 27/7/2025.
//

import SwiftUI
import CoreML
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = CryptoViewModel()
    @State private var predictionValue: Double = 0.55
    @State private var barWidth: Double = 0
    @State private var random_guess = Double.random(in: 0...1)
    @State private var mostAccurateModel = ""
    @State private var preductionRunForDay = false
    @State private var refreshID = UUID()
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prediction.date, order: .reverse) var predictionstore: [Prediction]

    private enum Verdict {
        case strongBuy, slightBuy, even, slightSell, strongSell
        
        init(from value: Double) {
            let v = max(0, min(1, value))
            switch v {
            case ..<0.4: self = .strongSell
            case 0.4..<0.5: self = .slightSell
            case 0.5: self = .even
            case 0.5..<0.6: self = .slightBuy
            default: self = .strongBuy
            }
        }
        
        var label: String {
            switch self {
            case .strongBuy: return "Strong Buy"
            case .slightBuy: return "Slight Buy"
            case .even: return "Even"
            case .slightSell: return "Slight Sell"
            case .strongSell: return "Strong Sell"
            }
        }
        
        var color: Color {
            switch self {
            case .strongBuy, .slightBuy: return .green
            case .even: return .secondary
            case .slightSell, .strongSell: return .red
            }
        }
    }

    private var verdict: Verdict { Verdict(from: predictionValue) }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    private func accuracy(for keyPath: KeyPath<Prediction, Bool?>) -> (correct: Int, total: Int, ratio: Double) {
        let values = predictionstore.compactMap { $0[keyPath: keyPath] }
        let total = values.count
        let correct = values.filter { $0 }.count
        let ratio = total > 0 ? Double(correct) / Double(total) : 0
        return (correct, total, ratio)
    }

    private struct AccuracyBar: View {
        var title: String
        var correct: Int
        var total: Int
        var ratio: Double

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(.subheadline, weight: .regular))
                    Spacer()
                    Text("\(correct)/\(total) • \(Int((ratio * 100).rounded()))%")
                        .font(.system(.caption, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)
                        Capsule()
                            .fill(Color.accentColor)
                            .frame(width: max(0, min(1, ratio)) * geo.size.width, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Prediction")
                    .font(.system(.title2, weight: .regular))
                    .foregroundStyle(.primary)
                VStack(spacing: 4) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(maxWidth: .infinity, maxHeight: 10)
                            .readSize { size in
                                barWidth = size.width
                            }

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                            .offset(x: predictionValue * barWidth - 5)
                            Text("Sell")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .offset(x: barWidth * 0.4 - 10, y: 20)
                            Text("Even")
                                .font(.caption)
                                .offset(x: barWidth * 0.5 - 10, y: 20)
                            Text("Buy")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .offset(x: barWidth * 0.6 - 10, y: 20)
                    }
                }
                .padding(.bottom, 30)
                HStack(spacing:4) {
                    let Value1DP = String(format: "%.2f", predictionValue)
                    Text(Value1DP)
                    Spacer()
                    let random1DP = String(format: "%.2f", random_guess)
                    Text("Random guess: \(random1DP)")
                        .font(.system(.caption, weight: .medium))

                }
                .font(.system(.footnote, weight: .medium))
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Verdict: \(verdict.label)")
                        .foregroundStyle(verdict.color)
                    Spacer()
                    Text(currentDate)
                        .foregroundStyle(.secondary)
                }
                .font(.system(.caption, weight: .medium))
                
            }
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(12)
            
            VStack(spacing: 10) {
                HStack {
                    Text("History")
                        .font(.system(.subheadline, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text("Current preduction rate")
                            .font(.system(.headline, weight: .regular))
                        Spacer()
                    }
                    
                    let modelAcc = accuracy(for: \.predictionResult)
                    let randomAcc = accuracy(for: \.randomResult)

                    VStack(spacing: 12) {
                        AccuracyBar(title: "Prediction model", correct: modelAcc.correct, total: modelAcc.total, ratio: modelAcc.ratio)
                        AccuracyBar(title: "Random guess", correct: randomAcc.correct, total: randomAcc.total, ratio: randomAcc.ratio)
                        let mostAccurateModel = (modelAcc.ratio == randomAcc.ratio)
                        ? "Both models are equally accurate"
                        : (modelAcc.ratio > randomAcc.ratio ? "Prediction model" : "Random guess")
                        Text("Most accurate: \(mostAccurateModel)")
                            .font(.system(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(.background)
                List {
                    ForEach(predictionstore) { prediction in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(prediction.date, format: .dateTime
                                    .month(.abbreviated)
                                    .day()
                                    .year()
                                )

                                Spacer()
                                Text(prediction.price, format: .currency(code: "USD"))
                            }
                            .font(.system(.caption, weight: .medium))
                            Text("Prediction Model")
                                .font(.system(.callout, weight: .medium))
                            HStack {
                                Text(prediction.prediction.formatted(.number.precision(.fractionLength(2))))
                                Spacer()
                                Text(
                                    prediction.predictionResult == true ? "✅ Correct"
                                    : prediction.predictionResult == false ? "❌ Wrong"
                                    : "—"
                                )
                            }
                            .font(.system(.caption, weight: .medium))
                            Text("Random Guess")
                            HStack {
                                Text(prediction.random.formatted(.number.precision(.fractionLength(2))))
                                Spacer()
                                Text(
                                    prediction.randomResult == true ? "✅ Correct"
                                    : prediction.randomResult == false ? "❌ Wrong"
                                    : "—"
                                )
                            }
                            .font(.system(.caption, weight: .medium))
                        }
                    }
                        
                }
            }
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(12)
            Button("Run Prediction") {
                guard let data = viewModel.marketData else {
                    print("No Data Avilable")
                    return
                }
                
                let previousPrediction = predictionstore.first
                
                if let last = previousPrediction,
                   Calendar.current.isDate(last.date, inSameDayAs: .now) {
                    print("Same day, please wait")
                    preductionRunForDay = true
                    return
                }
                
                let price = data.current_price.usd
                let volume = data.total_volume.btc
                let changeInVsYesterday = data.price_change_percentage_24h/100
                let changeIn7Days = data.price_change_percentage_7d/100
                let ATH = data.ath.usd
                let comparisonResult = ATH == price
                let isATH: Int = comparisonResult ? 1 : 0
                let daysInRowGrowth = changeIn7Days > 0 ? 1 : -1
                let calendar = Calendar.current
                
                
                
                if let old = previousPrediction,
                    !Calendar.current.isDate(old.date, inSameDayAs: Date.now) {
                        let predCheck = predictionResults(currentPrice: price, predictionPrice: old.price, predictionValue: old.prediction)
                        
                        let randCheck = randomResults(currentPrice: price, predictionPrice: old.price, randomPrediction: old.random)
                        
                        old.predictionResult = predCheck
                        old.randomResult = randCheck
                        
                    }

                // 1) Define Excel's epoch: 1899-12-31
                let excelEpoch = calendar.date(
                    from: DateComponents(year: 1899, month: 12, day: 31)
                )!

                // 2) Snap both dates to midnight so you only count whole days
                let todayMidnight = calendar.startOfDay(for: Date())

                // 3) Compute the difference in days
                let excelSerial = calendar.dateComponents(
                    [.day], from: excelEpoch, to: todayMidnight ).day!
                prediction(date: excelSerial, price: price, volume: volume, changeInVsYesterday: changeInVsYesterday, isATH: isATH, last_7_days_growth: changeIn7Days)
                
                // Persist the new prediction to SwiftData
                let newPrediction = Prediction(date: Date(),
                                               price: price,
                                               prediction: predictionValue,
                                               random: random_guess)
                modelContext.insert(newPrediction)
                try? modelContext.save()
                
                print("date: \(excelSerial), price: \(price), volume: \(volume), changeInVsYesterday: \(changeInVsYesterday), changeIn7Days: \(changeIn7Days), ATH: \(ATH), isATH: \(isATH), daysInRowGrowth: \(daysInRowGrowth)")
                
            }
            .buttonStyle(.borderedProminent)
    }
       .padding()
            .task {
            await viewModel.fetchData()
      }
            .alert("Already Run", isPresented: $preductionRunForDay) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("Prediction Has Already Been Run For Today")
    }
            .refreshable {
                refreshID = UUID()
            }
    }
    
    func prediction(date: Int, price: Double, volume: Double, changeInVsYesterday: Double, isATH: Int, last_7_days_growth: Double) {
        do {
            let config = MLModelConfiguration()
            let model = try Bitcoinprediction_7day_version(configuration: config)
            
            let prediction = try model.prediction(Date: Int64(date), Price: price, Volume: volume, __change_in_vs_yesterday: changeInVsYesterday, Is_ATH: Int64(isATH), Last_7_days_growth: last_7_days_growth)
            
            print(prediction.Prediction)
            predictionValue = prediction.Prediction
            
        } catch {
            print("Error: \(error)")
        }
    }
    

    func predictionResults(currentPrice: Double, predictionPrice: Double, predictionValue: Double) -> Bool {
        
        let priceIncreased: Bool = currentPrice > predictionPrice
        
        if predictionValue > 0.5 && priceIncreased {
            return true
        }
        if predictionValue < 0.5 && !priceIncreased {
            return true
        } else {
            return false
        }
        
    }
    
    func randomResults(currentPrice: Double, predictionPrice: Double, randomPrediction: Double) -> Bool  {
        let priceIncreased: Bool = currentPrice > predictionPrice
        
        if randomPrediction > 0.5 && priceIncreased {
            return true
        }
        if randomPrediction < 0.5 && !priceIncreased {
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    ContentView()
}
