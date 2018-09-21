//
//  KFVDonationDescription.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 17/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class KFVOpenDonationDescription: KFVDescriptor {
    
    let statisticsView = KFVSticky<KFVStatistics>(stickySide: .top)
    let secondSubtitleLabel = KFVSticky<UILabel>()
    
    let statusStackView = UIStackView()
    let statusTitleLabel = UILabel()
    let statusDescription = UILabel()
    
    let donationDescriptionStackView = UIStackView()
    let donationDescriptionTitleLabel = UILabel()
    let donationDescriptionContentLabel = UILabel()
    
    override func setupLayoutConstraints() {
        super.setupLayoutConstraints()
        
        infoStackView.addArrangedSubview(secondSubtitleLabel)
        infoStackView.addArrangedSubview(statisticsView)
        infoStackView.spacing = 2
        
        statusStackView.addArrangedSubview(statusTitleLabel)
        statusStackView.addArrangedSubview(statusDescription)
        statusStackView.axis = .vertical
        statusStackView.spacing = 2
        
        donationDescriptionStackView.addArrangedSubview(donationDescriptionTitleLabel)
        donationDescriptionStackView.addArrangedSubview(donationDescriptionContentLabel)
        donationDescriptionStackView.axis = .vertical
        donationDescriptionStackView.spacing = 2
        
        contentsStackView.addArrangedSubview(statusStackView)
        contentsStackView.addArrangedSubview(donationDescriptionStackView)
        
        titleLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        subtitleLabel.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        statisticsView.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        statisticsView.setContentHuggingPriority(.init(rawValue: 249), for: .vertical)
        
        for constraint in imageConstraints {
            constraint.constant = 128
        }
        
        subtitleLabel.updateStickySide()
    }
    
    override func setUpStyling() {
        super.setUpStyling()
        
        layer.cornerRadius = 0
        layer.shadowOpacity = 0
        
        secondSubtitleLabel.contentView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        secondSubtitleLabel.contentView.numberOfLines = 0
        secondSubtitleLabel.contentView.textColor = UIColor.kfSubtitle
        secondSubtitleLabel.contentView.adjustsFontForContentSizeCategory = true
        
        statusTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        statusTitleLabel.numberOfLines = 0
        statusTitleLabel.textColor = UIColor.kfTitle
        statusTitleLabel.adjustsFontForContentSizeCategory = true
        statusTitleLabel.text = "Distance"
        
        statusDescription.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statusDescription.numberOfLines = 0
        statusDescription.textColor = UIColor.kfSubtitle
        statusDescription.adjustsFontForContentSizeCategory = true
        
        donationDescriptionTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        donationDescriptionTitleLabel.numberOfLines = 0
        donationDescriptionTitleLabel.textColor = UIColor.kfTitle
        donationDescriptionTitleLabel.adjustsFontForContentSizeCategory = true
        donationDescriptionTitleLabel.text = "Description"
        
        donationDescriptionContentLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        donationDescriptionContentLabel.numberOfLines = 0
        donationDescriptionContentLabel.textColor = UIColor.kfSubtitle
        donationDescriptionContentLabel.adjustsFontForContentSizeCategory = true
    }
    
    func reloadData(for data: KFMOpenDonationDescriptionItem) {
        imageView.imageView.kf.setImage(with: data.imageURL)
        
        titleLabel.text = data.title
        subtitleLabel.contentView.text = "@\(data.username) at \(data.timestamp)"
        
        secondSubtitleLabel.contentView.text = "Reputation \(data.userReputation)%"
        
        statisticsView.contentView.donationCountLabel.text = "\(data.userDonationsCount)"
        statisticsView.contentView.deliveryCountLabel.text = "\(data.userDeliveriesCount)"
        
        statusDescription.text = "\(data.distance) Miles away from your current location"
        donationDescriptionContentLabel.text = data.description
    }
}


