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
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let creationDate: Date
    let modificationDate: Date?
    
    init(text: String, importance: Importance, deadline: Date? = nil, isDone: Bool = false, id: String = UUID().uuidString, creationDate: Date = Date(), modificationDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()



extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any],
              let text = jsonDict["text"] as? String,
                let id = jsonDict["id"] as? String 
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

        var creationDate: Date = Date()
        if let creationDateStr = jsonDict["creationDate"] as? String {
            creationDate = dateFormatter.date(from: creationDateStr) ?? Date()
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
        guard components.count >= 6 else { return nil }

        let id = components[0]
        let text = components[1]
        let isDone = Bool(components[2]) ?? false
        let creationDateString = components[3]
        let creationDate = dateFormatter.date(from: creationDateString) ?? Date()

        let importance = Importance(rawValue: components[4]) ?? .normal

        var deadline: Date?
        let deadlineStr = components[5]
        if !deadlineStr.isEmpty {
            deadline = dateFormatter.date(from: deadlineStr)
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


}

