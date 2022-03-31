//
//  APIManager.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import Foundation

protocol APIManagerProtocol{
    func getUsersList(since id: Int, completion: @escaping ([User]?) -> Void)
    func getUserDetail(for userName: String, completion: @escaping (UserDetail?) -> Void)
}

struct APIManager: APIManagerProtocol {
    static let baseURL: String = "https://api.github.com/"
    static let usersNode: String = "users"
    
    let dataSaveQueue = DispatchQueue(label: "BackgroundQueue", qos: .background, attributes: .concurrent)
    
    func getUsersList(since id: Int, completion: @escaping ([User]?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            self.getLastStoredUserList(completion: completion)
            return
        }
        
        var fullUrl = "\(APIManager.baseURL)\(APIManager.usersNode)"
        
        if id > 0 {
            fullUrl.append("?since=\(id)")
        }
        
        guard let url = URL(string: fullUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                print(ErrorMessages.TRYINGCACHE)
                self.getLastStoredUserList(completion: completion)
                return
            }
            
            guard let data = data else {
                print(ErrorMessages.NILDATA)
                self.getLastStoredUserList(completion: completion)
                return
            }

            do {
                let json = try JSONDecoder().decode([User].self, from: data)
                self.saveUserList(users: json)
                completion(json)
            } catch {
                print(ErrorMessages.NOTABLETODECODE)
                self.getLastStoredUserList(completion: completion)
            }
        }
        .resume()
    }
    
    
    
    func getUserDetail(for userName: String, completion: @escaping (UserDetail?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            self.getLastStoreUserDetail(for: userName, completion: completion)
            return
        }
        
        let fullUrl = "\(APIManager.baseURL)\(APIManager.usersNode)/\(userName)"
        guard let url = URL(string: fullUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                self.getLastStoreUserDetail(for: userName, completion: completion)
                return
            }
            
            guard let data = data else {
                print(ErrorMessages.NILDATA)
                self.getLastStoreUserDetail(for: userName, completion: completion)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(UserDetail.self, from: data)
                self.saveUserDetail(detail: json)
                completion(json)
            } catch {
                print(ErrorMessages.NOTABLETODECODE)
                self.getLastStoreUserDetail(for: userName, completion: completion)
            }
        }
        .resume()
    }
    
    private func getLastStoredUserList(completion: @escaping ([User]?) -> Void) {
        let list = DataManager.fetchUserList(type: UserEntity.self)
        let userList = list.map { $0.mapToUser() }
        if !userList.isEmpty {
            completion(userList)
        } else {
            completion(nil)
        }
    }
    
    private func getLastStoreUserDetail(for userName: String, completion: @escaping (UserDetail?) -> Void) {
        if let item = DataManager.fetchDetail(for: userName, type: UserDetailEntity.self) {
            completion(item.mapToUserDetail())
        } else {
            completion(nil)
        }
    }
    
    // MARK: - Saving into local storage
    private func saveUserList(users: [User]) {
        if users.isEmpty {
            return
        }
        
        self.dataSaveQueue.async {
            for user in users {
                let userEntity: UserEntity = .init(user: user)
                DataManager.addUser(userEntity)
            }
        }
    }
    
    private func saveUserDetail(detail: UserDetail) {
        self.dataSaveQueue.async {
            let userEntity: UserDetailEntity = .init(detail: detail)
            DataManager.addUserDetail(userEntity)
        }
    }
}
