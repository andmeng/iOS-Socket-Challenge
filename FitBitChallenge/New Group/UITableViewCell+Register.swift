//
//  UITableView+Register.swift
//  FoodieApp
//
//  Created by Andrew Meng on 2018-02-02.
//  Copyright © 2017 Andrew Meng. All rights reserved.
//

import UIKit

extension UITableView
{
    func registerCell(nibName: String, cellClass: AnyClass?, reuseIdentifier: String)
    {
        let nib = UINib(nibName: nibName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
}

