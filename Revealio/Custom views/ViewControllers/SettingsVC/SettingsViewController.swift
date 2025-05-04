//
//  SettingsViewController.swift
//  Revealio
//
//  Created by hanif hussain on 03/05/2025.
//
import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: RVTableView!
    private let sections = 5

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        tableView = RVTableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let myCell = SettingsProfileCell(style: .default, reuseIdentifier: "ProfileCell")
            myCell.set()
            return myCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! UITableViewCell
            cell.textLabel?.text = "HELPRL"
            return cell
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int { return sections }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 1
        }
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 50
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return UITableView.automaticDimension
        }
    }
}
