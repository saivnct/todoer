//
//  CategoryViewController.swift
//  Todoer
//
//  Created by Giang Bb on 1/16/19.
//  Copyright © 2019 giangbb. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadCategory()
        tableView.separatorStyle = .none
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row]{
            
            cell.textLabel?.text = category.name
            if let color = UIColor.init(hexString: category.color){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
        }else{
            cell.textLabel?.text = "No category added yet"
            cell.backgroundColor = UIColor.init(hexString: "1D9BF6")
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItem" {
            let destinationVC = segue.destination as! ToDoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
            
        }
        
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategory() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        //update data model
        if let category = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(category)
                }
            }catch{
                print("Error deleting category, \(error)")
            }

            //                tableView.reloadData() //dont need this code, cause options.expansionStyle = .destructive
        }
    }
    
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoer Category", message: "", preferredStyle: .alert)
        
        
        alert.addTextField { (uiTextField) in
            uiTextField.placeholder = "Create new item"
            textField = uiTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let category = Category()
            category.name = textField.text!
            category.color = UIColor.randomFlat.hexValue()
            self.saveCategory(category: category)
            
        }
        
        alert.addAction(action)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        
        present(alert, animated: true)
        
    }
}

