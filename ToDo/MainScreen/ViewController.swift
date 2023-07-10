//
//  ViewController.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/16/23.
//


import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let myViewController = MyViewController()
        addChild(myViewController)
        myViewController.view.frame = view.bounds
        view.addSubview(myViewController.view)
        myViewController.didMove(toParent: self)
    }
}

