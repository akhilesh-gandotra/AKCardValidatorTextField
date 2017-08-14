//
//  CardExpirationValidator.swift
//  CardValidator
//
//  Created by Akhilesh Gandotra on 27/07/17.
//  Copyright © 2017 Akhilesh. All rights reserved.
//

import Foundation
import  UIKit


extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return self[startIndex ..< endIndex]
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}
class CardExpirationValidator: UITextField {
    
    var expirationHandler: ((String) -> Void)?

    override func awakeFromNib() {
        self.placeholder = "MM/YYYY"
        self.delegate = self
    }
    
    func getMonth() -> String {
        return self.text!.substring(to: 1)
    }
    func getYear() -> String {
         return self.text!.substring(from: 3, to: 6)
    }

}

extension CardExpirationValidator: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length > 0
        {
            return true
        }
        
        //Dont allow empty strings
        if string == " "
        {
            return false
        }
        
        //Check for max length including the spacers we added
        if range.location >= 7
        {
            return false
        }
        
        var originalText = textField.text
        let replacementText = string.replacingOccurrences(of: " ", with: "")
        
        //Verify entered text is a numeric value
        let digits = NSCharacterSet.decimalDigits
        for char in replacementText.unicodeScalars
        {
            if !digits.contains(char)
            {
                return false
            }
        }
        
        //Put / space after 2 digit
        if range.location == 2
        {
            originalText?.append("/")
            textField.text = originalText
        }
        return true
    }
  }
