//
//  Todo.swift
//  ClearTodo
//
//  Created by Adnan Habib on 31/08/2023.
//

import Foundation
import RealmSwift

class Todo: Object {
    @Persisted var title: String
    @Persisted var done: Bool
    @Persisted var created: Date = Date()
    @Persisted(originProperty: "todos") var category: LinkingObjects<Category>
}
