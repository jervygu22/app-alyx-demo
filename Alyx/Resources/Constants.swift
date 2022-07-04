//
//  Constants.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import UIKit

struct Constants {
    // UserDefaults Identifier
    
    static let version = "v1.1.24"
    static let buildNumber = "1.1.24"
    
    static let app_logo = "alyx_logo"
    
    static let access_token = "access_token"
    static let access_token2 = "access_token2"
    static let token_user_email = "token_user_email"
    static let token_user_nicename = "token_user_nicename"
    static let token_user_display_name = "token_user_display_name"
    static let domain_name = "domain_name"
    
    static let machine_id = "machine_id"
    
    static let isAuthorized = "is_authorized"
    static let user_id = "user_id"
    static let user_name = "user_name"
    static let user_email = "user_email"
    static let user_pin = "user_pin"
    static let pin_entered_username = "pin_entered_username"
    static let pin_entered_employee_shift = "pin_entered_employee_shift"
    static let pin_entered_user_image = "pin_entered_user_image"
    static let pin_entered_user_roles = "pin_entered_user_roles"
    static let pin_entered_user_id = "pin_entered_user_id"
    static let pin_entered_work_date = "pin_entered_work_date"
    
    
    static let is_user_handle_cash = "is_user_handle_cash"
    static let user_role = "user_role"
    static let user_emp_id = "user_emp_id"
    
    static let is_initial_sent = "is_initial_sent"
    
    static let date_since_last_update = "date_since_last_update"
    
    static let generated_device_id = "generated_device_id"
    
    static let pin_code_entered = "pin_code_entered"
    
    static let vcBackgroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1)
    
    static let vcBackgroundCGColor = CGColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1)
    static let passcodeBackGroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1)
    static let whiteBackgroundColor: UIColor = .white
    static let drawerBackgroundColor: UIColor = .black
    static let drawerTableBackgroundColor: UIColor = .black
    static let blackBackgroundColor: UIColor = .black
    static let drawerTableViewCellBackgroundColor: UIColor = .black
    static let iconColor: UIColor = .white
    static let drawerLabelColor: UIColor = .white
    static let whiteLabelColor: UIColor = .white
    static let blackLabelColor: UIColor = .black
    static let secondaryLabelColor: UIColor = .lightGray
    static let secondaryDarkLabelColor: UIColor = .darkGray
    
    static let pwdLabelColor: UIColor = .orange
    static let seniorLabelColor: UIColor = .brown
    
    static let secondaryBackgroundColor: UIColor = .lightGray
    static let lightGrayBorderColor: UIColor = .lightGray
    static let darkGrayColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
    static let lightGrayColor: UIColor = .lightGray
    
    static let darkGrayCGColor = CGColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1)
    static let systemRedColor: UIColor = .systemRed
    static let collectionViewCellColor: UIColor = .white
    static let tableViewCellColor: UIColor = .white
    static let clearColor: UIColor = .clear
    
    static let redirectURI = "https://jervygu.wixsite.com/iosdev"
    
    static let franchiseesURL = "https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves/franchisees"

    static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email%20user-read-recently-played"
    
    static let username2 = "ck_76f64b8ad41a6dc4a4538f2e6227ad59b8bc07d1"
    static let password2 = "cs_ee2c14476230985b7953c2b648e20b2f9dec00e4"
    static let pubg101Url = URL(string: "https://raw.githubusercontent.com/jervygu/json-pubg101/master/pubg-weapons.json")
    
    
    static let username = "user" //"user"
    static let password = "RBQ51iAnjz2U" //"12345aA!" //"ZJQ0K5EZxAe1"
//    static let https = "https://"
    static let https = "https://alyx.codedisruptors.com/" //alyx-staging.codedisruptors.com/        //then domain
    static let httpsAuthV1 = "/wp-json/jwt-auth/v1/jeeves" //"https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves"
    
    static let httpsAuthV2 = "/wp-json/jwt-auth/v2/jeeves"
    static let httpsAuthV3 = "/wp-json/jwt-auth/v3/jeeves"
    
    static let httpsWCV3 = "/wp-json/wc/v3"
    
    static let tokenAPIURL = "/wp-json/jwt-auth/v1/token?" //"/wp-json/jwt-auth/v1/token?"
//    jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/token?
    
    static let tokenAPIURLinc = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v1/token" //"jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/token"
    
    static let baseURL = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v1/jeeves" //"https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves"
    static let baseURLV2 = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v2/jeeves" //"https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves"
    static let postDeviceID = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v1/jeeves/device?device_id=" //"https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves/device?device_id="
    
    static let productsUrl = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v1/jeeves/products/" //"https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves/products/"
    static let postOrder = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/wc/v3/orders" //"https://jeeves-reboot.codedisruptors.com/wp-json/wc/v3/orders"
    static let postCashCount = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/jwt-auth/v1/jeeves/cash" //"https://jeeves-reboot.codedisruptors.com/wp-json/jwt-auth/v1/jeeves/cash"
    
    static let updateCoupon = "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/wc/v3/coupons/"
    
    static let voidOrder =    "https://alyx-staging.codedisruptors.com/new-franchisee/wp-json/wc/v3/orders/"
    
    
    // Test APIs
    static let testShifts = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/shifts.json")
    static let testCategories = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/category.json")
    static let testProducts = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/products.json")
    static let testQueue = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/queue.json")
    static let testQueueOrders = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/queue_orders.json")
    static let testCartData = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/cart.json")
    static let testScheduleData = URL(string: "https://raw.githubusercontent.com/jervygu/jeeves-test-api/master/shifts.json")
    
    static let testUrl = URL(string: "https://raw.githubusercontent.com/jervygu/json-pubg101/master/pubg-weapons.json")
}
