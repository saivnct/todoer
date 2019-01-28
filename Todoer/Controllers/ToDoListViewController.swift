//
//  ViewController.swift
//  Todoer
//
//  Created by Giang Bui Binh on 1/14/19.
//  Copyright © 2019 giangbb. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    var todoItem : Results<Item>?

//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = selectedCategory?.color{
            title = selectedCategory!.name
            
             updateNavBarColor(withHexCode: color)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBarColor(withHexCode: "1D9BF6")
    }
    
    //MARK - Navbar Setup Methods
    func updateNavBarColor(withHexCode hex: String) {
        guard let navBar = navigationController?.navigationBar else{
            fatalError("navigationController does not exist")
        }
        
        if let navBarColor = UIColor(hexString: hex){
            navBar.barTintColor = navBarColor
            
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            searchBar.barTintColor = navBarColor
        }
    }

    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItem?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
      
        if let item = todoItem?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor.init(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItem!.count)){
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.backgroundColor = color
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Item Added"
        }
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArr[indexPath.row])
        if let item = todoItem?[indexPath.row] {
            do{
                try realm.write {
//                    realm.delete(item)    //delete item from realm
                    item.done = !item.done
                }
                
            }catch{
                print("Error editing new items, \(error)")
            }
            
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
     //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoer Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks Add Item button on our UIAlert
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    func loadItems() {
        todoItem = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        //update data model
        if let item = self.todoItem?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(item)
                }
            }catch{
                print("Error deleting item, \(error)")
            }
            
            //                tableView.reloadData() //dont need this code, cause options.expansionStyle = .destructive
        }
    }
}

//MARK - Search bar methods
extension ToDoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        todoItem = todoItem?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
