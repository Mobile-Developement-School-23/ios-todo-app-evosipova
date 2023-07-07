//
//  TodoItem.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/16/23.
//

import Foundation

enum Importance: String {
    case unimportant
    case normal
    case important
}


struct TodoItem {
    let id: String
    var text: String
    let importance: Importance
    var deadline: Date?
    var isDone: Bool
    let creationDate: Date
    var modificationDate: Date?
    
    
    
    
    init(text: String, importance: Importance, deadline: Date? = nil, isDone: Bool = false, id: String = UUID().uuidString, creationDate: Date = Date(), modificationDate: Date? = Date()) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        
    }
}



private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM yyyy"
    return formatter
}()


extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any],
              let text = jsonDict["text"] as? String,
              let id = jsonDict["id"] as? String,
              let creationDateStr = jsonDict["creationDate"] as? String,
              let creationDate = dateFormatter.date(from: creationDateStr)
        else { return nil }
        
        let isDone = jsonDict["isDone"] as? Bool ?? false
        var importance: Importance = .normal
        if let importanceString = jsonDict["importance"] as? String {
            importance = Importance(rawValue: importanceString) ?? .normal
        }
        
        var deadline: Date? = nil
        if let deadlineStr = jsonDict["deadline"] as? String {
            deadline = dateFormatter.date(from: deadlineStr)
        }
        
        var modificationDate: Date? = nil
        if let modificationDateStr = jsonDict["modificationDate"] as? String {
            modificationDate = dateFormatter.date(from: modificationDateStr)
        }
        
        return TodoItem(text: text, importance: importance, deadline: deadline, isDone: isDone, id: id, creationDate: creationDate, modificationDate: modificationDate)
    }
    
    
    var json: Any {
        var jsonDict: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "creationDate": dateFormatter.string(from: creationDate)
        ]
        
        if importance != .normal {
            jsonDict["importance"] = importance.rawValue
        }
        
        if let deadline = deadline {
            jsonDict["deadline"] = dateFormatter.string(from: deadline)
        }
        
        if let modificationDate = modificationDate {
            jsonDict["modificationDate"] = dateFormatter.string(from: modificationDate)
        }
        
        return jsonDict
    }
    
    
    static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: ",")
        guard components.count >= 5 else { return nil }
        
        let id = components[0]
        let text = components[1]
        let isDone = Bool(components[2]) ?? false
        let creationDateString = components[3]
        guard let creationDate = dateFormatter.date(from: creationDateString) else { return nil }
        
        let importance = Importance(rawValue: components[4]) ?? .normal
        
        var deadline: Date?
        if components.count > 5 {
            let deadlineStr = components[5]
            if !deadlineStr.isEmpty {
                deadline = dateFormatter.date(from: deadlineStr)
            }
        }
        
        var modificationDate: Date?
        if components.count > 6 {
            let modificationDateStr = components[6]
            if !modificationDateStr.isEmpty {
                modificationDate = dateFormatter.date(from: modificationDateStr)
            }
        }
        
        return TodoItem(text: text, importance: importance, deadline: deadline, isDone: isDone, id: id, creationDate: creationDate, modificationDate: modificationDate)
    }
    
    
    
    var csv: String {
        var csvString = "\(id),\(text),\(isDone),\(dateFormatter.string(from: creationDate))"
        
        if importance != .normal {
            csvString += ",\(importance.rawValue)"
        } else {
            csvString += ","
        }
        
        if let deadline = deadline {
            csvString += ",\(dateFormatter.string(from: deadline))"
        } else {
            csvString += ","
        }
        if let modificationDate = modificationDate {
            csvString += ",\(dateFormatter.string(from: modificationDate))"
        } else {
            csvString += ","
        }
        return csvString
    }
    
    static func convert(from networkToDoItem: NetworkToDoItem) -> TodoItem {
        var importance = Importance.normal
        switch networkToDoItem.importance {
        case "low":
            importance = .unimportant
        case "basic":
            importance = .normal
        case "important":
            importance = .important
        default:
            break
        }
        var deadline: Date?
        if let deadlineTimeInterval = networkToDoItem.deadline {
            deadline = Date(timeIntervalSinceReferenceDate: Double(deadlineTimeInterval))
        }
        var changed: Date?
        if let changedTimeInterval = networkToDoItem.changedAt {
            changed = Date(timeIntervalSinceReferenceDate: Double(changedTimeInterval))
        }
        
        let created = Date(timeIntervalSinceReferenceDate: Double(networkToDoItem.createdAt))
        let toDoItem = TodoItem(text: networkToDoItem.text, importance: importance, deadline: deadline, isDone: networkToDoItem.done, id: networkToDoItem.id, creationDate: created, modificationDate: changed)
        return toDoItem
    }
    
    var networkItem: NetworkToDoItem {
        var importance = ""
        switch self.importance {
        case .unimportant:
            importance = "low"
        case .normal:
            importance = "basic"
        case .important:
            importance = "important"
        }
        var deadline: Int?
        if let deadlineTimeInterval = self.deadline?.timeIntervalSinceReferenceDate {
            deadline = Int(deadlineTimeInterval)
        }
        var changed: Int?
        if let changedTimeInterval = self.modificationDate?.timeIntervalSinceReferenceDate {
            changed = Int(changedTimeInterval)
        }
        let created = Int(creationDate.timeIntervalSinceReferenceDate)
        let networkItem = NetworkToDoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: created,
            modificationDate: changed,
            lastUpdatedBy: "default"
        )
        
        return networkItem
    }
    
    
    
}

