//
//  TaskViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/22/23.
//

import Foundation
import UIKit



class ResizingTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        let textSize = self.sizeThatFits(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: textSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}




class TaskViewController: UIViewController {
    
    
    let statusView: YaToDoStatusView = {
        let view = YaToDoStatusView()
        let statusSelector = StatusSelectorView()
        view.configure(with: statusSelector)
        return view
    }()
    
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @IBOutlet weak var todoTextField: UITextField!
    
    var todoItem: TodoItem?
    let fileCache = FileCache()
    let filename = "TodoItems"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fileCache.loadFromFile(filename: filename)
            if let item = fileCache.items.first {
                self.todoItem = item
                updateUIWithTodoItem(item)
            }
        } catch {
            print("Error loading file: \(error)")
        }
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        let textView = ResizingTextView()
        
        let placeholder = "Что надо сделать?"
        textView.attributedText = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)
        
        
        let titleLabel = UILabel()
        titleLabel.text = "Дело"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "SFProText-Regular", size: 8.5)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "SF Pro Text", size: 8.5)
        cancelButton.setTitleColor(UIColor(red: 0, green: 0.48, blue: 1, alpha: 1), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "SF Pro Text", size: 8.5)
        saveButton.setTitleColor(UIColor(red: 0, green: 0.48, blue: 1, alpha: 1), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        
        
        
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 8
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 8),
            bottomView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(.gray, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(deleteButton)
        
        
        
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            
            deleteButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            
        ])
        
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        
        
        
        
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            statusView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
        ])
        
        
        NSLayoutConstraint.activate([
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.height * 0.5),
            
            
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
        ])
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        
        contentView.addSubview(statusView)
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(bottomView)
        
        
    }
    
    
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if let todoItem = self.todoItem {
            fileCache.addItem(todoItem)
            do {
                try fileCache.saveToFile(filename: filename)
            } catch {
                print("Error saving file: \(error)")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let todoItem = self.todoItem {
            fileCache.removeItem(withId: todoItem.id)
            do {
                try fileCache.saveToFile(filename: filename)
            } catch {
                print("Error saving file: \(error)")
            }
            self.todoItem = nil
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    private func updateUIWithTodoItem(_ todoItem: TodoItem) {
        todoTextField.text = todoItem.text
    }
    
    
    
    
}




private func createLabeledView(withText text: String) -> UIView {
    let view = UIView()
    
    let label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    return view
}



private func createRectangleView(withText text: String) -> UIView {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 14
    
    let label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
    return view
}

extension TaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText.string == "Что надо сделать?" {
            textView.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.attributedText = NSAttributedString(string: "Что надо сделать?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
}
