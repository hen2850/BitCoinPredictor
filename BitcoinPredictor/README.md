# Bitcoin Price ML – Learning Project

A hands-on learning project that demonstrates how to build, train, and integrate a Core ML model to forecast Bitcoin price movement using approximately the last 5 years of historical price data. The app fetches recent market data from the CoinGecko API, prepares features, runs an on-device Core ML model, and visualizes predictions for educational purposes.

> Disclaimer: This project is for learning and experimentation only. It is not financial advice. Do not use it for real trading or investment decisions. It is just a bit of fun

## What You’ll Learn

- Fetching and preparing time-series crypto market data
- Building a simple forecasting pipeline and exporting to Core ML
- Integrating a `.mlmodel` into an iOS app and making on-device predictions
- Basic evaluation and visualization of model outputs

## Features

- Pulls the latest Bitcoin price data from CoinGecko
- Preprocesses data (e.g., resampling, normalization, simple technical features)
- Runs an on-device Core ML model for short-horizon forecasting
- Displays recent history and the model’s next-step prediction

## Architecture Overview

- Data Source: CoinGecko API (daily/hourly price history endpoints)
- Preprocessing: Lightweight feature engineering (e.g., log returns, moving averages)
- Model: A small Core ML model designed for time-series (e.g., a simple regressor or sequence model)
- App: Swift / SwiftUI client that fetches data, prepares the input window, and queries the Core ML model

High-level flow:

1. Fetch recent BTC-USD price history from the API
2. Prepare a sliding window of features from the last N data points
3. Run the Core ML model to predict the next step (e.g., next close or delta)
4. Render the result alongside the recent historical series

## Requirements

- Xcode 15 or later
- iOS 17 or later (target can be adjusted)
- A CoinGecko API key

## Getting a CoinGecko API Key

1. Visit: https://www.coingecko.com/en/api
2. Create an account and subscribe to a plan that fits your needs
3. Generate an API key from your dashboard
4. Copy the key (you’ll add it to the app configuration below)

Note: Some CoinGecko endpoints require the `x-cg-pro-api-key` header. Check your plan’s documentation to determine which endpoints you can access and any rate limits.

## Configuration

Because projects store secrets differently, here are a few common approaches. Use whichever matches how your app is wired up:

- Run scheme environment variable (easy for development):
  - In Xcode: Product → Scheme → Edit Scheme… → Run → Arguments → Environment Variables
  - Add key: `COINGECKO_API_KEY` with your API key as the value
- `.xcconfig` (preferred for local dev):
  - Create a `Secrets.xcconfig` file (not committed to source control) with:
