//
//  PostStatsViewController.swift
//  postStatsTest
//
//  Created by Vadym Sushko on 3/13/19.
//  Copyright © 2019 Vadym Sushko. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostStatsViewController: UIViewController {
    
    @IBOutlet weak var postStatsTableView: UITableView!
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Properties
    var postData: PostData? {
        didSet {
            loadLikers("id", (postData?.postId)!)
            loadCommentators("id", (postData?.postId)!)
            loadMentions("id", (postData?.postId)!)
            
            postStatsTableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableView.RowAnimation.fade)
            postStatsTableView.reloadRows(at: [IndexPath.init(row: 4, section: 0)], with: UITableView.RowAnimation.fade)
            postStatsTableView.reloadRows(at: [IndexPath.init(row: 5, section: 0)], with: UITableView.RowAnimation.fade)
        }
    }
    
    var postLikers = [UserData]() {
        didSet {
            let index = IndexPath(row: 1, section: 0)
            postStatsTableView.reloadRows(at: [index], with: UITableView.RowAnimation.fade)
            collectionCellCounter(index: index)
        }
    }
    
    var postCommentators = [UserData]() {
        didSet {
            let index = IndexPath(row: 2, section: 0)
            postStatsTableView.reloadRows(at: [index], with: UITableView.RowAnimation.fade)
            collectionCellCounter(index: index)
        }
    }
    var postMentions = [UserData]() {
        didSet {
            let index = IndexPath(row: 3, section: 0)
            postStatsTableView.reloadRows(at: [index], with: UITableView.RowAnimation.fade)
            collectionCellCounter(index: index)
        }
    }
    
    var postSlug: String = "LeBxOWT5zSemiSvkuqBLXFjXlaA0bJlX" // default value
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPostData("slug",postSlug)
        
    }
    
    //MARK:-  collection cells in the table cell counter
    func collectionCellCounter(index: IndexPath) {
        let collection = (postStatsTableView.cellForRow(at: index) as! PeopleTableViewCell).collectionView
        let cellsNumber = collection?.visibleCells.count ?? 0
        let leftCells = postLikers.count - cellsNumber
        if (leftCells) > 0 {
            let tableCell = postStatsTableView.cellForRow(at: index) as! PeopleTableViewCell
            UIView.animate(withDuration: 0.5) {
                tableCell.moreLabel.alpha = 1
                tableCell.moreArrow.alpha = 1
            }
            tableCell.moreLabel.text = "еще " + String(leftCells)
        }
    }
    
    // MARK:- Loading data functions
    func setUpRequest(urlString: String) -> URLRequest {
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + Token.token , forHTTPHeaderField: "Authorization")
        return request
    }
    
    func loadPostData(_ parameterName: String, _ parameterValue: String) {
        let parameters = [parameterName:parameterValue]
        var request = setUpRequest(urlString: "https://api.inrating.top/v1/users/posts/get")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        DispatchQueue.global(qos: .userInteractive).async {
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    let code = response.statusCode
                    print(code)
                    if (code >= 200 &&  code <= 299) {
                        
                        if let data = data {
                            do {
                                let json = try JSON(data: data)
                                
                                let postData = PostData(postId: (json["id"].stringValue), viewsCount: (json["views_count"].stringValue), likesCount: (json["likes_count"].stringValue), repostsCount: (json["reposts_count"].stringValue), bookmarksCount: (json["bookmarks_count"].stringValue), commentsCount: (json["comments_count"].stringValue))
                                
                                DispatchQueue.main.async {
                                    self.postData = postData
                                }
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        } }
                    else {
                        let alert = UIAlertController(title: "Wrong slug", message: "Please, enter correct data", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                        
                    }
                }
                }.resume()
        }
    }
    
    func loadLikers(_ parameterName: String, _ parameterValue: String) {
        let parameters = [parameterName:parameterValue]
        var request = setUpRequest(urlString: "https://api.inrating.top/v1/users/posts/likers/all")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        DispatchQueue.global(qos: .userInteractive).async {
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        let nickNames = json["data"].arrayValue.map({$0["nickname"].stringValue})
                        let avatarImageUrls = json["data"].arrayValue.map({$0["avatar_image"]["url_small"].stringValue})
                        
                        var likers = [UserData]()
                        
                        for i in 0 ..< nickNames.count {
                            let liker = UserData(nickName: nickNames[i], avatarImageUrl: avatarImageUrls[i])
                            likers.append(liker)
                        }
                        DispatchQueue.main.async {
                            self.postLikers = likers
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                }.resume()
        }
    }
    
    func loadCommentators(_ parameterName: String, _ parameterValue: String) {
        let parameters = [parameterName:parameterValue]
        var request = setUpRequest(urlString: "https://api.inrating.top/v1/users/posts/commentators/all")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        DispatchQueue.global(qos: .userInteractive).async {
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        let nickNames = json["data"].arrayValue.map({$0["nickname"].stringValue})
                        let avatarImageUrls = json["data"].arrayValue.map({$0["avatar_image"]["url_small"].stringValue})
                        
                        var commentators = [UserData]()
                        
                        for i in 0 ..< nickNames.count {
                            let commentator = UserData(nickName: nickNames[i], avatarImageUrl: avatarImageUrls[i])
                            commentators.append(commentator)
                        }
                        DispatchQueue.main.async {
                            self.postCommentators = commentators
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                }.resume()
        }
    }
    func loadMentions(_ parameterName: String, _ parameterValue: String) {
        let parameters = [parameterName:parameterValue]
        var request = setUpRequest(urlString: "https://api.inrating.top/v1/users/posts/mentions/all")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        request.httpBody = httpBody
        
        DispatchQueue.global(qos: .userInteractive).async {
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        let nickNames = json["data"].arrayValue.map({$0["nickname"].stringValue})
                        let avatarImageUrls = json["data"].arrayValue.map({$0["avatar_image"]["url_small"].stringValue})
                        var mentions = [UserData]()
                        
                        for i in 0 ..< nickNames.count {
                            let mention = UserData(nickName: nickNames[i], avatarImageUrl: avatarImageUrls[i])
                            mentions.append(mention)
                        }
                        DispatchQueue.main.async {
                            self.postMentions = mentions
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                }.resume()
        }
    }
}

