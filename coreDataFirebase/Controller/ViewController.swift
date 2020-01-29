//
//  ViewController.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 12/31/19.
//  Copyright © 2019 Abdelrahman-Arw. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var btnAddCategory: UIBarButtonItem!
    @IBOutlet weak var categoryTableView: UITableView!
    
    
    //MARK: - Variables
    let context = DataStack().persistentContainer.viewContext
    
    var categories = [Category]()
    var refreshControl = UIRefreshControl()
    let categoriesRepo = CategoryRepository(url: "http://localhost:3000/categories", isSynced: "isSynced", uniqueID: "uniqueID")
    
    //MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        self.categoryTableView.reloadData()
        SetupRefreshControl()
        
    }
    
    
    func SetupRefreshControl(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        categoryTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
            checkForBackEndData()
        
    }
    
    //MARK: - Data population methods
    func getData(){
        categories = categoriesRepo.fetchObjects(in: context) { (request) in
            
        }
        
        checkForBackEndData()
    }
    func checkForBackEndData(){
        var backendCategories = [Category]()
        categoriesRepo.fetchDataBackEnd() { (response) in
            for i in response {
                var newCategory = Category(context: self.context)
                self.categoriesRepo.loadFromJson(i, in: self.context, with: newCategory, onSuccess: { (result) in
                    newCategory = result as! Category
                    if let _ = newCategory.uniqueID {
                        let c = self.categoriesRepo.checkExistence(in: self.context, objectUniqueID: newCategory.uniqueID!)
                        if c.count == 1 {
                            self.categoriesRepo.saveObjects(in: self.context, object: result as! Category)
                            backendCategories.append(result as! Category)
                        }
                    }
                })
            }
            if backendCategories.count > 0 {
                for i  in backendCategories {
                    self.categories.append(i)
                }
                self.showAlertNewData()
            }
        }

        refreshControl.endRefreshing()
    }
    
    func showAlertNewData(){
        let alert = UIAlertController(title: "Alert", message: "New Data Available", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { action in
            self.categoryTableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.saveCategory(category: categories[indexPath.row])
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsVC
        if let indexPath = categoryTableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}


