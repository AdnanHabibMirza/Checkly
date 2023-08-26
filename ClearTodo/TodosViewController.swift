//
//  ViewController.swift
//  ClearTodo
//
//  Created by Adnan Habib on 26/08/2023.
//

import UIKit

class TodosViewController: UITableViewController {
    
    var todos: [String] = []
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = todos[indexPath.row]
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
        }
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
                self.todos.append(text)
                self.tableView.reloadData()
            }
        }
        action.isEnabled = false
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}

