//
//  NetworkFetcher.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 7/7/23.
//

import Foundation

protocol NetworkService {
    func getAllItems() async throws -> [TodoItem]
    func updateTasks(toDoItems: [TodoItem]) async throws  -> [TodoItem]
    func fetchTask(toDoItem: TodoItem) async throws
    func removeItem(toDoItem: TodoItem) async throws
    func modifyTask(toDoItem: TodoItem) async throws
    func addItem(toDoItem: TodoItem) async throws
}

final class NetworkFetcher: NetworkService {
    private var revision: Int?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    func getAllItems() async throws -> [TodoItem] {
        let url = try RequestProcessor.makeURL()
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        // let (data, response) = try await RequestProcessor.performRequest(with: url)
        //   print(response)
        let networkListToDoItems = try decoder.decode(ListToDoItems.self, from: data)
        revision = networkListToDoItems.revision
        //  print(revision)
        return networkListToDoItems.list.map { TodoItem.convert(from: $0) }
    }
    
    func updateTasks(toDoItems: [TodoItem]) async throws -> [TodoItem] {
        print("requestUpdateItems")
        let taskURL = try RequestProcessor.makeURL()
        let taskList = ListToDoItems(list: toDoItems.map(\.networkItem))
        let taskHttpBody = try encoder.encode(taskList)
        let (responseData, _) = try await RequestProcessor.performRequest(with: taskURL, method: .patch, revision: revision ?? 0, httpBody: taskHttpBody)
        let taskNetwork = try decoder.decode(ListToDoItems.self, from: responseData)
        print(taskNetwork)
        revision = taskNetwork.revision
        return taskNetwork.list.map{TodoItem.convert(from: $0)}
    }
    
    func fetchTask(toDoItem: TodoItem) async throws {
        print("requestGetItem")
        let url = try RequestProcessor.makeURL(from: toDoItem.id)
        let (data, _) = try await RequestProcessor.performRequest(with: url)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
    
    func removeItem(toDoItem: TodoItem) async throws {
        print("requestRemoveItem")
        let url = try RequestProcessor.makeURL(from: toDoItem.id)
        let (data, response) = try await RequestProcessor.performRequest(with: url, method: .delete, revision: revision)
        print(response)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: data)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
    
    func modifyTask(toDoItem: TodoItem) async throws {
        let url = try RequestProcessor.makeURL(from: toDoItem.id)
        let elementToDoItem = ElementToDoItem(element: toDoItem.networkItem)
        let httpBody = try encoder.encode(elementToDoItem)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .put, revision: revision, httpBody: httpBody)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        revision = toDoItemNetwork.revision
    }
    
    func addItem(toDoItem: TodoItem) async throws {
        let elementToDoItem = ElementToDoItem(element: toDoItem.networkItem)
        let url = try RequestProcessor.makeURL()
        let httpBody = try encoder.encode(elementToDoItem)
        // print(String(data: httpBody, encoding: .utf8))
        // print(httpBody)
        let (responseData, _) = try await RequestProcessor.performRequest(with: url, method: .post, revision: revision, httpBody: httpBody)
        // let (responseData, response) = try await RequestProcessor.performRequest(with: url, method: .post, revision: revision, httpBody: httpBody)
        // print(response)
        let toDoItemNetwork = try decoder.decode(ElementToDoItem.self, from: responseData)
        print(toDoItemNetwork)
        revision = toDoItemNetwork.revision
    }
}
