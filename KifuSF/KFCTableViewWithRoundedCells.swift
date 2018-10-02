//
//  KFCTableViewWithRoundedCells.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 10/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class KFCTableViewWithRoundedCells: UIViewController {
    
    let tableViewWithRoundedCells = UITableView()
    var tableViewWithRoundedCellsConstraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableViewWithRoundedCells)
        
        configureLayoutConstraints()
        configureStyling()
        
        view.layoutIfNeeded()
    }
    
    func configureLayoutConstraints() {
        tableViewWithRoundedCells.translatesAutoresizingMaskIntoConstraints = false
        tableViewWithRoundedCellsConstraints = tableViewWithRoundedCells.autoPinEdgesToSuperviewEdges()
    }
    
    func configureStyling() {
        tableViewWithRoundedCells.separatorStyle = .none
        tableViewWithRoundedCells.backgroundColor = UIColor.kfGray
        
        tableViewWithRoundedCells.contentInset.bottom = 8
        tableViewWithRoundedCells.scrollIndicatorInsets.bottom = 8
        
        tableViewWithRoundedCells.contentInset.top = 8
        tableViewWithRoundedCells.scrollIndicatorInsets.top = 8
    }
}
