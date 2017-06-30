//
//  ViewController.swift
//  SaveThePrincess3.0
//
//  Created by julien simmer on 6/24/17.
//  Copyright © 2017 julien simmer. All rights reserved.
//

import UIKit
import AudioToolbox

import RealmSwift

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NewSoldierDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerLifeBarView: UIView!
    @IBOutlet weak var lifeBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lifeLevelLabel: UILabel!
    @IBOutlet weak var lifeBarView: UIView!
    @IBOutlet weak var StrikeView: UIView!
    @IBOutlet weak var viewForCrack: UIView!
    @IBOutlet weak var noSoldierLabel: UILabel!
    
    @IBOutlet weak var explosionView: UIImageView!
    @IBOutlet weak var kWidthExploision: NSLayoutConstraint!
    @IBOutlet weak var kHeightExplosion: NSLayoutConstraint!
    
    var tempAttackCell : SoldierCell = SoldierCell()
    var tempFrameInCollectionView : CGRect = CGRect()
    var tempFrameInMainView : CGRect = CGRect()
    var lifeBarTotalWidth = 0
    var soldierDatas :[Soldier] = []
    let doorBrokenLevel = -2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On remplit la base de soldat à la première ouverture de l'app
        if(UserDefaults.standard.integer(forKey: K.UD.firstOpening) != 42){
            let superMan = Soldier(value: [     0, "Ryan",          "f1c40f", Gender.male.rawValue,     34])
            let vincetto = Soldier(value: [     1, "Vincetto",      "e74c3c", Gender.male.rawValue,     39])
            let wonderwoman = Soldier(value: [  2, "LaraCroft",     "9b59b6", Gender.female.rawValue,   29])
            let heropro = Soldier(value: [      3, "Inconnu",       "d35400", Gender.male.rawValue,     33])
            let megator = Soldier(value: [      4, "MegaTor",       "ffbb11", Gender.male.rawValue,     99])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add([superMan, vincetto, wonderwoman, heropro, megator], update: true)
            }
             UserDefaults.standard.set(42, forKey: K.UD.firstOpening)
        }
        
        lifeBarTotalWidth = Int(containerLifeBarView.frame.width)-8
        addValueToDoorLevel(add: 0)
        collectionView.register(UINib.init(nibName: "SoldierCell", bundle: nil), forCellWithReuseIdentifier: "SoldierCellID")
        getSoldier()
    }
    
    func getSoldier(){
        let realm = try! Realm()
        soldierDatas = Array(realm.objects(Soldier.self))
        self.collectionView.reloadData()
    }
    
    func addValueToDoorLevel(add : Int){
        // Get current level
        let int = UserDefaults.standard.integer(forKey: K.UD.doorLifeLevel)
        let lastValue = int == 0 ? 100 : int-1
        let newValue = lastValue+add > 0 ? lastValue+add : doorBrokenLevel
        let newValueToDisplay = newValue == doorBrokenLevel ? 0 : newValue
        if newValue == doorBrokenLevel {
            launchOpeningDoorAnimation()
        } else if add != 0 {
            self.killSoldiers(levelDoor: newValueToDisplay)
        }
    
        // Update UI
        lifeBarWidthConstraint.constant = CGFloat(lifeBarTotalWidth*(newValueToDisplay)/100)
        lifeLevelLabel.text! = "\(newValueToDisplay) / 100"
        animateAttack(newValue: newValue)
        
        // Save the new level
        UserDefaults.standard.set(newValue+1, forKey: K.UD.doorLifeLevel)
    }
    
    func animateAttack(newValue : Int){
        let nbrCrack = Int(newValue/10)
        let currentNbrCrack = viewForCrack.subviews.count
        let borneInf = 4*nbrCrack
        let borneSup = 39-currentNbrCrack
        if nbrCrack < 10 && borneSup >= borneInf{
            for _ in borneInf...borneSup {
                let x = arc4random_uniform(UInt32(viewForCrack.frame.width-90)) + 20
                let y = arc4random_uniform(UInt32(viewForCrack.frame.height-90)) + 20
                let crack = UIImageView(frame: CGRect(x: Int(x), y: Int(y), width: 50, height: 50))
                let randomName = "crack\(Int(arc4random_uniform(UInt32(3))))"
                crack.image = UIImage(named: randomName)
                viewForCrack.addSubview(crack)
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finish in
            if newValue == self.doorBrokenLevel {self.launchOpeningDoorAnimation()}
        })
    }
    
    
    
    func launchOpeningDoorAnimation() {
        
        self.performSegue(withIdentifier: "GameToLaunchID", sender: self)
        
        // Reset Code
        UserDefaults.standard.set(101, forKey: K.UD.doorLifeLevel)
        addValueToDoorLevel(add: 0)
        for view in viewForCrack.subviews {
            view.removeFromSuperview()
        }
    }
    
    func didNewSoldierEndCreated() {
        getSoldier()
        collectionView.scrollToItem(at: IndexPath(row: soldierDatas.count-1, section: 0), at: .left, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noSoldierLabel.isHidden = soldierDatas.count != 0
        return soldierDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:SoldierCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoldierCellID", for: indexPath) as! SoldierCell
        let soldier = soldierDatas[indexPath.row]
        cell.setupWithSoldier(soldier: soldier)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        longPressRecognizer.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPressRecognizer)
        
        return cell
    }
    
    func longPressed(sender : UILongPressGestureRecognizer) {
        switch sender.state {
            case .began:
                let cell:SoldierCell = sender.view! as! SoldierCell
                tempFrameInCollectionView = cell.frame
                let tempFrame = collectionView.contentOffset
                tempFrameInMainView = CGRect(x: cell.frame.origin.x-tempFrame.x, y: collectionView.frame.minY+5, width: cell.frame.width, height: cell.frame.height)
                tempAttackCell = cell
                tempAttackCell.frame = tempFrameInMainView
                self.view.addSubview(tempAttackCell)
                StrikeView.isHidden = false
                tempAttackCell.center = sender.location(in: self.view)
            case .changed:
                tempAttackCell.center = sender.location(in: self.view)
            case .ended:
                if StrikeView.frame.contains(tempAttackCell.center) {
                    addValueToDoorLevel(add: -tempAttackCell.age)
                    launchExplosion()
                }
                UIView.animate(withDuration: 0.4, animations: {
                    self.tempAttackCell.frame = self.tempFrameInMainView
                }, completion: { finish in
                    self.tempAttackCell.frame = self.tempFrameInCollectionView
                    self.collectionView.addSubview(self.tempAttackCell)
                    self.StrikeView.isHidden = true
                })
            default:
                print("other")
        }
    }
    
    func setExplsionSizeTo(size : CGFloat, duration : Double, alpha : CGFloat, end : Bool) {
        kWidthExploision.constant = 1.2*size
        kHeightExplosion.constant = size
        UIView.animate(withDuration: duration, animations: {
            self.explosionView.alpha = alpha
            self.view.layoutIfNeeded()
        }, completion: { finish in
            if(end) {
                UIView.animate(withDuration: 0.6, animations: {
                    self.explosionView.alpha = 0
                }, completion: { finish in
                    self.explosionView.isHidden = true
                })
            }
        })
    }
    
    func killSoldiers(levelDoor :Int) {
        let nbrToKill = Int(arc4random_uniform(UInt32(levelDoor-1)) + 1)
        let realm = try! Realm()
        if nbrToKill >= soldierDatas.count  {
            try! realm.write {
                realm.deleteAll()
                getSoldier()
                self.presentAlert(withTitle: "Attention", andMessage: "All your soldiers had been killed", callback: {
                    self.collectionView.reloadData()
                })
            }
        } else {
            var array: [Soldier] = []
            for i in soldierDatas.count-nbrToKill...soldierDatas.count-1{ // On supprime les x derniers soldats de la base
                array.append(soldierDatas[i])
            }
            try! realm.write {
                realm.delete(array)
                getSoldier()
                self.presentAlert(withTitle: "Attention", andMessage: "\(nbrToKill) soldiers had been killed", callback: {
                    self.collectionView.reloadData()
                })
            }
        }
    }  
    
    func launchExplosion() {
        setExplsionSizeTo(size: 40, duration: 0, alpha: 0, end: false)
        explosionView.isHidden = false
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        setExplsionSizeTo(size: 400, duration: 0.6, alpha : 1, end: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameToLaunchID"  {
            let newVC:LaunchViewController = segue.destination as! LaunchViewController
            newVC.isFromOpening = false
        } else {
            let newVC:NewSoldierViewController = segue.destination as! NewSoldierViewController
            newVC.soldiersCount = soldierDatas.count
            newVC.modalPresentationStyle = .overFullScreen
            newVC.delegate = self
        }
    }
}
