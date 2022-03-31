//
//  UserDetailEntity.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import RealmSwift

class UserDetailEntity: Object {
    @objc dynamic var login: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var email: String?
    @objc dynamic var company: String?
    @objc dynamic var following: Int = 0
    @objc dynamic var followers: Int = 0
    @objc dynamic var created_at: String = ""
    @objc dynamic var imageData: Data?
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    convenience init(detail: UserDetail) {
        self.init()
        self.login = detail.login
        self.name = detail.name
        self.email = detail.email
        self.company = detail.company
        self.created_at = detail.created_at
        
        if let value = detail.following {
            self.following = value
        }
        
        if let value = detail.followers {
            self.followers = value
        }
        
        
        if let imgData =  detail.avatar_url.convertToData() {
            self.imageData = imgData
        }
    }
}

extension UserDetailEntity {
    func mapToUserDetail() -> UserDetail {
        let userDetail: UserDetail = .init(login: self.login, avatar_url: "", name: self.name, email: self.email, company: self.company, following: self.following, followers: self.followers, created_at: self.created_at, imageData: self.imageData)
        return userDetail
    }
}
