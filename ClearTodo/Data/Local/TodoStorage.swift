//
//  TodoStorage.swift
//  ClearTodo
//
//  Created by Adnan Habib on 27/08/2023.
//

import Foundation

private enum TodoStorageType {
    case standardDefaultsJSON
    case customPlist
    case standardDefaultsPlist
}

private protocol TodoStorageProtocol {
    func saveTodos(_ todos: [Todo])
    func loadTodos() -> [Todo]
}

class TodoStorage {
    private var storage: TodoStorageProtocol
    
    static let standardDefaultsJSON = TodoStorage(storageType: .standardDefaultsJSON)
    static let customPlist = TodoStorage(storageType: .customPlist)
    static let standardDefaultsPlist = TodoStorage(storageType: .standardDefaultsPlist)
    
    private init(storageType: TodoStorageType) {
        self.storage = TodoStorageFactory.create(storageType: storageType)
    }
    
    func saveTodos(_ todos: [Todo]) {
        storage.saveTodos(todos)
    }
    
    func loadTodos() -> [Todo] {
        return storage.loadTodos()
    }
}

private class TodoStorageFactory {
    static func create(storageType: TodoStorageType) -> TodoStorageProtocol {
        switch storageType {
        case .standardDefaultsJSON:
            return StandardDefaultsJSONTodoStorage()
        case .customPlist:
            return CustomPlistTodoStorage()
        case .standardDefaultsPlist:
            return StandardDefaultsPlistTodoStorage()
        }
    }
}

private class StandardDefaultsJSONTodoStorage: TodoStorageProtocol {
    private let userDefaults = UserDefaults.standard
    private let todoKey = "todos"
    
    func saveTodos(_ todos: [Todo]) {
        do {
            let encodedData = try JSONEncoder().encode(todos)
            userDefaults.set(encodedData, forKey: todoKey)
        } catch {
            print(error)
        }
    }
    
    func loadTodos() -> [Todo] {
        if let storedData = userDefaults.data(forKey: todoKey) {
            do {
                return try JSONDecoder().decode([Todo].self, from: storedData)
            } catch {
                print(error)
            }
        }
        return []
    }
}

private class CustomPlistTodoStorage: TodoStorageProtocol {
    private let plistUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Todos.plist")
    
    func saveTodos(_ todos: [Todo]) {
        do {
            let encodedData = try PropertyListEncoder().encode(todos)
            if let url = plistUrl {
                try encodedData.write(to: url)
            }
        } catch {
            print(error)
        }
    }
    
    func loadTodos() -> [Todo] {
        if let url = plistUrl {
            do {
                let storedData = try Data(contentsOf: url)
                return try PropertyListDecoder().decode([Todo].self, from: storedData)
            } catch {
                print(error)
            }
        }
        return []
    }
}

private class StandardDefaultsPlistTodoStorage: TodoStorageProtocol {
    private let userDefaults = UserDefaults.standard
    private let todoKey = "todos"
    
    func saveTodos(_ todos: [Todo]) {
        do {
            let encodedData = try PropertyListEncoder().encode(todos)
            userDefaults.set(encodedData, forKey: todoKey)
        } catch {
            print(error)
        }
    }
    
    func loadTodos() -> [Todo] {
        if let storedData = userDefaults.data(forKey: todoKey) {
            do {
                return try PropertyListDecoder().decode([Todo].self, from: storedData)
            } catch {
                print(error)
            }
        }
        return []
    }
}
