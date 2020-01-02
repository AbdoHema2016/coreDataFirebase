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
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what will happen on tapping the action add button
            
            let newCategory = Category(context: self.context)
            newCategory.title = textField.text!
            newCategory.isSynced = "No"
            if let check = self.checkifExists(category: newCategory) {
                if !check.keys.first! {
                    self.saveCategories(category: newCategory)
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
    
    //MARK: - CoreData Flow Methods
    func saveCategories(category: Category, nodeId: String? = nil){
        do {
            try context.save()
            self.categories.append(category)
            var nodeID = ref.childByAutoId().key
            if nodeId != nil {
                nodeID = nodeId
            }
            
            self.ref.child("Categories").child(nodeID!).setValue(["title": category.title,"isSynced":category.isSynced]) { (error, ref) in
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
        category.isSynced = "yes"
        do {
            try context.save()
            
        } catch {
            
        }
    }
    
    func loadCategories(with request:NSFetchRequest<Category> = Category.fetchRequest()){

        
        do {
            categories = try context.fetch(request)
            categoryTableView.reloadData()
            fetchFirebase()
            sendNonSyncedData()
            
            
        } catch {
            print("error loading data \(error)")
        }
        
    }
    
    func sendNonSyncedData(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "isSynced CONTAINS[cd] %@", "No")
        request.predicate = predicate
        var nonSynced = [Category]()
        do {
            nonSynced = try context.fetch(request)
            for category in nonSynced {
                saveCategories(category: category)
            }
            
        } catch {
            print("Can't save mobile saved data\(error)")
        }
        
    }
    
    func fetchFirebase(){
        ref.child("Categories").observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let categorySnap = snap as! DataSnapshot
                let categoryDict = categorySnap.value as! [String:String]
                guard let categorySyncStatus = categoryDict["isSynced"] else {return}
                //TODO: - updating item in firebase rewrites on core data
                if categorySyncStatus == "No" {
                    
                    let categoryTitle = categoryDict["title"] ?? ""
                    let newCategory = Category(context: self.context)
                    newCategory.title = categoryTitle
                    newCategory.isSynced = "Yes"
                    let nodeId = categorySnap.key
                    
                    if let check = self.checkifExists(category: newCategory) {
                        if check.keys.first! {
                            self.deleteCategory(category: check.values.first!)
                        }
                        
                    }
                    
                    
                    self.saveCategories(category: newCategory,nodeId: nodeId)

                }
            }
        })
        
    }
    
    func checkifExists(category: Category) -> Dictionary<Bool,Category>?{
        
        for checkCategory in categories {
            if checkCategory.title == category.title{
                return [true:checkCategory]
            }
        }
        
        return [false:category]
    }
    
    func deleteCategory(category: Category){
        self.context.delete(category)
        self.categories.remove(at: self.categories.index(of: category)!)
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


