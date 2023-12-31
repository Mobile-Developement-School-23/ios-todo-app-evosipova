//
//  MyViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/21/23.
//

import Foundation

import UIKit

class MyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Мои дела"
        label.textAlignment = .center
        _ = UIFont(name: "SFProDisplay-Bold", size: 34)
        _ = [NSAttributedString.Key.kern: 0.374]
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("Нажать", for: .normal)
        
        button.tintColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func buttonTapped() {
        let taskViewController = TaskViewController()
        present(taskViewController, animated: true, completion: nil)
    }
}
