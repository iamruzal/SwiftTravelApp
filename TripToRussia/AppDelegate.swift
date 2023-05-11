//
//  AppDelegate.swift
//  city
//
//  Created by Рузаль Назмутдинов on 04.10.2022.
//

import UIKit
import YandexMapsMobile
import Firebase
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        YMKMapKit.setApiKey("8f7cae19-43af-40db-b92d-80439dcdcc85")
        YMKMapKit.sharedInstance()
        FirebaseApp.configure()
       
       
            Auth.auth().addStateDidChangeListener { (auth, user) in
                if user != nil {
                    print("Пользователь уже успешно авторизован")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                                vc.navigationItem.hidesBackButton = true
                                UIApplication.shared.keyWindow?.rootViewController = vc

                } else {
                    print("Пользователь еще не авторизован.")
                 
                }
            }
            

        
        
        return true
    }
   

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

