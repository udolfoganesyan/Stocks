//
//  ViewController.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 28.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var companySymbolLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var priceChangeLabel: UILabel!
    @IBOutlet private weak var companyPickerView: UIPickerView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var companies = [
        "Apple": "AAPL"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
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
}
