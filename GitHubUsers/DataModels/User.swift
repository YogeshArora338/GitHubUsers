//
//  User.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import Foundation

struct User: Decodable, Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    let login: String
    let id: Int
    let avatar_url: String
    var imageData: Data?
}
