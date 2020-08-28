//
//  ViewController.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 28.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

enum CompanyPickerViewComponents: Int, CaseIterable {
    case main
}

final class ViewController: UIViewController {
    
    @IBOutlet private weak var companyLogoImageView: UIImageView!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var companySymbolLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var priceChangeLabel: UILabel!
    @IBOutlet private weak var companyPickerView: UIPickerView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    
    private let financialNetworkManager: FinancialNetworkManager
    
    init(financialNetworkManager: FinancialNetworkManager) {
        self.financialNetworkManager = financialNetworkManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickerView()
        
        requestCompanyUpdate()
    }
    
    private func setupPickerView() {
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
    }
    
    private func requestCompanyUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        companySymbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        priceChangeLabel.textColor = .black
        
        let selectedRow = companyPickerView.selectedRow(inComponent: CompanyPickerViewComponents.main.rawValue)
        let selectedCompany = Array(companies.values)[selectedRow]
        financialNetworkManager.fetchInfo(for: selectedCompany) { (financialData) in
            if let financialData = financialData {
                self.displayStockInfo(for: financialData)
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
        financialNetworkManager.fetchLogo(for: selectedCompany) { (image) in
            if let image = image {
                self.companyLogoImageView.image = image
            }
        }
    }
    
    private func displayStockInfo(for data: FinancialData) {
        activityIndicator.stopAnimating()
        
        companyNameLabel.text = data.companyName
        companySymbolLabel.text = data.companyTicker
        priceLabel.text = "\(data.price)"
        priceChangeLabel.text = "\(data.priceChange)"
        if data.priceChange > 0 {
            priceChangeLabel.textColor = .green
        } else if data.priceChange < 0 {
            priceChangeLabel.textColor = .red
        } else {
            priceChangeLabel.textColor = .black
        }
    }
}

// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        companies.keys.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        requestCompanyUpdate()
    }
}
