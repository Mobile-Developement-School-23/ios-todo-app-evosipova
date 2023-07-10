//
//  NetworkToDoItem.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 7/7/23.
//

import Foundation

struct NetworkToDoItem: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let createdAt: Int
    let changedAt: Int?
    let lastUpdatedBy: String
    
    init(id: String, text: String, importance: String, deadline: Int? = nil, isDone: Bool, creationDate: Int, modificationDate: Int? = nil, lastUpdatedBy: String = "iphone") {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = isDone
        self.createdAt = creationDate
        self.changedAt = modificationDate
        self.lastUpdatedBy = lastUpdatedBy
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy  = "last_updated_by"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        importance = try container.decode(String.self, forKey: .importance)
        deadline = try container.decodeIfPresent(Int.self, forKey: .deadline)
        done = try container.decode(Bool.self, forKey: .done)
        createdAt = try container.decode(Int.self, forKey: .createdAt)
        changedAt = try container.decodeIfPresent(Int.self, forKey: .changedAt)
        lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importance, forKey: .importance)
        try container.encodeIfPresent(deadline, forKey: .deadline)
        try container.encode(done, forKey: .done)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(changedAt, forKey: .changedAt)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }
}

struct ListToDoItems: Codable {
    let revision: Int?
    let list: [NetworkToDoItem]
    init(revision: Int? = nil, list: [NetworkToDoItem]) {
        self.revision = revision
        self.list = list
    }
}

struct ElementToDoItem: Codable {
    let revision: Int?
    let element: NetworkToDoItem
    init(revision: Int? = nil, element: NetworkToDoItem) {
        self.revision = revision
        self.element = element
    }
}
