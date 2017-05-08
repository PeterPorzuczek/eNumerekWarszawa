//
//  ReservationViewController.swift
//  eNumerek
//
//  Created by Piotr on 05.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import UIKit
import Spring

class ReservationViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var reservationTitle: UILabel!
    
    var dataSource:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if dataSource.count != 0 {
            reservationTitle.text = String(htmlEncodedString:dataSource[1]).lowercaseString.capitalizedString
            if Reachability.isConnectedToNetwork() == true {
                webView.loadRequest(NSURLRequest(URL: NSURL (string: dataSource[0])!))
            }else{
                GeneralManager.sharedInstance.alertShow("Brak połączenia z internetem")
            }
        }
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}