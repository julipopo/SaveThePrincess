//
//  Soldier.swift
//  SaveThePrincess3.0
//
//  Created by julien simmer on 6/24/17.
//  Copyright © 2017 julien simmer. All rights reserved.
//

import Foundation
import RealmSwift

enum Gender:Int {
    case male = 0
    case female = 1
    case other = 2
}

class Soldier: Object {
    dynamic var idd :Int = 0
    dynamic var name = ""
    dynamic var color = ""
    dynamic var gender :Int = Gender.other.rawValue
    dynamic var age :Int = 0
    
    override static func primaryKey() -> String? {
        return "idd"
    }
    
}
