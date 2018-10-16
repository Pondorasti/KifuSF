//
//  KFVCollaborator.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 28/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class KFVCollaboratorInfo: KFVDescriptor {
    
    let headlineLabel = UILabel()
    let descriptionLabel = UILabel()
    let statisticsStickyView = KFVSticky<KFVStatistics>(stickySide: .top)
    
    override func configureLayoutConstraints() {
        contentsStackView.addArrangedSubview(headlineLabel)
        
        super.configureLayoutConstraints()
        
        infoStackView.addArrangedSubview(descriptionLabel)
        infoStackView.addArrangedSubview(statisticsStickyView)
        
        titleLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        subtitleStickyLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        descriptionLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        statisticsStickyView.setContentHuggingPriority(.init(rawValue: 249), for: .vertical)
        
        subtitleStickyLabel.updateStickySide()
    }
    
    override func configureStyling() {
        super.configureStyling()
        
        layer.shadowOpacity = 0
        
        headlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        headlineLabel.numberOfLines = 0
        headlineLabel.textColor = UIColor.kfTitle
        headlineLabel.adjustsFontForContentSizeCategory = true
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.kfSubtitle
        descriptionLabel.adjustsFontForContentSizeCategory = true
        
        headlineLabel.text = "Collaborator Info"
    }
    
    func reloadData(for data: KFMCollaboratorInfo) {
        imageView.imageView.kf.setImage(with: data.profileImageURL)
        titleLabel.text = data.name
        subtitleStickyLabel.contentView.text = "@\(data.username)"
        descriptionLabel.text = "Reputation: \(data.userReputation)%"
        
        statisticsStickyView.contentView.donationCountLabel.text = "\(data.userDonationsCount)"
        statisticsStickyView.contentView.deliveryCountLabel.text = "\(data.userDeliveriesCount)"
    }
}