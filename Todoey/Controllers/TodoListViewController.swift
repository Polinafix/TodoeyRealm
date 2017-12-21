//
//  ViewController.swift
//  Todoey
//
//  Created by Polina Fiksson on 18/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    

    //access the context from the appDelegate(obtain a reference to the context):
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //mutable array
    var itemArray = [Item]()
    //will be nil until we set it in another VC
    //but once we set the selected category that's when we want to load up all the items relrvant to this specific category > use the computed property
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
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let currentItem = itemArray[indexPath.row]
        cell.textLabel?.text = currentItem.title
        //ternary operator
        cell.accessoryType = currentItem.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - tableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //change the tick
       // itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        ///1.remove data from our array
        itemArray.remove(at: indexPath.row)
        //2.remove data from our context
        context.delete(itemArray[indexPath.row])
        //save the changes to the permanent storage
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
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
                //create new object of type Item which NSManagedObject == row inside the table:
                //specify the context where this item is going to exist > persistentContainer.viewContext
                let newItem = Item(context: self.context)
                newItem.title = myItem
                newItem.done = false
                //specify the category
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                self.saveItems()
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
    
    func saveItems() {
        //commit our temp context to the permanent storage
        do {
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    //if we call this function and don't provide a value for the request, then we can have a default value
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //only load the items that have a parent category matching the selected one > query
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        //get all the predicates together
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        //first, our app needs to talk to the context
        do {
            try itemArray = context.fetch(request)//output for this method id going to be an array of items that is stored in the persistent container
        }catch {
            print("Error fetching data from the context \(error)")
        }
        
        
        tableView.reloadData()
        
    }
    

}
//MARK: - Search bar functionality
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //In order to read from the context we always need to create a request
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        //for all the items in Items array look for the once where the title contains the enter text, add query to our request
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        /*NSPredicate is a foundation class that specifies how data should be fetched or filtered*/
 
        //sort the data that we get from the DB, add it to the request:
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        //will return only those that satisfy the rules that we specified for our request
        loadItems(with: request, predicate: predicate)
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

