//
//  ListOfTasksViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/28/23.
//

import UIKit

protocol CreateTaskViewControllerDelegate: AnyObject {
    func saveTask(_ toDoItem: TodoItem)
    func deleteTask(_ id: String,_ reloadTable: Bool)
}

final class ListOfTasksViewController: UIViewController {
    private let fileCache = FileCache()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = UIColor(named: "backPrimary")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
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

    private var boundsImageCount: Int = 0 {
        didSet {
            doneLabel.text = "Выполнено — \(boundsImageCount)"
        }
    }
    
    private lazy var showDoneTasksButton: UIButton = {
        let showDoneTasksButton = UIButton(configuration: .plain())
        showDoneTasksButton.translatesAutoresizingMaskIntoConstraints = false
        showDoneTasksButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
        showDoneTasksButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            if showDoneTasksButton.titleLabel?.text == "Показать" {
                showDoneTasksButton.configuration?.attributedTitle = AttributedString("Скрыть", attributes: attributeContainer)
            } else {
                showDoneTasksButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
            }
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
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
        ])
        
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.id)
        
        loadTasks()
        
        
        NSLayoutConstraint.activate([
            doneLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            doneLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            doneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            showDoneTasksButton.topAnchor.constraint(equalTo: headerView.topAnchor),
            showDoneTasksButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            showDoneTasksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
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
    func saveTask(_ toDoItem: TodoItem) {
        fileCache.addItem(toDoItem)
        do {
            try fileCache.saveToFile(filename: "TodoItems")
        } catch {
            debugPrint(error)
        }
        tableView.reloadData()
    }
    
    func deleteTask(_ id: String,_ reloadTable: Bool = true) {
        fileCache.removeItem(withId: id)
        do {
            try fileCache.saveToFile(filename: "TodoItems")
        } catch {
            debugPrint(error)
        }
        if reloadTable { tableView.reloadData() }
    }
}

extension ListOfTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            let shape = CAShapeLayer()
            let rect = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.size.height)
            let corners: UIRectCorner = indexPath.row == 0 ? [.topLeft, .topRight] : [.bottomRight, .bottomLeft]
            
            shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
            cell.layer.mask = shape
            cell.layer.masksToBounds = true
        }
    }
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        fileCache.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.id, for: indexPath) as! CustomTableViewCell

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ellipse"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changeImageButtonPressed(sender:)), for: .touchUpInside)

        cell.contentView.addSubview(button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            button.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])

        cell.textLabel?.text = fileCache.items[indexPath.row].text

        return cell
    }




    @objc func changeImageButtonPressed(sender: UIButton) {
        let addImage = UIImage(named: "ellipse")
        let item1Image = UIImage(named: "bounds")

        if let cell = sender.superview?.superview as? CustomTableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            if sender.image(for: .normal)?.pngData() == addImage?.pngData() {
                sender.setImage(item1Image, for: .normal)
                boundsImageCount += 1
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.textLabel?.text ?? "")
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.textLabel?.attributedText = attributeString
            } else {
                sender.setImage(addImage, for: .normal)
                boundsImageCount -= 1
                let normalString: NSMutableAttributedString =  NSMutableAttributedString(string: fileCache.items[indexPath.row].text)
                normalString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, normalString.length))
                cell.textLabel?.attributedText = normalString
            }

        }
    }

    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        editTask(indexPath.row)
    }







    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { _, _, _ in
            
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


class CustomTableViewCell: UITableViewCell {
    var corners: UIRectCorner = []
    static let id = "CustomTableViewCell"
    override func layoutSubviews() {
        super.layoutSubviews()
        let shape = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.size.height)
        shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
        layer.mask = shape
        layer.masksToBounds = true
    }
}

