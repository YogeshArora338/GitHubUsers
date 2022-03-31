//
//  UserDetailController.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import UIKit

final class UserDetailController: BaseViewController {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblCreationDate: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    internal var userName: String?
    
    private var userDetail: UserDetail? {
        didSet {
            self.userDetailDidUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUserDetail()
    }
    
    // MARK: - Private Functions
    private func loadUserDetail() {
        if let userName = userName {
            self.startActivity()
            let apiManager = APIManager()
            apiManager.getUserDetail(for: userName) { detail in
                self.stopActivity()
                self.userDetail = detail
            }
        } else {
            ErrorHelper.showNormalAlert(with: ErrorMessages.INVALID_USER_NAME, parent: self) {
                self.navigateBack()
            }
        }
    }
    
    private func userDetailDidUpdate() {
        guard let userDetail = userDetail else {
            DispatchQueue.main.async { [weak self] in
                ErrorHelper.showRetryAlert(with: ErrorMessages.RETRY_SINGLE_RECORD,
                                           parent: self ?? nil) { shouldRetry in
                    if shouldRetry {
                        self?.loadUserDetail()
                    } else {
                        self?.navigateBack()
                    }
                }
            }
            return
        }
        
        self.loadImage()
        
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.title = userDetail.name
            self?.lblName.text = userDetail.displayName
            self?.lblCompany.text = userDetail.displayCompanyName
            self?.lblEmail.text = userDetail.displayEmail
            self?.lblFollowingCount.text = userDetail.displayFollowing
            self?.lblFollowersCount.text = userDetail.displayFollowers
            self?.lblCreationDate.text = userDetail.displayCreatedAt
        }
    }
    
    private func loadImage() {
        guard let userDetail = userDetail else {
            return
        }
        
        if let imageData = userDetail.imageData {
            self.loadImage(with: imageData)
        } else {
            DispatchQueue.global().async {
                if let url = URL(string: userDetail.avatar_url) {
                    if let data = try? Data(contentsOf: url) {
                        self.loadImage(with: data)
                    }
                }
            }
        }
    }
    
    private func loadImage(with data: Data) {
        DispatchQueue.main.async { [weak self] in
            self?.avatarView.image = UIImage(data: data)
        }
    }
    
    private func startActivity() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    private func stopActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }
}
