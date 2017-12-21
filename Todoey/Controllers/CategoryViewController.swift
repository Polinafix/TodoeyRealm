//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Polina Fiksson on 20/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            destinationVC.selectedCategory = categories[indexPath.row]
        }
       
    }

    

    //MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let newCategory = categories[indexPath.row]
        cell.textLabel!.text = newCategory.name
        
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
                let category = Category(context: self.context)
                category.name = myCategory
                self.categories.append(category)
                self.saveCategories()
                
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data manipulation methods
    
    func saveCategories() {
        do {
           try context.save()
        }catch {
            print("Error occured when saving the data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        //request
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        //add the items back in the array
        do {
            try categories = context.fetch(request)
        }catch {
            print("Error occured when fetching the results")
        }
        tableView.reloadData()
    }
    
    
    

}
