//
//  ReportingService.swift
//  KifuSF
//
//  Created by Erick Sanchez on 8/29/18.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ReportingService {
    
    static func createReport(
        for donation: Donation,
        flaggingType: FlaggedContentType,
        userMessage: String,
        completion: @escaping (Bool) -> Void) {
        
        //ref for report
        let refReport = Database.database().reference().child("reports").childByAutoId()
        
        //create report
        let report = Report(flag: donation, for: flaggingType, message: userMessage, uid: refReport.key)
        
        //set value
        refReport.setValue(report.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            
            var flaggedDonation = donation
            flaggedDonation.flag(with: report)
            
            //update donation using DonationService
            DonationService.update(donation: flaggedDonation, completion: { (success) in
                guard success else {
                    assertionFailure("there was an error updating donation: \(donation)")
                    
                    return completion(false)
                }
                
                completion(true)
            })
        }
    }
    
    static func createReport(
        for user: User,
        flaggingType: FlaggedContentType,
        userMessage: String,
        completion: @escaping (Bool) -> Void) {
        
        //ref for report
        let refReport = Database.database().reference().child("reports").childByAutoId()
        
        //create report
        let report = Report(flag: user, for: flaggingType, message: userMessage, uid: refReport.key)
        
        //set value
        refReport.setValue(report.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            
            var flaggedUser = user
            flaggedUser.flag(with: report)
            
            //update donation using DonationService
            UserService.update(user: flaggedUser, completion: { (success) in
                guard success else {
                    assertionFailure("there was an error updating donation: \(user)")
                    
                    return completion(false)
                }
                
                completion(true)
            })
        }
        
    }
    
    static func showReport(from reportUid: String, completion: @escaping(Report?) -> Void) {
        let refReport = Database.database().reference().child("reports").child(reportUid)
        refReport.observeSingleEvent(of: .value) { (snapshot) in
            guard let report = Report(from: snapshot) else {
                return completion(nil)
            }
            
            completion(report)
        }
    }
}
