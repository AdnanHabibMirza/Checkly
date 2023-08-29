//
//  ViewController.swift
//  ClearTodo
//
//  Created by Adnan Habib on 26/08/2023.
//

import UIKit
import CoreData

class TodosViewController: UITableViewController {
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var todos = [Todo]()
    
    override func viewDidLoad() {
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        todos = loadTodos()
        tableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource
    
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
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todos[indexPath.row].done = !todos[indexPath.row].done
        saveTodos()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var uiTextField = UITextField()
        let alert = UIAlertController(title: "Add Todo", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            uiTextField = alertTextField
            alertTextField.placeholder = "Type Todo Title"
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { _ in
                alert.actions.first?.isEnabled = !(alertTextField.text?.isEmpty ?? true)
            }
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            if let text = uiTextField.text, !text.isEmpty {
                let todo = Todo(context: self.context)
                todo.title = text
                self.saveTodos()
                self.todos.append(todo)
                self.tableView.reloadData()
            }
        }
        
        action.isEnabled = false
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func saveTodos(){
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func loadTodos() -> [Todo] {
        let request = Todo.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

