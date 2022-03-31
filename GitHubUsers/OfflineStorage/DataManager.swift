//
//  DataManager.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import Foundation
import RealmSwift

class DataManager {
    static func addUser<T: Object> (_ user: T) {
       let realmWrite = try! Realm()
           do {
               try realmWrite.write({
                   realmWrite.add(user, update: .modified)
               })
           } catch {
               print(error.localizedDescription)
           }
    }
    
    static func addUserDetail<T: Object> (_ userDetail: T) {
        let realmWrite = try! Realm()
        do {
            try realmWrite.write({
                realmWrite.add(userDetail, update: .modified)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fetchUserList<T: Object> (type: T.Type) -> [T] {
        // Read from Realm
        let realmRead = try! Realm()
        lazy var userList: Results<T> = { realmRead.objects(T.self) }()
        return userList.toArray()
    }
    
    static func fetchDetail<T: Object>(for login: String, type: T.Type) -> T? {
        let realm = try! Realm()
        guard let data = realm.object(ofType: type, forPrimaryKey: login) else { return nil }
        return data
    }
}

extension Results {
    func toArray() -> [Element] {
        return compactMap { $0 }
    }
}

extension Realm {
    func writeAsync<T: ThreadConfined> (obj: T, errorHandler: @escaping( (_ error: Swift.Error) -> Void) = { _ in return }, block: @escaping ( ( Realm, T?)-> Void)) {
        
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)
                    
                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}
