//
//  AppDelegate.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 28/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UIConfigurable {
    
    static var shared: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            fatalError("Major Bo bo")
        }
        
        return appDelegate
    }
        
    var window: UIWindow?
    
    var alertWindow: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()!.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        setInitalViewController()
        configureStyling()
        
        return true
    }

    private func setInitalViewController() {
        if Auth.auth().currentUser != nil,
            let userData = UserDefaults.standard.object(forKey: "currentUser") as? Data,
            let user = try? JSONDecoder().decode(User.self, from: userData) {

            User.setCurrent(user)
            
            window?.setRootViewController(KifuTabBarViewController())
        } else {
            window?.setRootViewController(UINavigationController(rootViewController: FrontPageViewController()))
        }
        
        window?.makeKeyAndVisible()
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
        if let _ = error {
            //error.localizedDescription usually the user cancelled the sign in flow
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        let credentialDict = ["credentials": credential] as [String: Any]
        NotificationCenter.default.post(name: .userDidLoginWithGoogle, object: nil, userInfo: credentialDict)
    }
    
    func configureStyling() {
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.Text.Headline]
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.Text.Headline]
        UINavigationBar.appearance().tintColor = UIColor.Pallete.Green
        UINavigationBar.appearance().barTintColor = UIColor.Pallete.White
        UINavigationBar.appearance().isTranslucent = false
        
        UITabBar.appearance().tintColor = UIColor.Pallete.Green
        UITabBar.appearance().barTintColor = UIColor.Pallete.White
        UITabBar.appearance().isTranslucent = false
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
