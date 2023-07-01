//
//  CustomTableViewCell.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/30/23.
//


import Foundation
import UIKit

protocol TaskCellDelegate: AnyObject {
    func changeToDoItem(_ toDoItem: TodoItem)
}

final class CustomTableViewCell: UITableViewCell {
    static let id = "CustomTableViewCell"
    
    var showDoneTasks = true
    
    var corners: UIRectCorner = []
    var todoItem: TodoItem?
    weak var delegate: TaskCellDelegate?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    private lazy var buttonCheck: UIButton = {
        let image = UIImage(named: "arrow")
        let checkButton = UIButton()
        checkButton.setImage(image, for: .normal)
        checkButton.tintColor = UIColor(named: "backPrimary")
        checkButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self, var todoItem else { return }
            todoItem.isDone = !todoItem.isDone
            setDone()
            delegate?.changeToDoItem(todoItem)
            
        }), for: .touchUpInside)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        return checkButton
    }()
    
    private let arrow: UIImageView = {
        let arrow = UIImageView(image: UIImage(named: "arrow"))
        arrow.contentMode = .center
        arrow.translatesAutoresizingMaskIntoConstraints = false
        return arrow
    }()
    
    private lazy var horizontalStack: UIStackView = {
        let horizontalStack = UIStackView(arrangedSubviews: [imgImportance, textStack])
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.spacing = 2
        horizontalStack.distribution = .fill
        
        //  mainStack.backgroundColor = .blue
        return horizontalStack
    }()
    
    private lazy var deadlineStack: UIStackView = {
        let deadlineStack = UIStackView(arrangedSubviews: [calendarView, deadlineLabel])
        deadlineStack.alignment = .leading
        deadlineStack.spacing = 2
        deadlineStack.isHidden = true
        
        
        // deadlineStack.backgroundColor = .green
        return deadlineStack
    }()
    
    private lazy var textStack: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [taskLabel, deadlineStack])
        textStack.axis = .vertical
        textStack.alignment = .leading
        return textStack
    }()
    
    private let taskLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 3
        return textLabel
    }()
    
    private let imgImportance: UIImageView = {
        let imgImportance = UIImageView()
        imgImportance.contentMode = .center
        imgImportance.isHidden = true
        return imgImportance
    }()
    
    private let deadlineLabel: UILabel = {
        let deadlineLabel = UILabel()
        deadlineLabel.textColor = .black
        deadlineLabel.font = UIFont.systemFont(ofSize: 15)
        return deadlineLabel
    }()
    
    private let calendarView: UIImageView = {
        let calendarView = UIImageView()
        calendarView.contentMode = .center
        calendarView.image = #imageLiteral(resourceName: "calendar").withRenderingMode(.alwaysTemplate)
        calendarView.tintColor = UIColor(named: "labelPrimary")
        
        return calendarView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let outline = CAShapeLayer()
        let figure = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.size.height)
        outline.path = UIBezierPath(roundedRect: figure, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
        layer.mask = outline
        layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        contentView.addSubview(buttonCheck)
        contentView.addSubview(horizontalStack)
        contentView.addSubview(arrow)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            buttonCheck.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonCheck.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            buttonCheck.heightAnchor.constraint(equalToConstant: 24),
            buttonCheck.widthAnchor.constraint(equalToConstant: 24),
            
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            horizontalStack.leadingAnchor.constraint(equalTo: buttonCheck.trailingAnchor, constant: 12),
            horizontalStack.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -16),
            
            arrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrow.heightAnchor.constraint(equalToConstant: 12),
            arrow.widthAnchor.constraint(equalToConstant: 8),
        ])
        
        horizontalStack.backgroundColor = .green
        deadlineStack.backgroundColor = .blue
        calendarView.backgroundColor = .red
    }
    
    
    
    func setUI(_ todoItem: TodoItem) {
        taskLabel.text = todoItem.text
        
        // print("Deadline: \(todoItem.deadline)")
        
        
        if let deadline = todoItem.deadline {
            deadlineLabel.text = dateFormatter.string(from:  deadline)
            deadlineStack.isHidden = false // Показываем стэк
            calendarView.isHidden = false // Показываем иконку календаря
        } else {
            deadlineStack.isHidden = true // Скрываем стэк
            calendarView.isHidden = true // Скрываем иконку календаря
        }
        
        
        switch todoItem.importance {
        case .important:
            imgImportance.isHidden = false
            imgImportance.image = UIImage(named: "item3")
        case .unimportant:
            imgImportance.isHidden = false
            imgImportance.image = UIImage(named: "item1")
        case .normal:
            imgImportance.isHidden = true
        }
        self.todoItem = todoItem
        setDone()
        
        // print("Deadline: \(todoItem.deadline)")
        
    }
    
    private func setDone() {
        guard let todoItem else { return }
        if todoItem.isDone {
            let img = UIImage(named: "bounds")
            buttonCheck.setImage(img, for: .normal)
            let str = NSAttributedString(string: taskLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            taskLabel.attributedText = str
            taskLabel.textColor = .lightGray
        } else if todoItem.importance == .important {
            let img = UIImage(named: "redBounds")
            buttonCheck.setImage(img, for: .normal)
            taskLabel.textColor = UIColor(named: "text")
            let str = NSAttributedString(string: taskLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.self])
            taskLabel.attributedText = str
        } else {
            let img = UIImage(named: "ellipse")
            buttonCheck.setImage(img, for: .normal)
            taskLabel.textColor = UIColor(named: "text")
            let str = NSAttributedString(string: taskLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.self])
            taskLabel.attributedText = str
        }
    }
}
