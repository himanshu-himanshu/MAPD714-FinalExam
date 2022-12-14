//
//  AppDelegate.swift
//  MAPD714-Final-Exam
//
//  Created by Himanshu on 2022-12-14.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        self.launchScreen()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func launchScreen() {
        let launchScreenVC = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        let rootVC = launchScreenVC.instantiateViewController(withIdentifier: "splashScreen")
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissLaunchScreen), userInfo: nil, repeats: false)
        
    }
    
    @objc func dismissLaunchScreen() {
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil)
        let rootVC = mainVC.instantiateViewController(withIdentifier: "mainScreen")
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

