//
//  CardValidator.swift
//  CardValidator
//
//  Created by Akhilesh Gandotra on 25/07/17.
//  Copyright © 2017 Akhilesh. All rights reserved.
//

import Foundation
import UIKit

enum CardResult {
    case success(CardType)
    case error(String)
}

extension String {
    
    func containsOnlyDigits() -> Bool  {
        
        let notDigits = NSCharacterSet.decimalDigits.inverted
        
        if rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil {
            return true
        }
        return false
    }
}

class CardValidatorTextField : UITextField {
    
    //MARK: Properties
    public var validatorCallBack: ((CardResult) -> Void)?
    private var cardNumberString = ""
    private var isAmex = false
    
    //MARK: Starting View
    override func awakeFromNib() {
        self.giveLeftImageView(image: #imageLiteral(resourceName: "chip"))
        self.addTarget(self, action: #selector(self.reformatAsCardNumber(_:)), for: UIControlEvents.editingChanged)
    }
    
    //MARk: Added Selector
    @objc private func reformatAsCardNumber(_ sender: UITextField) {
        self.formatToCreditCardNumber(isAmex: isAmex, withPreviousTextContent: self.text, andPreviousCursorPosition: self.selectedTextRange)
    }
    
    //MARK: Formatting Function and logic
    private func formatToCreditCardNumber(isAmex: Bool, withPreviousTextContent previousTextContent : String?, andPreviousCursorPosition previousCursorSelection : UITextRange?) {
        
        var selectedRangeStart = self.endOfDocument
        if self.selectedTextRange?.start != nil {
            selectedRangeStart = (self.selectedTextRange?.start)!
        }
        if  let textFieldText = self.text {
            var targetCursorPosition : UInt = UInt(self.offset(from:self.beginningOfDocument, to: selectedRangeStart))
            let cardNumberWithoutSpaces : String = removeNonDigitsFromString(string: textFieldText, andPreserveCursorPosition: &targetCursorPosition)
            if cardNumberWithoutSpaces.characters.count > 19  { // card number with spaces
                self.text = previousTextContent
                self.selectedTextRange = previousCursorSelection
                return
            }
            var cardNumberWithSpaces = ""
            if isAmex {
                cardNumberWithSpaces = insertSpacesInAmexFormat(string: cardNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
            } else {
                cardNumberWithSpaces = insertSpacesIntoEvery4DigitsIntoString(string: cardNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
            }
            self.text = cardNumberWithSpaces
            if let finalCursorPosition = self.position(from:self.beginningOfDocument, offset: Int(targetCursorPosition)) {
                self.selectedTextRange = self.textRange(from: finalCursorPosition, to: finalCursorPosition)
            }
            self.cardNumberString = removeNonDigitsFromString(string: self.text!, andPreserveCursorPosition: &targetCursorPosition)
            
            switch CardState(fromPrefix: removeNonDigitsFromString(string: self.text!, andPreserveCursorPosition: &targetCursorPosition)) {
                
            case .identified(let card):
                print(card)
                giveLeftImageView(image: card.image)
                if card == .amex {
                    self.isAmex  = true
                } else {
                    self.isAmex  = false
                }
                validatorCallBack?(.success(card))
                
            case .indeterminate(let cards):
                
                giveLeftImageView(image: #imageLiteral(resourceName: "chip"))
                self.isAmex  = false
                validatorCallBack?(.error("indeterminate state"))
                print(cards)
                
            case .invalid:
                giveLeftImageView(image: #imageLiteral(resourceName: "chip"))
                self.isAmex  = false
                validatorCallBack?(.error("invalid state"))
            }
            
            self.layoutIfNeeded()
        }
    }
    
    //MARK: giving image view to text field
    private func giveLeftImageView(image: UIImage) {
        self.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width/5, height: self.frame.height - 10 ))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.leftView = imageView
    }
    
    //MARK: For getting un formatted card number
    public func getCardNumberString() -> String {
        return cardNumberString
    }
    
    //MARK: Other functions
    private func removeNonDigitsFromString(string : String, andPreserveCursorPosition cursorPosition : inout UInt) -> String {
        var digitsOnlyString : String = ""
        for index in stride(from: 0, to: string.characters.count, by: 1)
        {
            let charToAdd : Character = Array(string.characters)[index]
            if isDigit(character: charToAdd) {
                digitsOnlyString.append(charToAdd)
            } else {
                if index < Int(cursorPosition) {
                    cursorPosition -= 1
                }
            }
        }
        return digitsOnlyString
    }
    
    private func isDigit(character : Character) -> Bool {
        return "\(character)".containsOnlyDigits()
    }
    
    private func insertSpacesInAmexFormat(string : String, andPreserveCursorPosition cursorPosition : inout UInt) -> String {
        var stringWithAddedSpaces : String = ""
        for index in stride(from: 0, to: string.characters.count, by: 1)
        {
            if index == 4
            {
                stringWithAddedSpaces += " "
                if index < Int(cursorPosition)
                {
                    cursorPosition += 1
                }
            }
            if index == 10 {
                stringWithAddedSpaces += " "
                if index < Int(cursorPosition)
                {
                    cursorPosition += 1
                }
            }
            if index < 15 {
                let characterToAdd : Character = Array(string.characters)[index]
                stringWithAddedSpaces.append(characterToAdd)
            }
        }
        return stringWithAddedSpaces
    }
    
    
    private func insertSpacesIntoEvery4DigitsIntoString(string : String, andPreserveCursorPosition cursorPosition : inout UInt) -> String {
        var stringWithAddedSpaces : String = ""
        for index in stride(from: 0, to: string.characters.count, by: 1)
        {
            if index != 0 && index % 4 == 0 && index < 16
            {
                stringWithAddedSpaces += " "
                
                if index < Int(cursorPosition)
                {
                    cursorPosition += 1
                }
            }
            if index < 16 {
                let characterToAdd : Character = Array(string.characters)[index]
                stringWithAddedSpaces.append(characterToAdd)
            }
        }
        return stringWithAddedSpaces
    }
}



