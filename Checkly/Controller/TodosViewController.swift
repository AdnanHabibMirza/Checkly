//
//  ViewController.swift
//  ClearTodo
//
//  Created by Adnan Habib on 26/08/2023.
//

import UIKit
import RealmSwift

class TodosViewController: UITableViewController {
    
    let realm = try! Realm()
    var todos: Results<Todo>!
    var category: Category! {
        didSet {
            loadTodos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = category?.title
        tableView.rowHeight = 80
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todo = todos[indexPath.row]
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = todo.title
        cell.contentConfiguration = contentConfiguration
        
        cell.accessoryType = todo.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, onComplete in
            self.realm.writeAsync {
                self.realm.delete(self.todos[indexPath.row])
            } onComplete: { e in
                if let error = e {
                    fatalError(error.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }
            onComplete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        realm.writeAsync {
            let todo = self.todos[indexPath.row]
            todo.done = !todo.done
        } onComplete: { e in
            if let error = e {
                fatalError(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    tableView.reloadData()
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var uiTextField = UITextField()
        let alert = UIAlertController(title: "Add Todo", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            uiTextField = alertTextField
            alertTextField.placeholder = "Type Todo Title"
            alertTextField.autocapitalizationType = .sentences
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { _ in
                alert.actions.first?.isEnabled = !(alertTextField.text?.isEmpty ?? true)
            }
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            if let text = uiTextField.text, !text.isEmpty {
                let todo = Todo()
                todo.title = text
                self.addTodo(todo)
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
    
    func addTodo(_ todo:Todo){
        realm.writeAsync {
            self.category!.todos.append(todo)
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
    
    func loadTodos(with query:String = ""){
        if(query.isEmpty) {
            todos = category.todos.sorted(byKeyPath: "created", ascending: false)
        }else{
            todos = category.todos.sorted(byKeyPath: "created", ascending: false).filter("title CONTAINS[cd] %@", query)
            
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: - UISearchBarDelegate

extension TodosViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let query = searchBar.text else { return }
        loadTodos(with: query)
        if(query.isEmpty){
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
