//
//  TodoStorage.swift
//  ClearTodo
//
//  Created by Adnan Habib on 27/08/2023.
//

import Foundation

struct TodoStorage {
    static let shared = TodoStorage()
    
    //MARK: - Standard Defaults with JSONCoder
    
    //    private let userDefaults = UserDefaults.standard
    //    private let todoKey = "todos"
    //
    //    func saveTodos(_ todos: [Todo]) {
    //        do {
    //            let encodedData = try JSONEncoder().encode(todos)
    //            userDefaults.set(encodedData, forKey: todoKey)
    //        } catch {
    //            print(error)
    //        }
    //    }
    //
    //    func loadTodos() -> [Todo] {
    //        if let storedData = userDefaults.data(forKey: todoKey) {
    //            do {
    //                return try JSONDecoder().decode([Todo].self, from: storedData)
    //            } catch {
    //                print(error)
    //            }
    //        }
    //        return []
    //    }
    
    //MARK: - Custom plist
    
    private let plistUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Todos.plist")

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
    
    //MARK: - Standard Defaults w/ PropertyListCoder
    
//        private let userDefaults = UserDefaults.standard
//        private let todoKey = "todos"
//
//        func saveTodos(_ todos: [Todo]) {
//            do {
//                let encodedData = try PropertyListEncoder().encode(todos)
//                userDefaults.set(encodedData, forKey: todoKey)
//            } catch {
//                print(error)
//            }
//        }
//
//        func loadTodos() -> [Todo] {
//            if let storedData = userDefaults.data(forKey: todoKey) {
//                do {
//                    return try PropertyListDecoder().decode([Todo].self, from: storedData)
//                } catch {
//                    print(error)
//                }
//            }
//            return []
//        }
}
