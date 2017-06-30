//
//  NewSoldierViewController.swift
//  SaveThePrincess3.0
//
//  Created by julien simmer on 6/24/17.
//  Copyright © 2017 julien simmer. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewSoldierDelegate {
    func didNewSoldierEndCreated()
}

class NewSoldierViewController: UIViewController, UITextFieldDelegate {
    
    var soldiersCount = 0
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderPicker: UISegmentedControl!
    @IBOutlet weak var colorPicker: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var femaleImageView: UIImageView!
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet var textFields: [UITextField]!
    
    var delegate: HomeViewController?
    
    let authorizedHexCharacter = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","a","b","c","d","e","f"]
    
    let soldier : Soldier = Soldier()
    var shieldLayer = ShieldLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(hex:"2F2F2F")
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelAction))
        let createButton = UIBarButtonItem(title: "CREATE", style: UIBarButtonItemStyle.done, target: self, action: #selector(createAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, createButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        for tF in textFields {
            tF.delegate = self
            tF.inputAccessoryView = toolBar
        }
        
        shieldLayer = ShieldLayer(withSize: colorView.frame.size, andColor: "3498db")
        colorView.layer.addSublayer(shieldLayer)
        
        nameTextField.placeholder = "SOLDIER \(soldiersCount)"
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        })
    }
    
    func createAction() {
        //On prends les valeurs renseignées, si elles sont vides, on prends les valeurs par defauts dans les placeholder
        let name = nameTextField.text!.length > 0 ? nameTextField.text! : nameTextField.placeholder!
        let color = colorPicker.text!.length > 0 ? colorPicker.text! : colorPicker.placeholder!
        let age = ageTextField.text!.length > 0 ? Int(ageTextField.text!)! : Int(ageTextField.placeholder!)!
        
        let soldier = Soldier(value: [soldiersCount, name, color, genderPicker.selectedSegmentIndex, age])
        let realm = try! Realm()
        try! realm.write {
            realm.create(Soldier.self, value: soldier, update: true)
            view.endEditing(true)
            weak var weakSelf = self
            self.dismiss(animated: true, completion: {
                weakSelf?.delegate?.didNewSoldierEndCreated()
            })
        }
    }

    func cancelAction() {
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func genderChanged(_ sender: Any) {
        maleImageView.isHidden = genderPicker.selectedSegmentIndex != Gender.male.rawValue
        femaleImageView.isHidden = genderPicker.selectedSegmentIndex != Gender.female.rawValue
    }
    
    @IBAction func colorDidChanged(_ sender: UITextField) {
        if sender.text!.length == 6{
            shieldLayer.changeColorTo(newColor: sender.text!)
            colorPicker.placeholder = sender.text!
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField {
            return range.location+string.length < 11
        } else if textField == ageTextField {
            return range.location+string.length  < 3
        } else if textField == colorPicker {
            var foundNonAuthorized = false
            for c in string.characters {
                if !authorizedHexCharacter.contains("\(c)") {
                    foundNonAuthorized = true
                    break
                }
            }
            return range.location+string.length < 7 && !foundNonAuthorized
        }
        return true
    }
}
