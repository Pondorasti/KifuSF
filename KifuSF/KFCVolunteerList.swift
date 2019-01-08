//
//  KFCVolunteerList.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 16/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class KFCVolunteerList: TableViewWithRoundedCellsViewController {
    // MARK: - Variables
    var donation: Donation!

    var volunteers: [User]!

    // MARK: - NoDataItem
    var noDataView = SlideView(image: .kfNoDataIcon,
                               title: "No poof",
                               description: "Go to...")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Volunteers"

        tableViewWithRoundedCells.register(
          RoundedTableViewCell<KFVVolunteerInfo>.self,
          forCellReuseIdentifier: RoundedTableViewCell<KFVVolunteerInfo>.identifier
          )
        tableViewWithRoundedCells.dataSource = self
        tableViewWithRoundedCells.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewWithRoundedCells.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension KFCVolunteerList: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if volunteers.isEmpty {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }

        return volunteers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let volunteerInfoCell = tableView.dequeueReusableCell(
            withIdentifier: RoundedTableViewCell<KFVVolunteerInfo>.identifier,
            for: indexPath) as? RoundedTableViewCell<KFVVolunteerInfo> else {
            fatalError(KFErrorMessage.unknownCell)
        }

        let volunteer = self.volunteers[indexPath.row]

        let data = KFMVolunteerInfo(
            imageURL: URL(string: volunteer.imageURL)!,
            username: volunteer.username,
            userReputation: volunteer.reputation,
            userDonationsCount: volunteer.numberOfDonations,
            userDeliveriesCount: volunteer.numberOfDeliveries
        )

        volunteerInfoCell.descriptorView.reloadData(for: data)
        volunteerInfoCell.descriptorView.delegate = self

        volunteerInfoCell.descriptorView.indexPath = indexPath

        return volunteerInfoCell
    }
}

// MARK: - KFPVolunteerInfoCellDelegate
extension KFCVolunteerList: KFPVolunteerInfoCellDelegate {
    func didPressButton(_ sender: RoundedTableViewCell<KFVVolunteerInfo>) {
        guard let indexPath = tableViewWithRoundedCells.indexPath(for: sender) else {
            return assertionFailure("no cell found")
        }
        
        let selectedVolunteer = self.volunteers[indexPath.row]
        tableViewWithRoundedCells.isUserInteractionEnabled = false
        
        DonationService.accept(volunteer: selectedVolunteer, for: self.donation) { (isSuccessfull) in
            if isSuccessfull {
                self.navigationController?.popViewController(animated: true)
            } else {
                let errorAlert = UIAlertController(errorMessage: nil)
                self.present(errorAlert, animated: true)
                
                self.tableViewWithRoundedCells.isUserInteractionEnabled = false
            }
        }
    }
}
