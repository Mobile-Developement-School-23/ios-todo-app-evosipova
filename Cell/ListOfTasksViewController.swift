//
//  ListOfTasksViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/28/23.
//

import Foundation
import UIKit

protocol TaskViewControllerDelegate: AnyObject {
    func saveCell(_ toDoItem: TodoItem, isNewItem: Bool)
    func deleteCell(_ toDoItem: TodoItem, _ reloadTable: Bool)
}

final class ListOfTasksViewController: UIViewController {
    private let fileCache = FileCache()
    
    var showDoneTasks = false
    
    private let networkFetcher: NetworkService = NetworkFetcher()
    
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .blue
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = UIColor(named: "backPrimary")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = mainView
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var mainView: UIView = {
        let mainV = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        mainV.addSubview(doneLabel)
        mainV.addSubview(showDoneTasksButton)
        
        NSLayoutConstraint.activate([
            doneLabel.topAnchor.constraint(equalTo: mainV.topAnchor),
            doneLabel.bottomAnchor.constraint(equalTo: mainV.bottomAnchor),
            doneLabel.leadingAnchor.constraint(equalTo: mainV.leadingAnchor, constant: 16),
            showDoneTasksButton.topAnchor.constraint(equalTo: mainV.topAnchor),
            showDoneTasksButton.bottomAnchor.constraint(equalTo: mainV.bottomAnchor),
            showDoneTasksButton.trailingAnchor.constraint(equalTo: mainV.trailingAnchor, constant: -16),
        ])
        return mainV
    }()
    
    private let doneLabel: UILabel = {
        let doneLabel = UILabel()
        doneLabel.translatesAutoresizingMaskIntoConstraints = false
        doneLabel.text = "Выполнено — 0"
        doneLabel.textColor = UIColor(named: "doneLabel")
        return doneLabel
    }()
    
