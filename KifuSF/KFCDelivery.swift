//
//  KFCDelivery.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 07/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CoreLocation

class KFCDelivery: KFCModularTableView {
    
    var delivery: Donation? {
        didSet {
            updateUI()
        }
    }
    
    private let actionButton = KFButton(backgroundColor: .kfInformative, andTitle: "Directions")
    
    private lazy var photoHelper: PhotoHelper = {
        let helper = PhotoHelper()
        helper.completionHandler = { [weak self] image in
            guard let unwrappedSelf = self else {
                return
            }
            
            guard let delivery = unwrappedSelf.delivery else {
                return assertionFailure("shouldn't select an image without a delivery")
            }
            
            //TODO: alex-show loading indicator
            
            DonationService.confirmDelivery(for: delivery, image: image, completion: { (isSuccessful) in
                //TODO: alex-dismiss loading indicator
                
                if isSuccessful {
                    unwrappedSelf.delivery?.status = .awaitingApproval
                    unwrappedSelf.updateUI()
                } else {
                    let errorAlert = UIAlertController(errorMessage: nil)
                    unwrappedSelf.present(errorAlert, animated: true)
                }
            })
        }
        
        return helper
    }()
    
    private func updateUI() {
        reloadData()
        
        //update the actionButton
        actionButton.isHidden = false
        
        if let delivery = self.delivery {
            switch delivery.status {
            case .open:
                assertionFailure("there shouldn't be a delivery as open here")
            case .awaitingPickup:
                actionButton.setTitle("Directions", for: .normal)
            case .awaitingDelivery:
                actionButton.setTitle("Directions", for: .normal)
            case .awaitingApproval:
                actionButton.isHidden = true
            }
        } else {
            actionButton.setTitle("View Open Donations", for: .normal)
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(actionButton)
        configureLayoutConstraints()
        actionButton.addTarget(
            self,
            action: #selector(pressActionButton(_:)),
            for: .touchUpInside
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStyling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        modularTableView.contentInset.bottom = actionButton.frame.height + 16
        modularTableView.scrollIndicatorInsets.bottom = actionButton.frame.height + 16
    }
    
    override func retrieveProgressItem() -> KFPModularTableViewItem? {
        guard let deliveryStep = self.delivery?.status.step else {
            return nil
        }
        
        return KFMProgress(currentStep: deliveryStep, ofType: .delivery)
    }
    
    override func retrieveInProgressDonationDescription() -> KFPModularTableViewItem? {
        guard let deliveryDescription = self.delivery?.inProgressDescriptionForVolunteer else {
            return nil
        }
        
        return deliveryDescription
    }
    
    override func retrieveEntityInfoItem() -> KFPModularTableViewItem? {
        guard let delivery = self.delivery else {
            return nil
        }
        
        //TODO: erick-collect info of what charity was selected for the donation
        return KFMEntityInfo(
            name: "Make School",
            phoneNumber: "+1 (415) 814-0980",
            address: "1547 Mission St San Francisco, CA  94103",
            entityType: .charity
        )
    }
    
    override func retrieveCollaboratorInfoItem() -> KFPModularTableViewItem? {
        guard let donatorInfo = self.delivery?.donator.collaboratorInfo else {
            return nil
        }
        
        return donatorInfo
    }
    
    override func retrieveDestinationMapItem() -> KFPModularTableViewItem? {
        guard let delivery = self.delivery else {
            return nil
        }
        
        let location: CLLocationCoordinate2D
        if delivery.status.isAwaitingPickup {
            location = CLLocationCoordinate2D(
                latitude: delivery.latitude,
                longitude: delivery.longitude
            )
        } else if delivery.status.isAwaitingDelivery {
            
            //TODO: get location of selected charity of donation
            return nil
        } else {
            return nil
        }
        
        return KFMDestinationMap(coordinate: location)
    }
    
    @objc func pressActionButton(_ sender: Any) {
        if let delivery = self.delivery {
            switch delivery.status {
            case .open, .awaitingApproval:
                assertionFailure("delivery should not have this status")
            case .awaitingPickup:
                
                //Directions to pick up loation
                self.openDirectionsToPickUpLocation(for: delivery)
            case .awaitingDelivery:
                
                //Directions to charity
//                self.openDirectionsToCharity(for: delivery)
                
                self.presentConfirmationImage(for: delivery)
            }
            
        } else {
            guard let tabBar = self.tabBarController else {
                return assertionFailure("no tabbar found")
            }
            
            tabBar.selectedIndex = 0
        }
    }
    
    private func openDirectionsToPickUpLocation(for delivery: Donation) {
        let map = MapHelper(long: delivery.longitude, lat: delivery.latitude)
        map.open()
    }
    
    private func presentConfirmationImage(for deliver: Donation) {
        photoHelper.presentActionSheet(from: self)
    }
    
    private func openDirectionsToCharity(for delivery: Donation) {
        
        //TODO: erick-find charity location
        let map = MapHelper(long: delivery.longitude, lat: delivery.latitude)
        map.open()
    }
}

extension KFCDelivery: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Delivery")
    }
}

//MARK: Styling & LayoutConstraints
extension KFCDelivery {
    private func configureLayoutConstraints() {
        configureDynamicButtonConstraints()
    }
    
    private func configureStyling() {
        view.backgroundColor = UIColor.kfSuperWhite
    }
    
    private func configureDynamicButtonConstraints() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        actionButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        actionButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
}

