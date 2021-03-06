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
    
    /**
     <#Lorem ipsum dolor sit amet.#>
     
     - parameter name: is the full name of the user
     - parameter contactNumber: is the user's phone number as shown XXXYYYZZZZ
     - parameter password: is six or more characters long
     
     - parameter user: if this is given back as nil, something went wrong while registering the user
     */
    static func register( // swiftlint:disable:this function_parameter_count
        with name: String,
        username: String,
        image: UIImage,
        contactNumber: String,
        email: String,
        password: String,
        completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let firUser = result?.user else {
                fatalError("no user from result but no error was found")
            }
            
            UserService.create(
                uid: firUser.uid,
                username: username,
                image: image,
                contactNumber:
                contactNumber, completion: { (user) in
                    completion(user, nil)
            })
        }
    }
    
    /**
     Login a Kifu user
     
     - parameter user: if this is given back as nil, no user was found
     */
    static func login(email: String, password: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                return completion(nil, error)
            }
            
            guard let firUser = result?.user else {
                fatalError("no user from result but no error was found or, validation failed with register button")
            }
            
            UserService.show(forUID: firUser.uid, completion: { (user) in
                completion(user, nil)
            })
        }
    }
    
    struct SignInProviderInfo {
        let uid: String
        let displayName: String?
        let email: String?
        let phoneNumber: String?
        let photoUrl: URL?
    }
    
    /**
     Use this to login after collecting credentials from a sign-in provider such as Google.
     
     - parameter credentials: object retrieved after the user has signed in from a provider.
     Listen to the `userDidLoginWithGoogle` notification to collect this credential
     in NotificationCenter.default
     - parameter completion: given an error or the existing user
     - parameter user: exsiting user or nil if an error has occurred
     - parameter newUserHandler: when the user is authenticated but not in our database
     - parameter providerInfo: the information that was given back from the provider
     */
    static func login(
        with credentials: AuthCredential,
        existingUserHandler: @escaping (_ user: User?, Error?) -> Void,
        newUserHandler: @escaping (_ providerInfo: SignInProviderInfo) -> Void) {
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (result, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                
                return existingUserHandler(nil, error)
            }
            
            guard let firUser = result?.user else {
                fatalError("no user from result but no error was found or, validation failed with register button")
            }
            
            let phoneNumber = firUser.phoneNumber
            let displayName = firUser.displayName
            let photoUrl = firUser.photoURL
            let email = firUser.email
            
            UserService.show(forUID: firUser.uid, completion: { (user) in
                if user != nil {
                    existingUserHandler(user, nil)
                } else {
                    let providerInfo = SignInProviderInfo(
                        uid: firUser.uid,
                        displayName: displayName,
                        email: email,
                        phoneNumber: phoneNumber,
                        photoUrl: photoUrl
                    )
                    newUserHandler(providerInfo)
                }
            })
        }
    }
    
    /**
     Logs out the current user and removes it from persistence
     */
    static func logout() throws {
        try Auth.auth().signOut()
        
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    /**
     send a password reset email
     
     - ToDo: decide what to do with the error
     */
    static func resetPassword(for email: String, completion: @escaping (Bool) -> ()) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                
                return completion(false)
            }
            
            return completion(true)
        }
    }
    
    /**
     After collecting the missing information about the user after signing in from
     a provider, use this method to push the information to the database
     
     - parameter uid: given from the SignInProviderInfo from `static func login(credentials:completion:newUserHandler:)`
     */
    static func completeSigninProviderLogin(// swiftlint:disable:this function_parameter_count
        withUid uid: String,
        name: String,
        username: String,
        image: UIImage,
        contactNumber: String,
        email: String,
        password: String,
        completion: @escaping (_ user: User?) -> Void) {
        
        self.create(
            uid: uid,
            username: username,
            image: image,
            contactNumber: contactNumber,
            completion: completion
        )
    }
    
    static func completeSigninProviderLogin(// swiftlint:disable:this function_parameter_count
        withUid uid: String,
        username: String,
        imageLink: URL,
        contactNumber: String,
        completion: @escaping (_ user: User?) -> Void) {
        self.create(uid: uid,
                    username: username,
                    imageURL: imageLink,
                    contactNumber: contactNumber,
                    completion: completion)
    }
    
    private static func create(
        uid: String,
        username: String,
        image: UIImage,
        contactNumber: String,
        completion: @escaping (User?) -> Void) {
        let imageRef = StorageReference.newUserImageRefence(with: uid)
        
        StorageService.uploadImage(image, at: imageRef) { (url) in
            guard let downloadURL = url else { return completion(nil) }
            let imageURL = downloadURL.absoluteString
            
            let newUser = User(username: username,
                               uid: uid,
                               imageURL: imageURL,
                               contactNumber: contactNumber,
                               isVerified: false)
            
            let ref = Database.database().reference().child("users").child(uid)
            
            ref.setValue(newUser.dictValue, withCompletionBlock: { (error, _) in
                if error != nil {
                    return completion(nil)
                }
                
                return completion(newUser)
            })
        }
    }
    
    private static func create(
        uid: String,
        username: String,
        imageURL: URL,
        contactNumber: String,
        completion: @escaping (User?) -> Void) {
        
        let stringURL = imageURL.absoluteString
        
        let newUser = User(username: username,
                           uid: uid,
                           imageURL: stringURL,
                           contactNumber: contactNumber,
                           isVerified: false)
        
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.setValue(newUser.dictValue, withCompletionBlock: { (error, _) in
            if error != nil {
                return completion(nil)
            }
            
            return completion(newUser)
        })
        
    }
    
    
    
    static func retrieveAuthErrorMessage(for error: Error) -> String {
        guard let errorCode = AuthErrorCode(rawValue: (error._code)) else {
            return "Something went wront, please try again."
        }
        
        switch errorCode {
        case .weakPassword:
            return "Password should contain atleast 6 characters."
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .missingEmail:
            return "Missing email."
        case .invalidEmail:
            return "This email is invalid."
        case .wrongPassword:
            return "Password Wrong."
        case .userNotFound:
            return "No matching account with this credentials."
        default:
            return "Something went wront, please try again."
        }
    }
    
    public static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let user = User(from: snapshot) else { return completion(nil) }
            
            return completion(user)
        }
    }
    
    /**
     Add a flagging report to the given user
     
     - Attention: conforms to firebase rules
     */
    static func attach(report: Report, to user: User, completion: @escaping (Bool) -> Void) {
        let refUser = DatabaseReference.user(at: user.uid)
        let changes: [String: Any] = [
            User.Keys.flaggedReportUid: report.uid,
            User.Keys.flag: report.flag.rawValue
        ]
        refUser.updateChildValues(changes) { error, _ in
            if let error = error {
                assertionFailure("there was an error attaching the report: \(error.localizedDescription)")
                return completion(false)
            }
            
            completion(true)
        }
    }
    
    static func review(donator: User, rating: UserReview, completion: @escaping (Bool) -> Void) {
        review(user: donator, rating: rating, keyPathToIncrement: \User.numberOfDonations, completion: completion)
    }
    
    static func review(volunteer: User, rating: UserReview, completion: @escaping (Bool) -> Void) {
        review(user: volunteer, rating: rating, keyPathToIncrement: \User.numberOfDeliveries, completion: completion)
    }
    
    private static func review(user: User, rating: UserReview, keyPathToIncrement keyPath: WritableKeyPath<User, Int>, completion: @escaping (Bool) -> Void) {
        
        let ref = DatabaseReference.user(at: user.uid)
        
        //using transactions
        ref.runTransactionBlock({ (snapshot) -> TransactionResult in
            
            /**
             since snapshots can come back as null in transactions, return success if
             that is the case.
             
             Only return abort if validation of a non-null snapshot occurs
             */
            
            guard let userDict = snapshot.value as? [String: Any] else {
                return .success(withValue: snapshot)
            }
            
            guard var user = User(from: userDict) else {
                return .abort()
            }
            
            //load the user's current ratings
            user.addNewRating(rating, increment: keyPath)
            
            snapshot.value = user.dictValue
            
            return .success(withValue: snapshot)
            
        }, andCompletionBlock: { (error, successful, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                
                return completion(false)
            }
            
            completion(successful)
        })
    }
    
    /**
     Mark the current user's isVerified to true
     
     - Attention: conforms to firebase rules
     */
    static func markIsVerifiedTrue(completion: @escaping (Bool) -> Void) {
        let ref = DatabaseReference.currentUser()
        let changes: [String: Any] = [
            User.Keys.isVerified: true
        ]
        
        ref.updateChildValues(changes) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                
                return completion(false)
            }
            
            completion(true)
        }
    }
    
    /**
     Mark the current user's hasApprovedConditions to true
     
     - Attention: conforms to firebase rules
     */
    static func markHasApprovedConditionsTrue(completion: @escaping (Bool) -> Void) {
        let ref = DatabaseReference.currentUser()
        let changes: [String: Any] = [
            User.Keys.hasApprovedConditions: true
        ]
        
        ref.updateChildValues(changes) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                
                return completion(false)
            }
            
            completion(true)
        }
    }
    
    /**
     Mark the current user's hasSeenTutorial to true
     
     - Attention: conforms to firebase rules
     */
    static func markHasSeenTutorialTrue(completion: @escaping (Bool) -> Void) {
        let ref = DatabaseReference.currentUser()
        let changes: [String: Any] = [
            User.Keys.hasSeenTutorial: true
        ]
        
        ref.updateChildValues(changes) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                
                return completion(false)
            }
            
            completion(true)
        }
    }
    
    /**
     update the given user in the user subtree. This also writes the given user
     to User Defaults
     
     - TODO: write a cloud function to update denormalized instances of the given user
     */
    //TODO: fix update function
    static func update(user: User, completion: @escaping (Bool) -> Void) {
        let refDonation = Database.database().reference().child("users").child(user.uid)
        refDonation.updateChildValues(user.dictValue) { (error, _) in
            guard error == nil else {
                assertionFailure(error!.localizedDescription)

                return completion(false)
            }
            
            User.setCurrent(user)
            User.writeToPersistance()

            completion(true)
        }
    }
    
    /**
     - returns: double in miles if user's location is available
     */
    public static func calculateDistance(donation: Donation) -> UserDistance {
        return calculateDistance(long: donation.longitude, lat: donation.latitude)
    }

    /**
     This distance is a striaght line between two distances (vs using roads, thus
     long distances will be vastly different than shorter ones)
     
     - returns: double in miles if user's location is available
     */
    public static func calculateDistance(long: Double, lat: Double) -> UserDistance {
        let location = CLLocation(latitude: lat, longitude: long)
        guard let myCurrentLocation = User.current.currentLocation else {
            return .notAvailable()
        }
        
        let meters = myCurrentLocation.distance(from: location)
        
        return .available(meters: meters)
    }
    
    // MARK: Update and persist user
    
    /**
     updates and writes the user in User Defaults. Local persistence only
     
     - parameter key: Using WritableKeyPath, define what you'd like to update
     - parameter value: the new value to set the given key path
     
     - returns: Updated User
     */
    @discardableResult
    static func updateCurrentUser<T>(
        key: WritableKeyPath<User, T>, to value: T,
        writeToUserDefaults: Bool = true) -> User {
        
        var updatedUser = User.current
        updatedUser[keyPath: key] = value
        User.setCurrent(updatedUser)
        
        if writeToUserDefaults {
            User.writeToPersistance()
        }
        
        return updatedUser
    }
}

fileprivate extension User {
    mutating func addNewRating(_ rating: UserReview, increment keyPath: WritableKeyPath<User, Int>) {
        
        //mutate the current user by updating their new reputation
        let nReviews = self.numberOfDeliveries + self.numberOfDonations
        let newStars = rating.rating.rawValue
        self.reputation = (reputation * Double(nReviews) + Double(newStars)) / Double(nReviews + 1)
        
        self[keyPath: keyPath] += 1
    }
}
