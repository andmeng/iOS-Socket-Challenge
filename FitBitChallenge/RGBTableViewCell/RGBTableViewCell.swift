//
//  RGBTableViewCell.swift
//  FitBitChallenge
//
//  Created by Andrew Meng on 2018-02-02.
//  Copyright © 2018 Andrew Meng. All rights reserved.
//

import UIKit

class RGBTableViewCell : UITableViewCell {
    
    static let reuseIdentifier = "RGBTableViewCell"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commandLabel: UILabel!
    
    // MARK: - Properties
    
    var command : RGBCommand? {
        didSet {
            updateForCommand()
        }
    }
    
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

// MARK: - Set-up Methods

extension RGBTableViewCell {
    fileprivate func updateForCommand() {
        if let cmd = command {
            self.commandLabel.text = cmd.getRGBDisplayString()
            self.containerView.backgroundColor = cmd.color
        }
    }
}
