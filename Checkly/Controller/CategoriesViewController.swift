//
//  CategoriesViewController.swift
//  ClearTodo
//
//  Created by Adnan Habib on 30/08/2023.
//

import UIKit
import RealmSwift

class CategoriesViewController: UITableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = category.title
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodos", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? TodosViewController else {return}
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        destination.category = categories[indexPath.row]
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var uiTextField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            uiTextField = alertTextField
            alertTextField.placeholder = "Type Category Title"
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { _ in
                alert.actions.first?.isEnabled = !(alertTextField.text?.isEmpty ?? true)
            }
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            if let text = uiTextField.text, !text.isEmpty {
                let category = Category()
                category.title = text
                self.addCategory(category)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
            alert.dismiss(animated: true)
        }
        
        addAction.isEnabled = false
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    //MARK: - Realm
    
    func addCategory(_ category: Category){
        realm.writeAsync {
            self.realm.add(category)
        } onComplete: { e in
            if let error = e {
                fatalError(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadCategories(with query:String = ""){
        if(query.isEmpty) {
            categories = realm.objects(Category.self).sorted(byKeyPath: "title")
        } else {
            categories = realm.objects(Category.self).sorted(byKeyPath: "title").filter("title CONTAINS[cd] %@", query)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - UISearchBarDelegate

extension CategoriesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let query = searchBar.text else { return }
        loadCategories(with: query)
        if(query.isEmpty){
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
