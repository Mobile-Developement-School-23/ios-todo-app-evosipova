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
    var toDoItem: TodoItem?
    weak var delegate: TaskCellDelegate?

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()


    private lazy var checkBox: UIButton = {
        let image = UIImage(named: "arrow")
        let checkBox = UIButton()
        checkBox.setImage(image, for: .normal)
        checkBox.tintColor = UIColor(named: "backPrimary")
        checkBox.addAction(UIAction(handler: { [weak self] _ in
            guard let self, var toDoItem else { return }
            toDoItem.isDone = !toDoItem.isDone
            setDone()
            delegate?.changeToDoItem(toDoItem)

        }), for: .touchUpInside)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        return checkBox
    }()

    private let arrow: UIImageView = {
        let arrow = UIImageView(image: UIImage(named: "arrow"))
        arrow.contentMode = .center
        arrow.translatesAutoresizingMaskIntoConstraints = false
        return arrow
    }()

    private lazy var mainStack: UIStackView = {
        let mainStack = UIStackView(arrangedSubviews: [importanceImage, textStack])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.spacing = 2
        mainStack.distribution = .fill


     //  mainStack.backgroundColor = .blue
        return mainStack
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
        let textStack = UIStackView(arrangedSubviews: [textTaskLabel, deadlineStack])
        textStack.axis = .vertical
        textStack.alignment = .leading
        return textStack
    }()

    private let textTaskLabel: UILabel = {
        let textTaskLabel = UILabel()
        textTaskLabel.numberOfLines = 3
        return textTaskLabel
    }()

    private let importanceImage: UIImageView = {
        let importanceImage = UIImageView()
        importanceImage.contentMode = .center
        importanceImage.isHidden = true
        return importanceImage
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
        let shape = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.size.height)
        shape.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16)).cgPath
        layer.mask = shape
        layer.masksToBounds = true
    }

    private func setupConstraints() {
        contentView.addSubview(checkBox)
        contentView.addSubview(mainStack)
        contentView.addSubview(arrow)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),

            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.heightAnchor.constraint(equalToConstant: 24),
            checkBox.widthAnchor.constraint(equalToConstant: 24),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -16),

            arrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrow.heightAnchor.constraint(equalToConstant: 12),
            arrow.widthAnchor.constraint(equalToConstant: 8),
        ])
    }



    func setUI(_ toDoItem: TodoItem) {
        textTaskLabel.text = toDoItem.text
//        if let deadline = toDoItem.deadline {
//            deadlineLabel.text = dateFormatter.string(from: deadline)
//            deadlineStack.isHidden = true
//          //  deadlineStack.isHidden = false
//        } else {
//           deadlineStack.isHidden = false
//          //  deadlineStack.isHidden = true
//        }


        if let deadline = toDoItem.deadline {
            deadlineLabel.text = dateFormatter.string(from: deadline)
            deadlineStack.isHidden = false // Показываем стэк
            calendarView.isHidden = false // Показываем иконку календаря
        } else {
            deadlineStack.isHidden = true // Скрываем стэк
            calendarView.isHidden = true // Скрываем иконку календаря
        }


        switch toDoItem.importance {
        case .important:
            importanceImage.isHidden = false
            importanceImage.image = UIImage(named: "item3")
        case .unimportant:
            importanceImage.isHidden = false
            importanceImage.image = UIImage(named: "item1")
        case .normal:
            importanceImage.isHidden = true
        }
        self.toDoItem = toDoItem
        setDone()
    }

    private func setDone() {
        guard let toDoItem else { return }
        if toDoItem.isDone {
            let imageDone = UIImage(named: "bounds")
            checkBox.setImage(imageDone, for: .normal)
            let attributedString = NSAttributedString(string: textTaskLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            textTaskLabel.attributedText = attributedString
            textTaskLabel.textColor = .lightGray
        } else if toDoItem.importance == .important {
            let imageRed = UIImage(named: "redBounds")
            checkBox.setImage(imageRed, for: .normal)
            textTaskLabel.textColor = UIColor(named: "text")
            let attributedString = NSAttributedString(string: textTaskLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.self])
            textTaskLabel.attributedText = attributedString
        } else {
            let imageEmpty = UIImage(named: "ellipse")
            checkBox.setImage(imageEmpty, for: .normal)
            textTaskLabel.textColor = UIColor(named: "text")
            let attributedString = NSAttributedString(string: textTaskLabel.text ?? "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.self])
            textTaskLabel.attributedText = attributedString
        }
    }
}
