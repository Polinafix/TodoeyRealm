//
//  ViewController.swift
//  Todoey
//
//  Created by Polina Fiksson on 18/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    //1.Create a new instance of realm:
    let realm = try! Realm()
    
    
     var todoItems: Results<Item>?
    //will be nil until we set it in another VC
    //but once we set the selected category that's when we want to load up all the items relevant to this specific category > use the computed property
    var selectedCategory: Category? {
        //will happen as soon as selected category gets set with the value
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //here we want to load up all of the to-do items from our persistent container
        //loadItems()
            }
    
    //MARK: - tableView DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let currentItem = todoItems?[indexPath.row] {
            cell.textLabel?.text = currentItem.title
            //ternary operator
            cell.accessoryType = currentItem.done ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No items added"
        }
       
        
        return cell
    }
    
    //MARK: - tableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                  item.done = !item.done
                }
            }catch {
                print("Error saving done status \(error)")
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Add new items
    
    @IBAction func addButtonPresses(_ sender: UIBarButtonItem) {
        //create a local variable
        var textField = UITextField()
        //create a new alert
        let alert = UIAlertController(title: "Add new to-do item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //once the user click the add button
            if let myItem = textField.text {
                if let currentCategory = self.selectedCategory {
                    
                    do {
                        try self.realm.write {
                            //create new object of type Item
                            let newItem = Item()
                            newItem.title = myItem
                            newItem.dateCreated = Date()
                            //specify the category
                            currentCategory.items.append(newItem)
                        }
                    }catch {
                        print("Error saving new item \(error)")
                    }
                }

                
                self.tableView.reloadData()
            }
    
            
        }
        //add a text field inside the ui alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new item"
            //extending the scope
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Model manipulation methods
    

    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()

    }


}
//MARK: - Search bar functionality
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //filter items based on our search criteria
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //once we delete the text, load up all the items
        if searchBar.text!.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                 searchBar.resignFirstResponder()
            }

        }
    }
}

