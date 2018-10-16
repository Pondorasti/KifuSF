//
//  AppDelegate.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 28/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    
    var alertWindow: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()!.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if Auth.auth().currentUser != nil,
            let userData = UserDefaults.standard.object(forKey: "currentUser") as? Data,
            let user = try? JSONDecoder().decode(User.self, from: userData) {
            
            User.setCurrent(user)
        }
        
//        UserService.register(
//            with: "Volunteer2",
//            username: "Volts2",
//            image: #imageLiteral(resourceName: "DonationIcon"),
//            contactNumber: "7071234321",
//            email: "e2@g.com",
//            password: "password") { (user) in
//                if let user = user {
//                    User.setCurrent(user, writeToUserDefaults: true)
//                }
//        }

        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = KFCTabBar()
        window?.makeKeyAndVisible()

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.kfPrimary]
        UINavigationBar.appearance().tintColor = .kfPrimary
        UINavigationBar.appearance().barTintColor = .kfSuperWhite
        UINavigationBar.appearance().isTranslucent = false

        UITabBar.appearance().tintColor = .kfPrimary
        UITabBar.appearance().barTintColor = .kfSuperWhite
        UITabBar.appearance().isTranslucent = false

        return true
    }

    //TODO: alex-login logic
    private func setInitalViewController() {
        if Auth.auth().currentUser != nil,
            let userData = UserDefaults.standard.object(forKey: "currentUser") as? Data,
            let user = try? JSONDecoder().decode(User.self, from: userData) {

            User.setCurrent(user)

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialVC = storyboard.instantiateViewController(withIdentifier: "initialTabBar")

            window?.rootViewController = initialVC
            window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let initialVC = storyboard.instantiateViewController(withIdentifier: "kfLogin")
            window?.rootViewController = initialVC
            window?.makeKeyAndVisible()
        }
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: [:])

    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            return assertionFailure(error.localizedDescription)
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        let credentialDict = ["credentials": credential] as [String: Any]
        NotificationCenter.default.post(name: .userDidLoginWithGoogle, object: nil, userInfo: credentialDict)
    }

    //TODO: Handle disconnect logic
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

    }
}

extension UIWindow {
    static var applicationAlertWindow: UIWindow {
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("¯\\_(ツ)_/¯")
        }
        
        let alertWindow: UIWindow
        if let window = appDelegate.alertWindow {
            alertWindow = window
        } else {
            
            guard let appDelegateWindow = appDelegate.window else {
                fatalError("¯\\_(ツ)_/¯")
            }
            
            alertWindow = UIWindow(frame: appDelegateWindow.bounds)
            appDelegate.alertWindow = alertWindow
            alertWindow.windowLevel = UIWindowLevelAlert + 1
        }
        
        return alertWindow
    }
}
