//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Polina Fiksson on 20/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    //1.Initialize a new access point to realm database:
    let realm = try! Realm()
    //Results is an auto-updating container > we don't need to 'append' objects to it > it will monitor them automatically!
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        loadCategories()

    }
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //we want to trigger the segue
        //but first we need to do some prep for the next VC
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //will be triggered just before we prepare the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //1.
        let destinationVC = segue.destination as! TodoListViewController
        //2.Grab the category that corresponds to the selected cell, so we need to know what is the selected cell?
         //the index path that identifies the current row that is selected
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
       
    }

    //MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if categories return nil, then return 1
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       //get the cell that gets created inside our super tableView in SwipeTableViewController
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //modify this cell further by changing itd text label
        cell.textLabel!.text = categories?[indexPath.row].name ?? "No categories added"
        cell.backgroundColor = UIColor(hexString: (categories?[indexPath.row].color) ?? "#CDCDCD")
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
         
        return cell
        
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new category"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let myCategory = textField.text {
                let category = Category()
                category.name = myCategory
                category.color = UIColor.randomFlat.hexValue()
                 //Results is an auto-updating container > we don't need to 'append' objects to it > it will monitor them automatically!
                //self.categories.append(category)
                self.save(category: category)
                
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data manipulation methods
    
    func save(category: Category) {
        do {
            //commit current state to realm db
            try realm.write {
                realm.add(category)
            }
        }catch {
            print("Error occured when saving the data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        //will fetch all the data of Category type from db
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from swipe
    
    override func updateModel(at index: IndexPath) {
        if let category = self.categories?[index.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            }catch {
                print("Error deleting the category")
            }
        }
        //tableView.reloadData()
    }
    
    

}

