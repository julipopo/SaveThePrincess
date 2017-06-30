//
//  ShieldLayer.swift
//  SaveThePrincess3.0
//
//  Created by julien simmer on 6/28/17.
//  Copyright © 2017 julien simmer. All rights reserved.
//

import UIKit

class ShieldLayer: CAShapeLayer {
    
    convenience init(withSize : CGSize, andColor : String) {
        
        self.init()
        
        let kWidth = withSize.width
        let kHeight = withSize.height
        
        let Path = UIBezierPath()
        Path.move(to: CGPoint(x: 0, y:10))
        Path.addQuadCurve(to: CGPoint(x: kWidth/2, y:0), controlPoint: CGPoint(x: kWidth/3, y: 8))
        Path.addQuadCurve(to: CGPoint(x: kWidth, y:10), controlPoint: CGPoint(x: 2*kWidth/3, y: 8))
        Path.addLine(to: CGPoint(x: kWidth, y: 40))
        Path.addQuadCurve(to: CGPoint(x: kWidth/2, y:kHeight), controlPoint: CGPoint(x: kWidth-10, y: kHeight-10))
        Path.addQuadCurve(to: CGPoint(x: 0, y:40), controlPoint: CGPoint(x: 10, y: kHeight-10))
        Path.close()
        
        backgroundColor = UIColor.clear.cgColor
        strokeColor = UIColor(hex: "707070").cgColor
        path = Path.cgPath
        lineWidth = 4
        fillColor = UIColor(hex: andColor).cgColor
        frame = CGRect(x: 0, y: 0, width: kWidth, height: kHeight)
    }
    
    func changeColorTo(newColor : String) {
        fillColor = UIColor(hex: newColor).cgColor
    }

}