//MARK:-  TableView Delegate and DataSource
extension PostStatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 || row == 4  || row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "narrowCell", for: indexPath) as! TextTableViewCell
            switch row {
            case 0:
                cell.cellLabel.text = "Просмотры " + (self.postData?.viewsCount ?? "")
                cell.cellImage.image = #imageLiteral(resourceName: "views")
            case 4:
                cell.cellLabel.text = "Репосты " + (self.postData?.repostsCount ?? "")
                cell.cellImage.image = #imageLiteral(resourceName: "reposts")
            case 5:
                cell.cellLabel.text = "Закладки " + (self.postData?.bookmarksCount ?? "")
                cell.cellImage.image = #imageLiteral(resourceName: "bookmark")
            default:
                break
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wideCell", for: indexPath) as! PeopleTableViewCell
            switch row {
            case 1:
                cell.cellLabel.text = "Лайки " + String(self.postLikers.count)
                cell.cellImage.image = #imageLiteral(resourceName: "like")
            case 2:
                cell.cellLabel.text = "Комментаторы " + String(self.postCommentators.count)
                cell.cellImage.image = #imageLiteral(resourceName: "comment")
            case 3:
                cell.cellLabel.text = "Отметки " + String(self.postMentions.count)
                cell.cellImage.image = #imageLiteral(resourceName: "mention")
                
            default:
                break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 5 {
            return 40
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell:UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 0 || indexPath.row != 4 || indexPath.row != 5 {
            if let cell = cell as? PeopleTableViewCell {
                cell.collectionView.dataSource = self
                cell.collectionView.delegate = self
                cell.collectionView.tag = indexPath.row
                cell.collectionView.reloadData()
            }
        }
    }
}
//MARK:-  CollectionView Delegate and DataSource
extension PostStatsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return postLikers.count
        } else if collectionView.tag == 2 {
            return postCommentators.count
        } else if collectionView.tag == 3 {
            return postMentions.count
        }  else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! AvatarCollectionViewCell
        if collectionView.tag == 1 {
            cell.name.text = postLikers[indexPath.item].nickName
            cell.avatarImage.load(url: URL(string: postLikers[indexPath.item].avatarImageUrl)!)
        } else if collectionView.tag == 2 {
            cell.name.text = postCommentators[indexPath.item].nickName
            cell.avatarImage.load(url: URL(string: postCommentators[indexPath.item].avatarImageUrl)!)
        } else if collectionView.tag == 3 {
            cell.name.text = postMentions[indexPath.item].nickName
            cell.avatarImage.load(url: URL(string: postMentions[indexPath.item].avatarImageUrl)!)
        }
        cell.avatarImage.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemHeight - 21, height: itemHeight - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var dataSource = postLikers
        if collectionView.tag == 2 {
            dataSource = postCommentators
        } else if collectionView.tag == 3 {
            dataSource = postMentions
        }
        
        let tableCell = postStatsTableView.cellForRow(at: IndexPath(row: collectionView.tag, section: 0)) as! PeopleTableViewCell
        
        let visCells = collectionView.visibleCells.count
        let leftCells = dataSource.count - indexPath.row
        
        if leftCells > dataSource.count - visCells {
            let leftCell = leftCells - visCells
            tableCell.moreLabel.text = "еще " + String(leftCell)
        } else {
            tableCell.moreLabel.text = "еще " + String(leftCells)
        }
        
        if (indexPath.row == dataSource.count - 1) {
            UIView.animate(withDuration: 0.5) {
                tableCell.moreLabel.text = "еще " + String(leftCells)
                tableCell.moreLabel.alpha = 0
                tableCell.moreArrow.alpha = 0
            }
        }
    }
}

//MARK:-  UIImage extantion for getting images from url
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
