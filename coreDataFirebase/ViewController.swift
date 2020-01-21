//
//  ViewController.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 12/31/19.
//  Copyright © 2019 Abdelrahman-Arw. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var btnAddCategory: UIBarButtonItem!
    @IBOutlet weak var categoryTableView: UITableView!
    
    //MARK: - Variables
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let categoryModel = CategoryModel()
    //MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryModel.fetchFirebase(onSuccess: { response in
            for i in response {
                self.categories.append(i)
            }
            self.categoryTableView.reloadData()
        })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
    }
    
    //MARK: - Add Categories
    @objc func addTapped(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what will happen on tapping the action add button
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            let newCategory = Category(context: self.context)
            newCategory.title = textField.text!
            newCategory.isSynced = "No"
            newCategory.lastUpdated = result
            if let check = self.categoryModel.checkifExists(category: newCategory) {
                if !check.keys.first! {
                    self.categoryModel.saveCategory(category: newCategory)
                    self.categories.append(newCategory)
                    self.categoryTableView.reloadData()
                    
                } else {
                    if self.categoryModel.checkifUpdated(category: newCategory.lastUpdated!) {
                        self.categoryModel.saveCategory(category: newCategory)
                        self.categories.append(newCategory)
                        self.categoryTableView.reloadData()
                    }
                }
                
            }
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
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


