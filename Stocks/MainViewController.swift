//
//  ViewController.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 28.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit
import Network

enum CompanyPickerViewComponents: Int, CaseIterable {
    case main
}

final class MainViewController: UIViewController {
    
    @IBOutlet private weak var companyLogoImageView: UIImageView!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var companySymbolLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var priceChangeLabel: UILabel!
    @IBOutlet private weak var companyPickerView: UIPickerView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let connectivityMonitor = NWPathMonitor()
    
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
        setupConnectivityMonitor()
    }
    
    private func setupPickerView() {
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
    }
    
    private func setupConnectivityMonitor() {
        connectivityMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .unsatisfied {
                    self.showErrorOkAlert("No internet connection")
                } else {
                    self.getCompaniesList()
                }
            }
        }
        let queue = DispatchQueue(label: "connectivityMonitor")
        connectivityMonitor.start(queue: queue)
    }
    
    private func getCompaniesList() {
        activityIndicator.startAnimating()
        financialNetworkManager.fetchCompanies { (companies) in
            if let companies = companies {
                if !companies.isEmpty {
                    self.companies = companies
                    self.companyPickerView.reloadAllComponents()
                }
                self.requestCompanyUpdate()
            } else {
                self.activityIndicator.stopAnimating()
                self.showErrorOkAlert("Seems like we could not fetch companies list:(")
            }
        }
    }
    
    private func requestCompanyUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        companySymbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        priceChangeLabel.textColor = .label
        
        let selectedRow = companyPickerView.selectedRow(inComponent: CompanyPickerViewComponents.main.rawValue)
        let selectedCompany = Array(companies.values)[selectedRow]
        
        financialNetworkManager.fetchInfo(for: selectedCompany) { (financialData) in
            if let financialData = financialData {
                self.displayStockInfo(for: financialData)
            } else {
                self.activityIndicator.stopAnimating()
                self.showErrorOkAlert("Oops, something went wrong during info fetching:(")
            }
        }
        
        financialNetworkManager.fetchLogo(for: selectedCompany) { (image) in
            if let image = image {
                self.companyLogoImageView.image = image
//                self.view.backgroundColor = image.averageColor
            } else {
                self.showErrorOkAlert("Something went wrong during logo fetching:(")
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

extension MainViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        companies.keys.count
    }
}

// MARK: - UIPickerViewDelegate

extension MainViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        requestCompanyUpdate()
    }
}
