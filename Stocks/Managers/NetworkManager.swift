//
//  NetworkManager.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 28.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

protocol FinancialNetworkManager {
    func fetchCompanies(completion: @escaping (_ companies: [String: String]?) -> Void)
    func fetchInfo(for company: String, completion: @escaping (_ data: FinancialData?) -> Void)
    func fetchLogo(for company: String, completion: @escaping (_ logo: UIImage?) -> Void)
}

struct IEXNetworkManager: FinancialNetworkManager {
    
    static let token = "pk_d7808609ee3f419297f9afe4f0a4bf8e"
    
    func fetchCompanies(completion: @escaping (_ companies: [String: String]?) -> Void) {
        guard  let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/list/iexpercent?token=\(IEXNetworkManager.token)") else {
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    error == nil {
                    let companies = self.parseCompaniesNames(from: data)
                    completion(companies)
                } else {
                    completion(nil)
                    return
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func parseCompaniesNames(from data: Data) -> [String: String]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let companiesJson = jsonObject as? [[String: Any]] else {
                    return nil
            }
            
            var companies = [String: String]()
            
            for company in companiesJson {
                guard let companyName = company["companyName"] as? String,
                    let symbol = company["symbol"] as? String else {
                        continue
                }
                companies[companyName] = symbol
            }
            
            return companies
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
            return nil
        }
    }
    
    func fetchInfo(for company: String, completion: @escaping (_ data: FinancialData?) -> Void) {
        guard  let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(company)/quote?token=\(IEXNetworkManager.token)") else {
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    error == nil {
                    let financialData = self.parseInfo(from: data)
                    completion(financialData)
                } else {
                    completion(nil)
                    return
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func parseInfo(from data: Data) -> FinancialData? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companyTicker = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else {
                    return nil
            }
            
            let financialData = FinancialData(companyName: companyName, companyTicker: companyTicker, price: price, priceChange: priceChange)
            return financialData
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
            return nil
        }
    }
    
    func fetchLogo(for company: String, completion: @escaping (_ logo: UIImage?) -> Void) {
        guard  let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(company)/logo?token=\(IEXNetworkManager.token)") else {
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data,
                    (response as? HTTPURLResponse)?.statusCode == 200,
                    error == nil {
                    let image = self.getImage(from: data)
                    completion(image)
                } else {
                    completion(nil)
                    return
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func getImage(from data: Data) -> UIImage? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String: Any],
                let urlString = json["url"] as? String,
                let url = URL(string: urlString)else {
                    return nil
            }
            
            if let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            } else {
                return nil
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
            return nil
        }
    }
}