    private lazy var showDoneTasksButton: UIButton = {
        let doneButton = UIButton(configuration: .plain())
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
        
        doneButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.showDoneTasks.toggle()
            if self.showDoneTasks {
                doneButton.configuration?.attributedTitle = AttributedString("Скрыть", attributes: attributeContainer)
            } else {
                doneButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
            }
            self.tableView.reloadData()
        }), for: .touchUpInside)
        return doneButton
        
        
    }()
    
    private lazy var addButton: UIButton = {
        let image = UIImage(named: "Add")?.withRenderingMode(.alwaysOriginal)
        let addButton = UIButton(primaryAction: UIAction(image: image, handler: { [weak self] _ in
            let taskViewController = TaskViewController()
            taskViewController.delegate = self
            self?.present(taskViewController, animated: true)
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
    
    
    private let alert: UIAlertController = {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadTasks()
        registerCells()
        setupActivityIndicator()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "backPrimary")
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        view.addSubview(activityIndicator)
        setupTableView()
        setupAddButton()
    }
    
    private func updateTasks() {
        Task {
            do {
                let toDoItems = try await networkFetcher.updateTasks(toDoItems: fileCache.items)
                for toDoItem in toDoItems {
                    fileCache.addItem(toDoItem)
                }
                fileCache.isDirty = false
                tableView.reloadData()
                updateDoneTasks()
            } catch {
                print(error)
                fileCache.isDirty = true
            }
        }
    }
    
    private func loadTasks() {
        activityIndicator.startAnimating()
        _ = Task {
            do {
                let toDoItems = try await networkFetcher.getAllItems()
                for toDoItem in toDoItems {
                    fileCache.addItem(toDoItem)
                }
                fileCache.isDirty = false
                tableView.reloadData()
                updateDoneTasks()
                activityIndicator.stopAnimating()
            } catch {
                debugPrint(error)
                do {
                    try fileCache.loadFromFile(filename: "TodoItems")
                    tableView.reloadData()
                    updateDoneTasks()
                } catch {
                    alert.title = "Нет списка дел"
                    alert.message = "Не получилось загрузить список дел"
                    present(alert, animated: true)
                }
                fileCache.isDirty = true
                activityIndicator.stopAnimating()
            }
        }
        
    }
    
    private func registerCells() {
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
        tableView.register(AddTaskCell.self, forCellReuseIdentifier: AddTaskCell.id)
    }
    
    private func editTask(_ index: Int) {
        let createTaskViewController = TaskViewController()
        createTaskViewController.todoItem = fileCache.items[index]
        createTaskViewController.delegate = self
        print(fileCache.items[index])
        present(createTaskViewController, animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
}

extension ListOfTasksViewController: TaskViewControllerDelegate {
    func updateDoneTasks() {
        let doneTasks = fileCache.items.filter { $0.isDone }.count
        doneLabel.text = "Выполнено — \(doneTasks)"
    }
    
    
    func saveCell(_ toDoItem: TodoItem, isNewItem: Bool)  {
        fileCache.addItem(toDoItem)
        do {
            try fileCache.saveToFile(filename: "TodoItems")
        } catch {
            alert.title = "Что-то пошло не так"
            alert.message = "Не получилось сохранить задачу"
            present(alert, animated: true)
        }
        updateDoneTasks()
        tableView.reloadData()
        
        guard !fileCache.isDirty else {
            updateTasks()
            return
        }
        Task {
            do {
                if isNewItem {
                    try await networkFetcher.addItem(toDoItem: toDoItem)
                } else {
                    try await networkFetcher.fetchTask(toDoItem: toDoItem)
                }
            } catch {
                debugPrint(error)
                fileCache.isDirty = true
            }
        }
    }
    
    
    
    func deleteCell(_ toDoItem: TodoItem, _ reloadTable: Bool = true) {
        

        fileCache.removeItem(withId: toDoItem.id)
        do {
            try fileCache.saveToFile(filename: "TodoItems")
        } catch {
            alert.title = "Что-то пошло не так"
            alert.message = "Не получилось удалить задачу"
            present(alert, animated: true)
        }
        updateDoneTasks()
        if reloadTable { tableView.reloadData() }
        guard !fileCache.isDirty else {
            updateTasks()
            return
        }
        
        Task {
            do {
                try await networkFetcher.removeItem(toDoItem: toDoItem)
            }  catch {
                debugPrint(error)
                fileCache.isDirty = true
            }
        }
        
    }
    
    
}

extension ListOfTasksViewController: TaskCellDelegate {
    func changeToDoItem(_ toDoItem: TodoItem) async {
        await saveCell(toDoItem, isNewItem: false)
    }
}

extension ListOfTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt index: IndexPath) {
        guard let cell = cell as? CustomTableViewCell else { return }
        if index.row == 0 || index.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell.corners = index.row == 0 ? [.topLeft, .topRight] : [.bottomRight, .bottomLeft]
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
    
    func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        let items = showDoneTasks ? fileCache.items : fileCache.items.filter { !$0.isDone }
        if index.row == items.count {
            return tableView.dequeueReusableCell(withIdentifier: AddTaskCell.id, for: index)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: index) as? CustomTableViewCell
        cell?.setUI(items[index.row])
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
    
    func tableView(_: UITableView, didSelectRowAt index: IndexPath) {
        let items = showDoneTasks ? fileCache.items : fileCache.items.filter { !$0.isDone }
        if index.row == items.count {
            let taskViewController = TaskViewController()
            taskViewController.delegate = self
            present(taskViewController, animated: true)
        } else {
            editTask(index.row)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt index: IndexPath) -> UISwipeActionsConfiguration? {
        let items = showDoneTasks ? fileCache.items : fileCache.items.filter { !$0.isDone }
        if index.row != items.count {
            let doneAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
                guard let self else { return }
                var toDoItem = items[index.row]
                toDoItem.isDone = !toDoItem.isDone
                saveCell(toDoItem, isNewItem: false)
            }
            doneAction.backgroundColor = #colorLiteral(red: 0.2260308266, green: 0.8052191138, blue: 0.4233448207, alpha: 1)
            doneAction.image = UIImage(systemName: "checkmark.circle.fill")
            return UISwipeActionsConfiguration(actions: [doneAction])
        } else {
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let items = showDoneTasks ? fileCache.items : fileCache.items.filter { !$0.isDone }
        if indexPath.row != items.count {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
                guard let self else { return }
                let toDoItem = items[indexPath.row]
                deleteCell(toDoItem, false)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return nil
        }
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
                self.deleteCell(toDoItem)
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


