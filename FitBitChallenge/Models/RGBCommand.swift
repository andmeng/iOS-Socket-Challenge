//
//  RGBCommand.swift
//  FitBitChallenge
//
//  Created by Andrew Meng on 2018-02-02.
//  Copyright © 2018 Andrew Meng. All rights reserved.
//

import UIKit

struct RGB {
    
    static let defaultRgbValue : CGFloat = 127.0
    static let rgbDivisionConstant : CGFloat = 255
    
    var r : CGFloat = 0
    var g : CGFloat = 0
    var b : CGFloat = 0
    
    init(red : CGFloat?, green : CGFloat?, blue : CGFloat?) {
        self.r = red ?? RGB.defaultRgbValue
        self.g = green ?? RGB.defaultRgbValue
        self.b = blue ?? RGB.defaultRgbValue
    }
}

enum CommandType : Int {
    case relative = 1
    case absolute = 2
}

class RGBCommand {
    
    var rgb : RGB?
    var commandType : CommandType?
    var color : UIColor?
    
    convenience init(type : CommandType?, rgb : RGB?) {
        self.init()
        self.commandType = type
        self.rgb = rgb
    }
    
    func getRGBDisplayString() -> String {
        if let rgbValues = self.rgb {
            return "(\(rgbValues.r) ,\(rgbValues.g) ,\(rgbValues.b))"
        } else {
            return "NaN"
        }
    }
}
