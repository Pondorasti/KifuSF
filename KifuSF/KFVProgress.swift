//
//  KFVProgress.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 20/09/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//


import UIKit
import PureLayout

class KFVProgress: UITableViewCell {
    
    @IBOutlet weak var currentStepLabel: UILabel!
    @IBOutlet weak var currentStepImageView: UIImageView!
    
    @IBOutlet weak var stepOneStackView: UIStackView!
    @IBOutlet weak var stepOneTitleLabel: UILabel!
    @IBOutlet weak var stepOneDescriptionLabel: UILabel!
    
    @IBOutlet weak var stepTwoStackView: UIStackView!
    @IBOutlet weak var stepTwoTitleLabel: UILabel!
    @IBOutlet weak var stepTwoDescriptionLabel: UILabel!
    
    @IBOutlet weak var stepThreeStackView: UIStackView!
    @IBOutlet weak var stepThreeTitleLabel: UILabel!
    @IBOutlet weak var stepThreeDescriptionLabel: UILabel!
    
    @IBOutlet weak var stepFourStackView: UIStackView!
    @IBOutlet weak var stepFourTitleLabel: UILabel!
    
    private var allStepsStackViews = [UIStackView]()
    private var allStepsImages = [UIImage?]()
    
    private let fadedTextAlpha: CGFloat = 0.2
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        allStepsStackViews = [stepOneStackView, stepTwoStackView, stepThreeStackView, stepFourStackView]
        allStepsImages = [UIImage(named: "Step 1"), UIImage(named: "Step 2"), UIImage(named: "Step 3"), UIImage(named: "Step 4")]
        
        setUpStyling()
    }
    
    private func setUpStyling() {
        currentStepLabel.textColor = UIColor.Text.Headline
        
        stepOneTitleLabel.textColor = UIColor.Text.Headline
        stepOneDescriptionLabel.textColor = UIColor.Text.SubHeadline
        stepOneDescriptionLabel.numberOfLines = 2
        stepOneDescriptionLabel.adjustsFontSizeToFitWidth = true
        
        stepTwoTitleLabel.textColor = UIColor.Text.Headline
        stepTwoDescriptionLabel.textColor = UIColor.Text.SubHeadline
        stepTwoDescriptionLabel.numberOfLines = 2
        stepTwoDescriptionLabel.adjustsFontSizeToFitWidth = true
        
        stepThreeTitleLabel.textColor = UIColor.Text.Headline
        stepThreeDescriptionLabel.textColor = UIColor.Text.SubHeadline
        stepThreeDescriptionLabel.numberOfLines = 2
        stepThreeDescriptionLabel.adjustsFontSizeToFitWidth = true
        
        stepFourTitleLabel.textColor = UIColor.Text.Headline
        selectionStyle = .none
    }
    
    private func highlightCurrentStep(for currentStep: KFMProgress.Step) {
        for stackView in allStepsStackViews {
            stackView.alpha = fadedTextAlpha
        }
        
        //TODO: check for index out of range
        allStepsStackViews[currentStep.rawValue].alpha = 1
    }
    
    private func updateImage(for currentStep: KFMProgress.Step) {
        //TODO: check for index out of range
        currentStepImageView.image = allStepsImages[currentStep.rawValue]
    }
    
    func reloadData(for data: KFMProgress) {
        highlightCurrentStep(for: data.currentStep)
        updateImage(for: data.currentStep)
        currentStepLabel.text = "Current Step: \(data.currentStep.rawValue + 1)"
        
        switch data.actionType {
        case .delivery:
            stepOneDescriptionLabel.text = "Pick up the item from the Donator"
            stepTwoDescriptionLabel.text = "Deliver the item to charity and validate the delivery by taking a picture with the item"
            stepThreeDescriptionLabel.text = "After completing your delivery, review the Donator"
        case .donation:
            stepOneDescriptionLabel.text = "Deliver the item to the volunteer"
            stepTwoDescriptionLabel.text = "Waiting for the volunteer to deliver the item"
            stepThreeDescriptionLabel.text = "Waiting for your approval of the delivery"
        }
    }
}
