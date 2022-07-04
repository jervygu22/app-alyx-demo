//
//  AuthManager.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

//import Foundation
import UIKit
import CoreData

// 1. get token
// 2. get all user
// 3. cached user credential - userdefaults
// 4  use loggedin credential to get all user,categories, products, etc
// 5. sign in with 4 pin code
// 6. push menuVC

/// Managers - are objects in the app that allows us to perform operations across the whole app
final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var refreshingToken = false
    
//    struct Constants {
//        static let redirectURI = "https://jervygu.wixsite.com/iosdev"
//        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email%20user-read-recently-played"
//
//        static let username = "user"
//        static let password = "ZJQ0K5EZxAe1"
//        static let tokenAPIURL = "https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/token"
//        static let baseURL = "https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves"
//
//        static let isAuthorized = "is_authorized"
//    }
    
    var isLoggedIn: Bool {
//        return accessToken != nil // && pinCode != nil
        return userName != nil // && pinCode != nil
//        return false
    }
    
    var isHaveVerifiedDomain: Bool {
        return domainName != nil
    }
    
    var doesHaveCachedDeviceID: Bool {
        return cachedDeviceID != nil
    }
    
    private var pinCode: String? = {
       return nil
    }()
    
    public var accessToken: String? = {
//        return UserDefaults.standard.string(forKey: "access_token")
        
        let storedToken = CartViewController.shared.returnStoredToken()
        return storedToken
    }()
    
    public var cachedDeviceID: String? = {
        return UserDefaults.standard.string(forKey: "generated_device_id")
    }()
    
    public var domainName: String? = {
        return UserDefaults.standard.string(forKey: "domain_name")
    }()
    
    public var userID: String? = {
        return UserDefaults.standard.string(forKey: "user_id")
    }()
    
    public var userPin: String? = {
        return UserDefaults.standard.string(forKey: "user_pin")
    }()
    
    public var userName: String? = {
        return UserDefaults.standard.string(forKey: "user_name")
    }()
    
    public var pinEnteredUsername: String? = {
        return UserDefaults.standard.string(forKey: "pin_entered_username")
    }()
    
    public var pinCodeEntered: String? = {
        return UserDefaults.standard.string(forKey: "pin_code_entered")
    }()
    
    public var pin_entered_employee_shift: String? = {
        return UserDefaults.standard.string(forKey: "pin_entered_employee_shift")
    }()
    
    public var pin_entered_user_id: String? = {
        return UserDefaults.standard.string(forKey: "pin_entered_user_id")
    }()
    
    public var pin_entered_user_image: String? = {
        return UserDefaults.standard.string(forKey: "pin_entered_user_image")
    }()
    
    public var pin_entered_user_roles: [String]? = {
        return UserDefaults.standard.stringArray(forKey: "pin_entered_user_roles")
    }()
    
    public var userEmail: String? = {
        return UserDefaults.standard.string(forKey: "")
    }()
    
    private var refreshToken: String? = {
        return nil
    }()
    
    private var tokenExpirationDate: Date? = {
        return nil
    }()
    
    private var shouldRefreshToken: Bool = {
        return false
    }()
    
    private var onRefreshBlocks = [((String) -> Void)]()
    
    
    public func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.token, forKey: "access_token")
    }
    
    public func shouldClearSavedUserData() {
        // Clear Credentials and cached user data
        
        // access tokens
        UserDefaults.standard.setValue(nil, forKey: Constants.access_token)
        UserDefaults.standard.setValue(nil, forKey: Constants.access_token2)
        
        // supervisor
        UserDefaults.standard.setValue(nil, forKey: Constants.user_id)
        UserDefaults.standard.setValue(nil, forKey: Constants.user_name)
        UserDefaults.standard.setValue(nil, forKey: Constants.user_email)
        UserDefaults.standard.setValue(nil, forKey: Constants.user_pin)
        UserDefaults.standard.setValue(nil, forKey: Constants.is_user_handle_cash)
        UserDefaults.standard.setValue(nil, forKey: Constants.user_role)
        UserDefaults.standard.setValue(nil, forKey: Constants.user_emp_id)
        
        // cashier
        UserDefaults.standard.setValue(nil, forKey: Constants.pin_code_entered)
        UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_id)
        UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_username)
        UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_roles)
        UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_user_image)
        UserDefaults.standard.setValue(nil, forKey: Constants.pin_entered_employee_shift)
        
        UserDefaults.standard.setValue(nil, forKey: Constants.date_since_last_update)
        UserDefaults.standard.setValue(nil, forKey: Constants.isAuthorized)
        UserDefaults.standard.setValue(nil, forKey: Constants.domain_name)
    }
}
