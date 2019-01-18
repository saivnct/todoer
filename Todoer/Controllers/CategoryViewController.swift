//
//  CategoryViewController.swift
//  Todoer
//
//  Created by Giang Bb on 1/16/19.
//  Copyright © 2019 giangbb. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No category added yet"
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
            
            self.saveCategory(category: category)
            
        }
        
        alert.addAction(action)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        
        present(alert, animated: true)
        
    }
    

}
