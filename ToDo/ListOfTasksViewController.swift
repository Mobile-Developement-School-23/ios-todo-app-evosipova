//
//  ListOfTasksViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/28/23.
//

import Foundation
import UIKit


protocol CreateTaskViewControllerDelegate: AnyObject {
    func saveTask(_ toDoItem: TodoItem)
    func deleteTask(_ id: String, _ reloadTable: Bool)
}

final class ListOfTasksViewController: UIViewController {
    private let fileCache = FileCache()
    
    var showDoneTasks = false
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = UIColor(named: "backPrimary")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        headerView.addSubview(doneLabel)
        headerView.addSubview(showDoneTasksButton)
        
        NSLayoutConstraint.activate([
            doneLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            doneLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            doneLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            showDoneTasksButton.topAnchor.constraint(equalTo: headerView.topAnchor),
            showDoneTasksButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            showDoneTasksButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
        ])
        return headerView
    }()
    
    private let doneLabel: UILabel = {
        let doneLabel = UILabel()
        doneLabel.translatesAutoresizingMaskIntoConstraints = false
        doneLabel.text = "Выполнено — 0"
        doneLabel.textColor = UIColor(named: "doneLabel")
        return doneLabel
    }()
    
    private lazy var showDoneTasksButton: UIButton = {
        let showDoneTasksButton = UIButton(configuration: .plain())
        
        
        
        showDoneTasksButton.translatesAutoresizingMaskIntoConstraints = false
        showDoneTasksButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
        
        showDoneTasksButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.showDoneTasks.toggle()
            if self.showDoneTasks {
                showDoneTasksButton.configuration?.attributedTitle = AttributedString("Скрыть", attributes: attributeContainer)
            } else {
                showDoneTasksButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
            }
            self.tableView.reloadData()
        }), for: .touchUpInside)
        return showDoneTasksButton
        
        
    }()
    
    private lazy var addButton: UIButton = {
        let image = UIImage(named: "Add")?.withRenderingMode(.alwaysOriginal)
        let addButton = UIButton(primaryAction: UIAction(image: image, handler: { [weak self] _ in
            let createTaskViewController = TaskViewController()
            createTaskViewController.delegate = self
            self?.present(createTaskViewController, animated: true)
        }))
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        addButton.layer.shadowOpacity = 0.3
        addButton.layer.shadowRadius = 10
        return addButton
    }()
    
    private let attributeContainer: AttributeContainer = {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .semibold)
        return container
    }()
    
    private let defaultName = "Task"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backPrimary")
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
        
        loadTasks()
        
        tableView.register(AddTaskCell.self, forCellReuseIdentifier: AddTaskCell.id)
        
    }
    
    private func loadTasks() {
        do {
            try fileCache.loadFromFile(filename: "TodoItems")
        } catch {
            debugPrint(error)
        }
    }
    
    private func editTask(_ index: Int) {
        let createTaskViewController = TaskViewController()
        createTaskViewController.todoItem = fileCache.items[index]
        createTaskViewController.delegate = self
        print(fileCache.items[index])
        present(createTaskViewController, animated: true)
    }
}

extension ListOfTasksViewController: CreateTaskViewControllerDelegate {
    func updateDoneTasks() {
        let doneTasks = fileCache.items.filter { $0.isDone }.count
        doneLabel.text = "Выполнено — \(doneTasks)"
    }
    
    func saveTask(_ toDoItem: TodoItem) {
        fileCache.addItem(toDoItem)
        do {
            try fileCache.saveToFile(filename: "TodoItems")
        } catch {
            debugPrint(error)
        }
        updateDoneTasks()
        tableView.reloadData()
    }
    
    func deleteTask(_ id: String, _ reloadTable: Bool = true) {
        fileCache.removeItem(withId: id)
        do {
            try fileCache.saveToFile(filename: "TodoItems")
        } catch {
            debugPrint(error)
        }
        updateDoneTasks()
        if reloadTable { tableView.reloadData() }
    }
    
    
}

extension ListOfTasksViewController: TaskCellDelegate {
    func changeToDoItem(_ toDoItem: TodoItem) {
        saveTask(toDoItem)
    }
}

extension ListOfTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CustomTableViewCell else { return }
        if indexPath.row == 0 || indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell.corners = indexPath.row == 0 ? [.topLeft, .topRight] : [.bottomRight, .bottomLeft]
        } else {
            cell.corners = []
        }
    }
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if showDoneTasks {
            return fileCache.items.count + 1
        } else {
            return fileCache.items.filter { !$0.isDone }.count + 1
        }
    }
    
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = showDoneTasks ? fileCache.items : fileCache.items.filter { !$0.isDone }
        if indexPath.row == items.count {
            return tableView.dequeueReusableCell(withIdentifier: AddTaskCell.id, for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: indexPath) as? CustomTableViewCell
        cell?.setUI(items[indexPath.row])
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = showDoneTasks ? fileCache.items : fileCache.items.filter { !$0.isDone }
        if indexPath.row == items.count {
            let createTaskViewController = TaskViewController()
            createTaskViewController.delegate = self
            present(createTaskViewController, animated: true)
        } else {
            editTask(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let self else { return }
            var toDoItem = fileCache.items[indexPath.row]
            toDoItem.isDone = !toDoItem.isDone
            saveTask(toDoItem)
        }
        doneAction.backgroundColor = #colorLiteral(red: 0.2260308266, green: 0.8052191138, blue: 0.4233448207, alpha: 1)
        doneAction.image = UIImage(systemName: "checkmark.circle.fill")
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let self else { return }
            let toDoItem = fileCache.items[indexPath.row]
            deleteTask(toDoItem.id, false)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        return UIContextMenuConfiguration(identifier: identifier,
                                          previewProvider: nil,
                                          actionProvider: { [weak self] _ in
            guard let self else { return UIMenu() }
            let inspectAction =
            UIAction(title: NSLocalizedString("Редактировать", comment: ""),
                     image: UIImage(systemName: "arrow.up.square"))
            { _ in
                self.editTask(index)
            }
            let deleteAction =
            UIAction(title: NSLocalizedString("Удалить", comment: ""),
                     image: UIImage(systemName: "trash"),
                     attributes: .destructive)
            { _ in
                let toDoItem = self.fileCache.items[index]
                self.deleteTask(toDoItem.id)
            }
            return UIMenu(title: "", children: [inspectAction, deleteAction])
        })
    }
    
    func tableView(_: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let identifier = configuration.identifier as? String, let index = Int(identifier) else { return }
        animator.addCompletion {
            self.editTask(index)
        }
    }
}




