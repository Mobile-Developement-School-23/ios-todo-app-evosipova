//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Elizaveta Osipova on 6/16/23.
//

import XCTest
@testable import ToDo

final class ToDoTests: XCTestCase {
    func testTodoItemCreation() throws {
        let todo = TodoItem(text: "Test", importance: .normal)
        XCTAssertNotNil(todo)
        XCTAssertEqual(todo.text, "Test")
        XCTAssertEqual(todo.importance, Importance.normal)
        XCTAssertFalse(todo.isDone)
    }
    
    func testTodoItemIdGeneration() throws {
        let todo1 = TodoItem(text: "Test 1", importance: .normal)
        let todo2 = TodoItem(text: "Test 2", importance: .normal)
        XCTAssertNotEqual(todo1.id, todo2.id)
    }
    
    func testTodoItemParsingFromJson() throws {
        let todo = TodoItem(text: "Test", importance: .normal)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: todo.json, options: .prettyPrinted),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let parsedTodo = TodoItem.parse(json: jsonObject) else {
            XCTFail("Failed to serialize and deserialize the todo item.")
            return
        }
        
        XCTAssertEqual(parsedTodo.id, todo.id)
        XCTAssertEqual(parsedTodo.text, todo.text)
        XCTAssertEqual(parsedTodo.importance, todo.importance)
    }
    
    func testTodoItemParsingFromCSV() throws {
        let todo = TodoItem(text: "Test", importance: .normal)
        let parsedTodo = TodoItem.parse(csv: todo.csv)
        XCTAssertEqual(parsedTodo?.id, todo.id)
        XCTAssertEqual(parsedTodo?.text, todo.text)
        XCTAssertEqual(parsedTodo?.importance, todo.importance)
    }
    
    func testTodoItemCompleteCsvParsing() {
        let creationDate = dateFormatter.string(from: Date())
        let deadline = dateFormatter.string(from: Date(timeIntervalSinceNow: 60))
        let modificationDate = dateFormatter.string(from: Date())
        let completeCsv = "testID,Test,true,\(creationDate),important,\(deadline),\(modificationDate)"
        
        guard let todo = TodoItem.parse(csv: completeCsv) else {
            XCTFail("Failed to parse complete CSV.")
            return
        }
        
        XCTAssertEqual(todo.id, "testID")
        XCTAssertEqual(todo.text, "Test")
        XCTAssertEqual(todo.isDone, true)
        XCTAssertEqual(todo.importance, .important)
        XCTAssertNotNil(todo.deadline)
        XCTAssertNotNil(todo.modificationDate)
    }
    
    func testTodoItemCompleteCsvConversion() {
        let deadline = Date(timeIntervalSinceNow: 60)
        let modificationDate = Date()
        let todo = TodoItem(text: "Test", importance: .important, deadline: deadline, isDone: true, id: "testID", modificationDate: modificationDate)
        let csv = todo.csv
        XCTAssertTrue(csv.contains("testID"))
        XCTAssertTrue(csv.contains("Test"))
        XCTAssertTrue(csv.contains("true"))
        XCTAssertTrue(csv.contains("important"))
        XCTAssertTrue(csv.contains(dateFormatter.string(from: deadline)))
        XCTAssertTrue(csv.contains(dateFormatter.string(from: modificationDate)))
    }
    
    func testTodoItemCompleteJsonParsing() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let completeJson: [String: Any] = [
            "id": "testID",
            "text": "Test",
            "isDone": true,
            "creationDate": dateFormatter.string(from: Date()),
            "importance": "important",
            "deadline": dateFormatter.string(from: Date(timeIntervalSinceNow: 60)),
            "modificationDate": dateFormatter.string(from: Date())
        ]
        
        guard let todo = TodoItem.parse(json: completeJson) else {
            XCTFail("Failed to parse complete JSON.")
            return
        }
        
        XCTAssertEqual(todo.id, "testID")
        XCTAssertEqual(todo.text, "Test")
        XCTAssertEqual(todo.isDone, true)
        XCTAssertEqual(todo.importance, .important)
        XCTAssertNotNil(todo.deadline)
        XCTAssertNotNil(todo.modificationDate)
    }
    
    func testTodoItemDeadline() throws {
        let deadline = Date(timeIntervalSinceNow: 60)
        let todo = TodoItem(text: "Test", importance: .normal, deadline: deadline)
        XCTAssertNotNil(todo.deadline)
        XCTAssertEqual(todo.deadline, deadline)
    }
    
    func testTodoItemModificationDate() throws {
        var todo = TodoItem(text: "Test", importance: .normal)
        let modificationDate = Date()
        todo.modificationDate = modificationDate
        XCTAssertEqual(todo.modificationDate, modificationDate)
    }
    
    func testTodoItemJsonWithoutOptionalFields() throws {
        let todo = TodoItem(text: "Test", importance: .normal)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: todo.json, options: .prettyPrinted),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            XCTFail("Failed to serialize the todo item.")
            return
        }
        
        XCTAssertNil(jsonDict["deadline"])
        XCTAssertNil(jsonDict["modificationDate"])
        XCTAssertNil(jsonDict["importance"])
    }
    
    func testTodoItemJsonWithOptionalFields() throws {
        let deadline = Date(timeIntervalSinceNow: 60)
        let modificationDate = Date()
        let todo = TodoItem(text: "Test", importance: .important, deadline: deadline, isDone: true, modificationDate: modificationDate)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: todo.json, options: .prettyPrinted),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            XCTFail("Failed to serialize the todo item.")
            return
        }
        
        XCTAssertNotNil(jsonDict["deadline"])
        XCTAssertNotNil(jsonDict["modificationDate"])
        XCTAssertEqual(jsonDict["importance"] as? String, Importance.important.rawValue)
        XCTAssertEqual(jsonDict["isDone"] as? Bool, true)
    }
    
    func testTodoItemJsonParsingFailure() throws {
        let invalidJson: [String: Any] = ["invalid_key": "invalid_value"]
        let todo = TodoItem.parse(json: invalidJson)
        XCTAssertNil(todo)
    }
    
    func testTodoItemCsvParsingFailure() throws {
        let invalidCsv = "invalid_csv_string"
        let todo = TodoItem.parse(csv: invalidCsv)
        XCTAssertNil(todo)
    }
}
