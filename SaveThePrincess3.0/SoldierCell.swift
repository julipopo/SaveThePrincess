//
//  SoldierCell2.swift
//  SaveThePrincess3.0
//
//  Created by julien simmer on 6/27/17.
//  Copyright © 2017 julien simmer. All rights reserved.
//

import UIKit

class SoldierCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var femaleImageView: UIImageView!
    
    var age: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
    }
    
    func setupWithSoldier(soldier : Soldier) {
        age = soldier.age
        nameLabel.text = soldier.name
        
        ageLabel.text = "\(soldier.age)"
        
        maleImageView.isHidden = soldier.gender != Gender.male.rawValue
        femaleImageView.isHidden = soldier.gender != Gender.female.rawValue
        
        let shieldLayer = ShieldLayer(withSize: colorView.frame.size, andColor: soldier.color)
        colorView.layer.addSublayer(shieldLayer)
     }
}
