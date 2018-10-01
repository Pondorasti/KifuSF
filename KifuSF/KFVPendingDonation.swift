//
//  KFVPendingDonation.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 09/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class KFVPendingDonation: KFVDescriptor {
    
    let cancelStickyButton = KFVSticky<KFVButton>(stickySide: .bottom)
    
    var indexPath: IndexPath?
    
    weak var delegate: KFPPendingDonationCellDelegate?
    
    override func setUpLayoutConstraints() {
        super.setUpLayoutConstraints()
        cancelStickyButton.translatesAutoresizingMaskIntoConstraints = false
        
        infoStackView.addArrangedSubview(cancelStickyButton)
        
        titleLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        subtitleStickyLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        cancelStickyButton.setContentHuggingPriority(.init(rawValue: 249), for: .vertical)
        
        cancelStickyButton.autoPinEdge(toSuperviewEdge: .leading)
        cancelStickyButton.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    override func setUpStyling() {
        super.setUpStyling()
        
        cancelStickyButton.contentView.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        cancelStickyButton.contentView.setMainBackgroundColor(.kfDestructive)
        cancelStickyButton.contentView.setTitle("Cancel", for: .normal)
    }
    
    @objc func cancelButtonPressed() {
        guard let tableViewCell = superview?.superview as? KFVRoundedCell<KFVPendingDonation> else {
            //TODO: fix this
            fatalError("you are using this view the wrong way :]")
        }
        
        delegate?.didPressButton(tableViewCell)
    }
    
    func reloadData(for data: KFMPendingDonation) {
        imageView.imageView.kf.setImage(with: data.imageURL)
        
        titleLabel.text = data.title
        subtitleStickyLabel.contentView.text = "\(data.distance) Miles away"
    }
}

protocol KFPPendingDonationCellDelegate: class {
    func didPressButton(_ sender: KFVRoundedCell<KFVPendingDonation>)
}