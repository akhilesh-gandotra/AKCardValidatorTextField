//
//  ViewController.swift
//  CardValidator
//
//  Created by soc-macmini-45 on 25/07/17.
//  Copyright © 2017 Akhilesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var expiryTextFiel: CardExpirationValidator!
    @IBOutlet weak var textField: AKCardValidatorTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use this callback to determine the result of the validation
        textField.validatorCallBack = { (result) in
            switch result {
            case .success(let card):
                print(card, card.maxLength, card.segmentGroupings)
            case .error(let error):
                print(error)
            }
        }
    }
    
    @IBAction func btnACtion(_ sender: Any) {
        print(expiryTextFiel.getYear(), expiryTextFiel.getMonth())
    }
}

