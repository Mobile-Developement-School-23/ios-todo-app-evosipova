//
//  ListOfTasksViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/28/23.
//

import Foundation
import UIKit

final class ListOfTasksViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(named: "white")
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
        doneLabel.text = "Выполнено — 5"
        doneLabel.textColor = UIColor(named: "doneLabel")
        return doneLabel
    }()

    private lazy var showDoneTasksButton: UIButton = {
        let showDoneTasksButton = UIButton(configuration: .plain(), primaryAction: UIAction(handler: { [weak self] _ in
            guard let self else { return }
            if self.showDoneTasksButton.titleLabel?.text == "Показать" {
                self.showDoneTasksButton.configuration?.attributedTitle = AttributedString("Скрыть", attributes: self.attributeContainer)
            } else {
                self.showDoneTasksButton.configuration?.attributedTitle = AttributedString("Показать", attributes: self.attributeContainer)
            }
        }))

        showDoneTasksButton.translatesAutoresizingMaskIntoConstraints = false
        showDoneTasksButton.configuration?.attributedTitle = AttributedString("Показать", attributes: attributeContainer)
        return showDoneTasksButton
    }()

    private let addButton: UIButton = {
            let image = UIImage(named: "Add")?.withRenderingMode(.alwaysOriginal)
            let addButton = UIButton(primaryAction: UIAction(image: image, handler: { _ in

            }))
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(openTaskViewController), for: .touchUpInside)
            addButton.layer.shadowColor = UIColor.black.cgColor
            addButton.layer.shadowOffset = CGSize(width: 0, height: 8)
            addButton.layer.shadowOpacity = 0.3
            addButton.layer.shadowRadius = 10
            return addButton
        }()

        @objc func openTaskViewController() {
            let taskViewController = TaskViewController()
            self.navigationController?.present(taskViewController, animated: true)
        }


    private let attributeContainer: AttributeContainer = {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .semibold)
        return container
    }()

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        let indexPath = IndexPath(row: 0, section: 0)
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        let shape = CAShapeLayer()
//        let rect = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.size.height)
//        print(cell.bounds.width)
//        print(cell.bounds.size.height)
//        let corners: UIRectCorner = [.topLeft, .topRight]
//
//        shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
//        cell.layer.mask = shape
//        cell.layer.masksToBounds = true
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(named: "primary")
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
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
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension ListOfTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
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
        10
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        56
    }

    func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
//        let cell = UITableViewCell()
        cell.textLabel?.text = "123"
//        cell.backgroundColor = .cyan
        return cell
    }

    func tableView(_: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        return UIContextMenuConfiguration(identifier: identifier,
                                          previewProvider: nil,
                                          actionProvider: { _ in
                                              let inspectAction =
                                                  UIAction(title: NSLocalizedString("InspectTitle", comment: ""),
                                                           image: UIImage(systemName: "arrow.up.square"))
                                              { _ in
                                                  //                       tableView.performInspect(indexPath)
                                              }
                                              let duplicateAction =
                                                  UIAction(title: NSLocalizedString("DuplicateTitle", comment: ""),
                                                           image: UIImage(systemName: "plus.square.on.square"))
                                              { _ in
                                                  //                       self.performDuplicate(indexPath)
                                              }
                                              let deleteAction =
                                                  UIAction(title: NSLocalizedString("DeleteTitle", comment: ""),
                                                           image: UIImage(systemName: "trash"),
                                                           attributes: .destructive)
                                              { _ in
                                                  //                       self.performDelete(indexPath)
                                              }
                                              return UIMenu(title: "", children: [inspectAction, duplicateAction, deleteAction])
                                          })
    }

    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        print("willPerformPreviewActionForMenuWith")
        guard let identifier = configuration.identifier as? String, let index = Int(identifier) else { return }
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
        animator.addCompletion {
            let vc = TaskViewController()
//            self.show(vc, sender: cell)
            self.present(vc, animated: true)
            print("animator")
        }
    }
}
