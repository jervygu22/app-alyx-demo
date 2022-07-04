//
//  UserDefaultsManager.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 3/1/22.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    let defaults = UserDefaults(suiteName: "com.codedisruptors.alyx-dev")
    
}
