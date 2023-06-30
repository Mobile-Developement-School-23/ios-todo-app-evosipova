//
//  AddTaskCell.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 7/1/23.
//

import Foundation
import UIKit

class AddTaskCell: UITableViewCell {

    static let id = "AddTaskCell"

    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Новое", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(addButton)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @objc func addButtonTapped() {
    }
}
