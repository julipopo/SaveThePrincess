//
//  LaunchViewController.swift
//  SaveThePrincess3.0
//
//  Created by julien simmer on 6/30/17.
//  Copyright © 2017 julien simmer. All rights reserved.
//

import UIKit
import RealmSwift

class LaunchViewController: UIViewController {

    @IBOutlet weak var topConstraintDoorImageView: NSLayoutConstraint!
    @IBOutlet weak var doorImageView: UIImageView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    var isFromOpening : Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        
        let kHeight = doorImageView.frame.height
        
        topConstraintDoorImageView.constant = isFromOpening ? -kHeight : 0
        view.layoutIfNeeded()
        
        topConstraintDoorImageView.constant = isFromOpening ? 0 : -kHeight
        UIView.animate(withDuration: isFromOpening ? 1 : 2, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finish in
            if self.isFromOpening {
                self.performSegue(withIdentifier: "launchToGameID", sender: nil)
            } else {
                self.replayButton.isHidden = false
                self.resetButton.isHidden = false
            }
        })
        
        resetButton.isHidden = isFromOpening
        replayButton.isHidden = isFromOpening
    }

    @IBAction func replayButtonAction(_ sender: Any) {
        isFromOpening = true
        viewDidAppear(false)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: K.UD.firstOpening)
        UserDefaults.standard.removeObject(forKey: K.UD.doorLifeLevel)
        let realm = try! Realm()
        try! realm.write {
                realm.deleteAll()
        }
        isFromOpening = true
        viewDidAppear(false)
    }
}
