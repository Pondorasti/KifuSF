//
//  Protocols.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 02/10/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation

protocol UIConfigurable {
    func configureData()
    func configureStyling()
    func configureLayout()
    func configureGestures()
    func configureDelegates()
}

extension UIConfigurable {
    func configureData() { }
    func configureStyling() { }
    func configureLayout() { }
    func configureGestures() { }
    func configureDelegates() { }
}
