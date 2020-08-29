//
//  FinancialData.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 28.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import Foundation

struct FinancialData {
    let companyName: String
    let companyTicker: String
    let price: Double
    let priceChange: Double
    
    init?(json: [String: Any]) {
        guard let companyName = json["companyName"] as? String,
            let companyTicker = json["symbol"] as? String,
            let price = json["latestPrice"] as? Double,
            let priceChange = json["change"] as? Double else {
                return nil
        }
        self.companyName = companyName
        self.companyTicker = companyTicker
        self.price = price
        self.priceChange = priceChange
    }
}
