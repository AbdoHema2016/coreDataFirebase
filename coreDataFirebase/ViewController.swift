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
    var ref: DatabaseReference!
    
    //MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        loadCategories()

        
    }
    
    //MARK: - Add Categories
    @objc func addTapped(){
        print("button pressed")
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what will happen on tapping the action add button
            
            let newCategory = Category(context: self.context)
            newCategory.title = textField.text!
            newCategory.isSynced = "No"
            self.categories.append(newCategory)
            
            
            self.saveCategories(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    //MARK: - CoreData Flow Methods
    func saveCategories(category: Category){
        do {
            try context.save()
            
            self.ref.child("Categories").childByAutoId().setValue(["title": category.title,"isSynced":"Yes"]) { (error, ref) in
                    guard error == nil else {
                        print("error saving into firebase\(error?.localizedDescription ?? "something went Wrong")")
                    return
                }
                self.updateCategories(category: category)
            }
            
            
        } catch {
            print("Error saving categories \(error)")
        }
        
        categoryTableView.reloadData()
    }
    func updateCategories(category: Category){
        category.isSynced = "Yes"
        do {
            try context.save()
            
        } catch {
            
        }
    }
    
    func loadCategories(with request:NSFetchRequest<Category> = Category.fetchRequest()){
        
        let predicate = NSPredicate(format: "isSynced CONTAINS[cd] %@", "Yes")
       // request.fetchLimit = 2
        request.predicate = predicate
        
        do {
            categories = try context.fetch(request)
            categoryTableView.reloadData()
        } catch {
            print("error loading data \(error)")
        }
        
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
    
    
    
}


