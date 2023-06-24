//
//  StatusSelection.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 6/22/23.
//

import Foundation
import UIKit

protocol StatusSelectionProtocol: UIView {
    func getStatus() -> String
}



class StatusSelectorView: UIView, StatusSelectionProtocol {
    private let label1 = UILabel()
    private let segmentControl = UISegmentedControl(items: [ UIImage(named: "item1.svg")?.withRenderingMode(.alwaysOriginal) as Any, "нет",  UIImage(named: "item3.svg")?.withRenderingMode(.alwaysOriginal) as Any])

    private var datePickerHeightConstraint: NSLayoutConstraint!


    private let label2 = UILabel()
    private let dateButton = UIButton(type: .system)
    private let separator = UIView()
    private let separator2 = UIView()
    private let toggleSwitch = UISwitch()
    private let datePicker = UIDatePicker()

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.clipsToBounds = true

        label1.text = "Важность"
        label2.text = "Сделать до"
        datePicker.isHidden = true
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        separator2.backgroundColor = .lightGray
        separator2.translatesAutoresizingMaskIntoConstraints = false
        separator2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator2.isHidden = true
        
        
        let horizontalStackView1 = UIStackView(arrangedSubviews: [label1, segmentControl])
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.spacing = 16
        horizontalStackView1.distribution = .fillProportionally
        horizontalStackView1.alignment = .center
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false

        horizontalStackView1.heightAnchor.constraint(equalToConstant: 56).isActive = true


        
        dateButton.setTitleColor(.systemBlue, for: .normal)
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false


        let verticalStackView = UIStackView(arrangedSubviews: [label2, dateButton])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.distribution = .fillProportionally
        verticalStackView.alignment = .fill
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false


        let horizontalStackView2 = UIStackView(arrangedSubviews: [verticalStackView, spacerView, toggleSwitch])
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.spacing = 10
        horizontalStackView2.distribution = .fill
        horizontalStackView2.alignment = .center
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false

        horizontalStackView2.heightAnchor.constraint(equalToConstant: 56).isActive = true

        
        toggleSwitch.setContentHuggingPriority(.required, for: .horizontal)
        toggleSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)


        toggleSwitch.addTarget(self, action: #selector(toggleSwitched), for: .valueChanged)

        let stackView = UIStackView(arrangedSubviews: [horizontalStackView1, separator, horizontalStackView2, separator2, datePicker])  // separator2 added here

        horizontalStackView1.setCustomSpacing(16, after: separator)

        //stackView.setCustomSpacing(16, after: horizontalStackView2)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(5, after: horizontalStackView1)
        stackView.setCustomSpacing(10, after: separator)
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill

        stackView.translatesAutoresizingMaskIntoConstraints = false


        
        self.addSubview(stackView)

        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),


            toggleSwitch.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -12),
        ])

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getStatus() -> String {
        let toggleStatus = toggleSwitch.isOn ? "On" : "Off"
        let segmentStatus = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex) ?? "No selection"
        return "Toggle: \(toggleStatus), Segment: \(segmentStatus)"
    }
    
    
    @objc func switchChanged(_ sender: UISwitch) {
        datePicker.isHidden = !sender.isOn
        
        
    }
    
    @objc func dateButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.datePicker.isHidden = !self.datePicker.isHidden
            self.separator2.isHidden = !(!self.datePicker.isHidden && self.toggleSwitch.isOn)

        })
    }


    @objc func toggleSwitched(_ sender: UISwitch) {
        dateButton.isHidden = !sender.isOn
        self.datePicker.isHidden = true
        self.separator2.isHidden = true
        if sender.isOn {
            
            var dateComponents = DateComponents()
            dateComponents.day = 1
            let nextDate = Calendar.current.date(byAdding: dateComponents, to: Date())
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateButton.setTitle(formatter.string(from: nextDate!), for: .normal)
            datePicker.date = nextDate!
        }



    }

    

    
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateButton.setTitle(formatter.string(from: sender.date), for: .normal)
    }
}



final class YaToDoStatusView: UIView {
    
    private enum Constants {
        static let verticalPadding: CGFloat = 12
        static let leftPadding: CGFloat = 8
        static let selectableRightPadding: CGFloat = 6
        static let labelStackRightPadding: CGFloat = 8
        static let stackViewSpacing: CGFloat = 4
    }
    
    struct Model {
        var bgColor: UIColor
        var title: String
        var description: String?
    }
    
    private let infolabel: UILabel = UILabel()
    private let titleLabel: UILabel = UILabel()
    private let labelStack: UIStackView = UIStackView()
    private var selectable: StatusSelectionProtocol? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with selectable: StatusSelectionProtocol) {
        if let selectable = self.selectable {
            selectable.removeFromSuperview()
        }
        
        self.selectable = selectable
        addSubview(selectable)
        selectable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectable.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.verticalPadding),
            selectable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.verticalPadding),
            selectable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.leftPadding),
            selectable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.selectableRightPadding)
        ])
    }
    
    
    func configure(with model: Model) {
        titleLabel.text = model.title
        backgroundColor = model.bgColor
        
        infolabel.isHidden = true
        if let description = model.description {
            infolabel.text = description
            infolabel.isHidden = false
        }
    }
    
    func configure(description: String?) {
        infolabel.isHidden = true
        if let description = description {
            infolabel.text = description
            infolabel.isHidden = false
        }
    }
    
    func getData() -> String? {
        return selectable?.getStatus()
    }
    

}
