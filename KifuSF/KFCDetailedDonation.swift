//
//  DetailedDonationViewController.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 29/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class KFCDetailedDonation: KFCModularTableView {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Donation"
        view.backgroundColor = UIColor.kfWhite
        tableView.separatorStyle = .none
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .kfFlagIcon,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(flagButtonPressed))
    }
    
    @objc func flagButtonPressed() {
        //TODO: flagging
    }

    override func retrieveOpenDonationDescriptionItem() -> KFPModularTableViewItem? {
        return KFMOpenDonationDescriptionItem(imageURL: URL(string: "https://images.pexels.com/photos/356378/pexels-photo-356378.jpeg?auto=compress&cs=tinysrgb&h=350")!, title: "Toilet Paper", username: "Pondorasti", creationDate: "12.12.12", userReputation: 79, userDonationsCount: 12, userDeliveriesCount: 12, distance: 5, description: "woof woof") // swiftlint:disable:this line_length
    }
}
