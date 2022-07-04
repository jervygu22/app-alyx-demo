//
//  AppDelegate.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//
// App ID Prefix - UH3KRKPDYQ

import UIKit
import CoreData
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        
//        let watermark = UIImageView()
//        watermark.image = UIImage(systemName: "photo")
//        watermark.backgroundColor = .red
//        watermark.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
//        window.addSubview(watermark)
            
        if AuthManager.shared.isLoggedIn {
            window.rootViewController = UINavigationController(rootViewController: MenuViewController())
            UINavigationBar.appearance().barTintColor = .black  // solid color
            UINavigationBar.appearance().barStyle = .black // Battery,etc bar always white
            UINavigationBar.appearance().isTranslucent = false // not see through
            UIBarButtonItem.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            UITabBar.appearance().barTintColor = .yellow // tabBar
        } else if AuthManager.shared.isHaveVerifiedDomain && AuthManager.shared.doesHaveCachedDeviceID {
            let navVC = UINavigationController(rootViewController: UserLoginViewController(deviceID: nil))
            navVC.navigationBar.prefersLargeTitles = false
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
            UINavigationBar.appearance().barTintColor = .black  // solid color
            UINavigationBar.appearance().barStyle = .black // Battery,etc bar always white
            UINavigationBar.appearance().isTranslucent = false // not see through
            UIBarButtonItem.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            UITabBar.appearance().barTintColor = .yellow // tabBar
            window.rootViewController = navVC
        } else {
            let navVC = UINavigationController(rootViewController: DomainViewController())
            navVC.navigationBar.prefersLargeTitles = false
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .never
            UINavigationBar.appearance().barTintColor = .black  // solid color
            UINavigationBar.appearance().barStyle = .black // Battery,etc bar always white
            UINavigationBar.appearance().isTranslucent = false // not see through
            UIBarButtonItem.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            UITabBar.appearance().barTintColor = .yellow // tabBar
            window.rootViewController = navVC
        }
        
        window.makeKeyAndVisible()
        self.window = window
        
//        print("DeviceID: ", UIDevice.current.identifierForVendor?.uuidString)
        // 50E5BDE6-CE6A-4A76-898F-A7A5426C497F
        // EB7481EA-5D35-4B48-AE5B-1D13130DB6C6 - myiPhone7
        print("USERDEFAULTS: ",NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
// /Users/mac/Library/Developer/CoreSimulator/Devices/6239E472-AD74-4ADE-92FE-A282FA16D6AC/data/Containers/Data/Application/25AD6B41-8CF8-4CCC-8F71-3A4E14F6D682/Library/Preferences
        
        
//        print("Access token cached: ", UserDefaults.standard.string(forKey: "access_token") ?? "token empty")
//        print("Pin Code cached: ", UserDefaults.standard.string(forKey: "pin_code") ?? "code empty")
        
        
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
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

