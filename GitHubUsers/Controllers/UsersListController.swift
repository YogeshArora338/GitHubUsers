//
//  ViewController.swift
//  GitHubUsers
//
//  Created by Yogesh Arora on 30/03/22.
//

import UIKit

class UsersListController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    private let apiManager: APIManager = APIManager()
    private var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Users"
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.loadData()
    }
    
    // MARK: - Private Functions
    private func loadData() {
        self.startActivity()
        var id: Int = -1
        if let lastItem = self.users.last {
            id = lastItem.id
        }
        
        self.apiManager.getUsersList(since: id) { items in
            self.stopActivity()
            self.handleResponse(items)
        }
    }
    
    private func handleResponse(_ users: [User]?) {
        if let items = users {
            self.users.append(contentsOf: items)
            self.users.removeDuplicates()
            self.contentsDidUpdate()
        }
        
        // If it is still empty then considering might be no information found online as well as offline
        if self.users.isEmpty {
            DispatchQueue.main.async { [weak self] in
                ErrorHelper.showRetryAlert(with: ErrorMessages.RETRY,
                                           parent: self ?? nil) { shouldRetry in
                    if shouldRetry {
                        self?.loadData()
                    }
                }
            }
        }
    }
    
    private func startActivity() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    private func stopActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }
    
    private func contentsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Action
    @objc func refresh(_ sender: AnyObject) {
        self.users.removeAll()
        self.loadData()
    }
}

// MARK: - Table View DataSource
extension UsersListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        
        if let imageData = self.users[indexPath.row].imageData {
            cell.avatarView.image = UIImage(data: imageData)
        } else {
            DispatchQueue.global().async {
                if let url = URL(string: self.users[indexPath.row].avatar_url) {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async { [weak cell] in
                            cell?.avatarView.image = UIImage(data: data)
                            // Caching image data so that it will not fetch again
                            self.users[indexPath.row].imageData = data
                        }
                    }
                }
            }
        }
        
        cell.title.text = self.users[indexPath.row].login
        cell.subtitle.text = String(self.users[indexPath.row].id)
        self.loadNextPageIfNeeded(for: indexPath)
        
        return cell
    }
    
    private func loadNextPageIfNeeded(for indexPath: IndexPath) {
        // Do not load next page if network is not reachable
        if !Reachability.isConnectedToNetwork() {
            return
        }
        
        guard self.shouldLoadNextPage(for: indexPath) else { return }
        self.loadData()
    }
    
    private func shouldLoadNextPage(for indexPath: IndexPath) -> Bool {
        return indexPath.row > (self.users.count - 5)
    }
}

extension UsersListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: User = self.users[indexPath.row]
        self.routeTo(.detail(userName: user.login))
    }
}
