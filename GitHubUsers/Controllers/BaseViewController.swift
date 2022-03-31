    //
//  BaseViewController.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    enum DestinationType {
        case detail(userName: String)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.navigationBar.topItem?.title = self.cityName
    }
    
    func routeTo(_ destinationType: DestinationType) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch destinationType {
        case .detail(let userName):
            let detailController = storyBoard.instantiateViewController(withIdentifier: "UserDetail") as! UserDetailController
            detailController.userName = userName
            self.navigationController?.pushViewController(detailController, animated: true)
        }
    }
    
    func navigateBack() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
