//
//  LaunchViewController.swift
//  eNumerek
//
//  Created by Piotr on 05.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import UIKit
import Spring

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.view.viewWithTag(3) as! SpringImageView).transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(M_PI * (7.22) / 180.0)), -5.18, -3.55)
        
        (self.view.viewWithTag(4) as! SpringView).animate()
        
        UIView.animateWithDuration(0.25, delay: 1.05, options: [], animations: {
            (self.view.viewWithTag(3) as! SpringImageView).transform = CGAffineTransformIdentity
        }, completion:  { _ in
            (self.view.viewWithTag(5) as! SpringView).animateToNext({ 
                self.performSegueWithIdentifier("toDepartmentChoiceView", sender: self)
            })
        })
        
    }
    
}