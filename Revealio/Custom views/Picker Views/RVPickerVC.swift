//
//  RVPickerView.swift
//  Revealio
//
//  Created by hanif hussain on 06/01/2025.
//
import UIKit

protocol RVPickerVCDelegate: AnyObject {
    func didSelect(dialingAreaCode: DialingAreaCode)
}

class RVPickerVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    private var picker = UIPickerView()
    private var dataSource: [DialingAreaCode] = []
    weak var rvPickVCDelegate: RVPickerVCDelegate?
    
    init(dataSource: [DialingAreaCode]) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        view.addSubview(picker)
        picker.pinToSafeAreaEdges(of: view)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return dataSource.count }
    
    
    //func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return dataSource[row].flag }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { return 60 }
    
    
    //func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat { return 200 }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rvPickVCDelegate?.didSelect(dialingAreaCode: dataSource[row])
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let contentView = RVContentView()
        contentView.translatesAutoresizingMaskIntoConstraints =  true
        contentView.frame = view?.frame ?? .zero
        let flagLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .title1), alignment: .left, textColor: .black, text: dataSource[row].flag)
        let countryLabel = RVBodyLabel(textAlignment: .left)
        countryLabel.text = dataSource[row].name
        contentView.addSubviews(flagLabel, countryLabel)
        
        NSLayoutConstraint.activate([
            flagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            flagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            flagLabel.widthAnchor.constraint(equalToConstant: 40),
            flagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            countryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            countryLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 2),
            countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            countryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        return contentView
    }
}
