//
//  QueueDetailsViewController.swift
//  eNumerek
//
//  Created by Piotr on 05.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import UIKit
import Spring
import NVActivityIndicatorView

class QueueDetialsViewController: UIViewController {

    @IBOutlet weak var dataTime: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var currentNumber: UILabel!
    @IBOutlet weak var peopleInQueue: UILabel!
    @IBOutlet weak var activeHandlers: UILabel!
    @IBOutlet weak var handlingTime: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var dataSource: [[String]] = []
    var point:Int = 0
    var link:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }
    
    func setupLabels(){
        var letterPrefix = ""
        if(dataSource[point][5] != ""){
            if Int(String(dataSource[point][5])[0]) != nil {
                letterPrefix = String(dataSource[point][3])
            }
        }
        dataTime.text = "Aktualizacja: " + dataSource[point][0] + " " + dataSource[point][1]
        name.text = String(htmlEncodedString: dataSource[point][4]).lowercaseString.capitalizedString
        currentNumber.text = letterPrefix + dataSource[point][5]
        peopleInQueue.text = "Liczba oczekujących: " + dataSource[point][6]
        activeHandlers.text = "Aktywne stanowiska: " + dataSource[point][7]
        handlingTime.text = "Czas obsługi [min.]: " + dataSource[point][8]
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func refreshButtonAction(sender: AnyObject) {
        setupQueueData()
    }
    
    private func setupQueueData(){
        UIView.animateWithDuration(0.07, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.activityIndicatorView.stopAnimation()
            }, completion: nil)
        
        activityIndicatorView = NVActivityIndicatorView(frame:  indicatorView.bounds, type: .BallGridPulse, color: UIColor.whiteColor(), padding: 0)
        self.indicatorView.addSubview(activityIndicatorView)
        
        self.activityIndicatorView.startAnimation()
        
        if Reachability.isConnectedToNetwork() == true {
            EndpointDataManager.sharedInstance.getQueueData(link) { (queueData, state) in
                if state == "good" {
                    self.dataSource = queueData
                    self.activityIndicatorView.stopAnimation()
                    self.setupLabels()
                    }else{
                        self.activityIndicatorView.stopAnimation()
                    GeneralManager.sharedInstance.alertShow("Nie można było zaktualizować")
                }
            } } else {
                        self.activityIndicatorView.stopAnimation()
            GeneralManager.sharedInstance.alertShow("Brak połączenia z internetem")
        }
    }
    
}