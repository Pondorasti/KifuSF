//
//  UserService.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 28/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import Foundation

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

typealias FIRUser = FirebaseAuth.User

struct UserService {
    public static func create(firUser: FIRUser, username: String, image: UIImage, contactNumber: String, completion: @escaping (User?) -> ()) {
        let imageRef = StorageReference.newUserImageRefence(with: firUser.uid)
        
        StorageService.uploadImage(image, at: imageRef) { (url) in
            guard let downloadURL = url else { return completion(nil) }
            let imageURL = downloadURL.absoluteString
            
            let newUser = User(username: username, uid: firUser.uid, imageURL: imageURL, contributionPoints: 0, contactNumber: contactNumber)
            
            let ref = Database.database().reference().child("users").child(firUser.uid)
            
            ref.setValue(newUser.dictValue, withCompletionBlock: { (error, _) in
                if let error = error {
                    return completion(nil)
                }
                
                return completion(newUser)
            })
        }
    }
    
    public static func show(forUID uid: String, completion: @escaping (User?) -> ()) {
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let user = User(from: snapshot) else { return completion(nil) }
            
            return completion(user)
        }
    }
    
    public static func calculateDistance(from location: CLLocation, completion: @escaping (String) -> ()) {
        if let myCurrentLocation = User.current.currentLocation {
            //TODO: convert result into miles
            return completion("\(myCurrentLocation.distance(from: location)) miles to pickup")
        }
        
        completion("Distance not available")
    }
    

}


