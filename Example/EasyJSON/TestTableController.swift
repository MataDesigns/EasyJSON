//
//  ViewController.swift
//  EasyJSON
//
//  Created by Nicholas Mata on 09/25/2016.
//  Copyright (c) 2016 Nicholas Mata. All rights reserved.
//

import UIKit
import EasyJSON
import Alamofire

class Company: EasyModel {
    var name: String?
    var catchPhrase: String?
    var bs: String?
}

class Coordinate: EasyModel {
    var lat: String?
    var lng: String?
}

class Address: EasyModel {
    var street: String?
    var suite: String?
    var city: String?
    var zipcode: String?
    var geo: Coordinate?
    
    override var subObjects: [String : AnyClass] {
        return ["geo": Coordinate.self]
    }
}

class UserModel: EasyModel {
    
    var id: Int = -1
    
    var name: String?
    var username: String?
    var email: String?
    
    var address: Address?
    
    var phone: String?
    var website: String?
    var company: Company?
    
    override var subObjects: [String : AnyClass] {
        return ["address": Address.self, "company" : Company.self]
    }
}

class UserCell: UITableViewCell {
    static var reuseIdentifier = "UserCell"
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
}

class TestTableController: UITableViewController {
    
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getUsers()
    }
    
    func getUsers() {
        Alamofire.request("https://jsonplaceholder.typicode.com/users", method: .get).responseJSON { (response) in
            switch(response.result) {
            case .failure(let error):
                print(error)
            case .success(let data):
                if let jsonObjects = data as? [[String: Any]] {
                    for jsonObject in jsonObjects {
                        let user = UserModel()
                        // Fills the user variable with the provided json dictionary.
                        user.fill(withDict: jsonObject)
                        self.users.append(user)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
        if let user = users[safe: indexPath.row] {
            // TO UNDERSTAND: Set breakpoint here to view the user variable with data from json.
            cell.fullNameLabel.text = user.name
            cell.emailLabel.text = user.email
            cell.companyLabel.text = user.company?.name
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
