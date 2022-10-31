//
//  UserDefaultsInstagramDataPersistingProvider.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import Foundation

class UserDefaultsInstagramDataPersistingProvider: InstagramDataPersistingProviding {
    
    //MARK: - IVars
    
    private let userKey = "user"
    
    var userDefaults: UserDefaults
    
    //MARK: - Lifecycle
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    //MARK: - InstagramDataPersistingProviding
    
    func store(user: InstagramUser?) {
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: userKey)
        } catch {
            print("Failed to store user in user defaults: \(userDefaults)")
        }
    }
    
    func loadExistingUser() -> InstagramUser? {
        if let data = userDefaults.data(forKey: userKey), let user = try? JSONDecoder().decode(InstagramUser.self, from: data) {
            return user
        }
        return nil
    }
}
