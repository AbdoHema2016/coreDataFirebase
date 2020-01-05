//
//  ItemsVC.swift
//  coreDataFirebase
//
//  Created by Abdelrahman-Arw on 1/5/20.
//  Copyright © 2020 Abdelrahman-Arw. All rights reserved.
//

import UIKit
import CoreData
import Firebase
class ItemsVC: UIViewController {
    
    @IBOutlet weak var btn_addItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView_items: UITableView!
    
    //MARK: - Variables
    var items = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController!
    var didSelectImage: ((UIImage) -> Void)?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    //MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        //loadItems()
        
        
    }
    
    //MARK: - Main saving Method
    func saveItem(item: Item,nodeId: String? = nil){
        self.saveItemsCoreData(item: item)
        self.items.append(item)
        self.tableView_items.reloadData()
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }

    
    //MARK: - Add Categories
    @objc func addTapped(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen on tapping the action add button
            
            let newItem = Item(context: self.context)
            newItem.name = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.saveItem(item: newItem)

            
        }
        let imagePickAction = UIAlertAction(title: "pick Image for Item", style: .default) { (action) in
            // what will happen on tapping the action add button
           // guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.selectImageFrom(.photoLibrary)
                
            //}
            //self.selectImageFrom(.camera)
           
            let newItem = Item(context: self.context)
            newItem.name = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.didSelectImage = { [weak self] image in
                newItem.image = image.pngData()
                self!.saveItem(item: newItem)
            }
            
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
            
        }
        
       // alert.addAction(action)
        alert.addAction(imagePickAction)
        present(alert,animated: true,completion: nil)
    }
    
    
    //MARK: - CoreData Flow Methods
    func saveItemsCoreData(item: Item){
        do {
            try context.save()
            //item.done = true
        } catch {
            print("Error saving categories \(error)")
        }
    }
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
       request.predicate = categoryPredicate
        do {
           // fetchFirebase()
            items = try context.fetch(request)
        } catch {
            print("error loading data \(error)")
        }
        
    }
    

    
}

extension ItemsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.imageView?.image = UIImage(data: item.image!)
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        items[indexPath.row].done = !items[indexPath.row].done
        self.saveItem(item: items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        //items[IndexPath.].image = selectedImage
        self.didSelectImage?(selectedImage)
    }
    
}
