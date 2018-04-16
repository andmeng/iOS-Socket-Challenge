//
//  ViewController.swift
//  FitBitChallenge
//
//  Created by Andrew Meng on 2018-02-02.
//  Copyright © 2018 Andrew Meng. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    fileprivate var commandReceiver : CommandReceiver?
    fileprivate var commands : [RGBCommand] = []
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachCommandReceiver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Depending on our use case we may want to close the network connection
        // At a different stage of the ViewController lifecycle or even deinit
        self.commandReceiver?.closeNetworkConnection()
    }
}

// MARK: - Set-up Methods

extension MainViewController {
    fileprivate func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.registerCell(nibName: "RGBTableViewCell",
                                    cellClass: RGBTableViewCell.self,
                                    reuseIdentifier: RGBTableViewCell.reuseIdentifier)
    }
    
    fileprivate func attachCommandReceiver() {
        self.commandReceiver = CommandReceiver()
        self.commandReceiver?.delegate = self
        self.commandReceiver?.setupNetworkConnection()
    }
}

// MARK: - Actions

extension MainViewController {
    @objc fileprivate func didPressConnectToPort() {
        print("Did press connect")
    }
}

// MARK: - UITableViewDelegate

extension MainViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        let rgbCell = tableView.dequeueReusableCell(
            withIdentifier: RGBTableViewCell.reuseIdentifier,
            for: indexPath)
            as! RGBTableViewCell
        
        rgbCell.command = indexPath.row < self.commands.count
            ? self.commands[indexPath.row] : nil
        
        cell = rgbCell
        return cell!
    }
}

// MARK: - CommandReceiverDelegate

extension MainViewController : CommandReceiverDelegate
{
    func didReceiveCommand(command: RGBCommand) {
        let configuredCommand = command
        
        // Add Relative Command RGB Offset,
        // Does not properly handle for if by chance the R G or B value goes out of range ( not in 0 - 255 )
        // When over the limit it just caps that value at the bound (e.g. 400 is used as 255)
        
        if let type = configuredCommand.commandType, type == .relative {
            configuredCommand.rgb?.r += self.commands.first?.rgb?.r ?? RGB.defaultRgbValue
            configuredCommand.rgb?.g += self.commands.first?.rgb?.g ?? RGB.defaultRgbValue
            configuredCommand.rgb?.b += self.commands.first?.rgb?.b ?? RGB.defaultRgbValue
        }
        
        configuredCommand.color = UIColor(red: (configuredCommand.rgb?.r ?? RGB.defaultRgbValue) / RGB.rgbDivisionConstant,
                                          green: (configuredCommand.rgb?.g ?? RGB.defaultRgbValue) / RGB.rgbDivisionConstant,
                                          blue: (configuredCommand.rgb?.b ?? RGB.defaultRgbValue) / RGB.rgbDivisionConstant,
                                          alpha: 1.0)
        
        self.tableView.beginUpdates()
        
        self.commands.insert(configuredCommand, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath],
                                  with: UITableViewRowAnimation.automatic)
        
        self.tableView.endUpdates()
    }
}

