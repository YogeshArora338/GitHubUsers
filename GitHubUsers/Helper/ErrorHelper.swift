//
//  ErrorHelper.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 31/03/22.
//

import UIKit

final class ErrorHelper {
    static func showRetryAlert(with message: String, parent: UIViewController?, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            completion(true) // Should retry
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            completion(false)
        }))
        
        parent?.present(alert, animated: true, completion: nil)
    }
    
    static func showNormalAlert(with message: String, parent: UIViewController?, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        
        parent?.present(alert, animated: true, completion: nil)
    }
}
 
