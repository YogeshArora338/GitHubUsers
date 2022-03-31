//
//  UserDetail.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import Foundation

struct UserDetail: Decodable {
    let login: String
    let avatar_url: String
    let name: String
    let email: String?
    let company: String?
    let following: Int?
    let followers: Int?
    let created_at: String
    let imageData: Data?
}

extension UserDetail {
    var displayName: String {
        return "Name: \(self.name)"
    }
    
    var displayCompanyName: String {
        return "Company: \(self.company ?? "")"
    }
    
    var displayEmail: String {
        return "Email: \(self.email ?? "")"
    }
    
    var displayFollowing: String {
        return "Following: \(self.following ?? 0)"
    }
    
    var displayFollowers: String {
        return "Follower: \(self.followers ?? 0)"
    }
    
    var displayCreatedAt: String {
        return "Created At: \(self.created_at)"
    }
}
