//
//  UserEntity.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import RealmSwift

class UserEntity: Object {
    @objc dynamic var login: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var imageData: Data?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(user: User) {
        self.init()
        self.login = user.login
        self.id = user.id
        if let imgData =  user.avatar_url.convertToData() {
            self.imageData = imgData
        }
    }
}

extension String {
    func convertToData() -> Data? {
        if let url = URL(string: self){
            do {
                if let imgData = try? Data(contentsOf: url) {
                    return imgData
                }
            }
        }
        return nil
    }
}

extension UserEntity {
    func mapToUser() -> User {
        let user: User = .init(login: self.login, id: self.id, avatar_url: "", imageData: self.imageData as Data?)
        return user
    }
}
