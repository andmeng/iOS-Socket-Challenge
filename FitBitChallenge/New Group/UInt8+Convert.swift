//
//  UInt8+Convert.swift
//  FitBitChallenge
//
//  Created by Andrew Meng on 2018-02-05.
//  Copyright © 2018 Andrew Meng. All rights reserved.
//

import Foundation

extension UInt8 {
    
    // Returns UInt8 value as if it would be represented by Int8
    func convertToSignedEquivalent() -> Int16 {
        if self > 127 {
            // Based on Two's Complement
            return Int16(~self + 1) * -1
        }
        return Int16(self)
    }
}
