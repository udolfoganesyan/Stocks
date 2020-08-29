//
//  OnboardingViewController.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 29.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    @IBOutlet private weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
    }
    
    private func setupButton() {
        doneButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true
    }
    
    @IBAction private func doneTouched(_ sender: UIButton) {
        let networkManager = IEXNetworkManager()
        let mainVC = MainViewController(financialNetworkManager: networkManager)
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        present(mainVC, animated: true, completion: nil)
    }
}
