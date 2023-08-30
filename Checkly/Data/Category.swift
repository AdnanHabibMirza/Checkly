//
//  Category.swift
//  ClearTodo
//
//  Created by Adnan Habib on 31/08/2023.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var title: String
    @Persisted var todos: List<Todo>
}
