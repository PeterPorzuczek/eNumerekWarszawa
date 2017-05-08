//
//  DepartmentDetailsViewController.swift
//  eNumerek
//
//  Created by Piotr on 05.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import UIKit
import Spring
import KeepBackgroundCell
import NVActivityIndicatorView

class DepartmentDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate  {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var segmentedTabControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: RefreshButton!
    
    var searchController = UISearchController()
    var searchBar = UISearchBar()
    var tableViewSearchHeader = UIView()
    private var isSearchBarHidden = true
    
    var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var activityIndicatorViewAdd = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var dataSource:[AnyObject] = [[],[],[]]
    private var filteredDataSource:[[String]] = []
    var dataSourceToPassToReservation:[String] = []
    var dataSourceToPassToQueueDetails:[[String]] = []
    var pointToPass:Int = 0

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(self.searchController.active){
            return 1
        }else{
            if dataSource[0].count != 0{
                return 1
            }else{
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedTabControl.selectedSegmentIndex == 0 {
            if (self.searchController.active) {
                return self.filteredDataSource.count
            }else{
                return dataSource[1].count
            }
        }
        if segmentedTabControl.selectedSegmentIndex == 1 {
            if (self.searchController.active) {
                return self.filteredDataSource.count
            }else{
            return dataSource[2].count
            }
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var row = indexPath.row
        if (self.searchController.active) {
            row = Int(filteredDataSource[row][0])!
        }
        if segmentedTabControl.selectedSegmentIndex == 0 {
            if let cell = self.tableView?.dequeueReusableCellWithIdentifier("queueCell") {
                cell.keepSubviewBackground = true
                (cell.contentView.viewWithTag(1) as! SpringView).layer.shouldRasterize = true
                (cell.contentView.viewWithTag(1) as! SpringView).layer.rasterizationScale = UIScreen.mainScreen().scale
                
                (cell.contentView.viewWithTag(100)! as UIView).backgroundColor = UIColor ( red: 0.2471, green: 0.1882, blue: 0.5608, alpha: 1.0 )
                var letterPrefix = ""
                if((dataSource[1] as! [[String]])[row][5] != ""){
                    if Int(String((dataSource[1] as! [[String]])[row][5])[0]) != nil {
                        letterPrefix = String((dataSource[1] as! [[String]])[row][3])
                    }
                }else{
                    (cell.contentView.viewWithTag(100)! as UIView).backgroundColor = UIColor ( red: 0.9059, green: 0.8902, blue: 0.9216, alpha: 1.0 )
                }
                if String((dataSource[1] as! [[String]])[row][6]) == "0"{
                    (cell.contentView.viewWithTag(101)! as UIView).backgroundColor = UIColor ( red: 0.9059, green: 0.8902, blue: 0.9216, alpha: 1.0 )
                    (cell.contentView.viewWithTag(9) as! UILabel).textColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.152693965517241 )
                }else{
                    (cell.contentView.viewWithTag(101)! as UIView).backgroundColor = UIColor ( red: 0.2471, green: 0.1882, blue: 0.5608, alpha: 1.0 )
                    (cell.contentView.viewWithTag(9) as! UILabel).textColor = UIColor.whiteColor()
                }
                (cell.contentView.viewWithTag(4) as! UILabel).text = String(htmlEncodedString:(dataSource[1] as! [[String]])[row][4]).capitalizedString
                 (cell.contentView.viewWithTag(3) as! UILabel).text = String((dataSource[1] as! [[String]])[row][3]) + ""
                (cell.contentView.viewWithTag(8) as! UILabel).text = letterPrefix + "" + String((dataSource[1] as! [[String]])[row][5]).lowercaseString.capitalizedString
                (cell.contentView.viewWithTag(9) as! UILabel).text = String((dataSource[1] as! [[String]])[row][6])
                return cell
            }else{
                return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "errorIdentifier")
            }
        }
        if segmentedTabControl.selectedSegmentIndex == 1 {
            if let cell = self.tableView?.dequeueReusableCellWithIdentifier("reservationCell") {
                cell.keepSubviewBackground = true
                (cell.contentView.viewWithTag(1) as! SpringView).layer.shouldRasterize = true
                (cell.contentView.viewWithTag(1) as! SpringView).layer.rasterizationScale = UIScreen.mainScreen().scale
                
                (cell.contentView.viewWithTag(4) as! UILabel).text = String(htmlEncodedString:(dataSource[2] as! [[String]])[row][1]).lowercaseString.capitalizedString
                return cell
            }else{
                return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "errorIdentifier")
            }
        }else{
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "errorIdentifier")
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerIdentifier = ""
        if segmentedTabControl.selectedSegmentIndex == 0 {
            headerIdentifier = "departmentQueueHeaderCell"
        }
        if segmentedTabControl.selectedSegmentIndex == 1 {
            headerIdentifier = "departmentReservationHeaderCell"
        }
        if let header = self.tableView.dequeueReusableCellWithIdentifier(headerIdentifier) {
            (header.contentView.viewWithTag(1) as! UILabel).text = (dataSource[0] as! [String])[section]
            if((dataSource[1] as! [[String]]).count != 0) {
                if segmentedTabControl.selectedSegmentIndex == 0 {
                    (header.contentView.viewWithTag(2) as! UILabel).text = "Aktualizacja: " + (self.dataSource[1] as! [[String]])[section][0] + " " + (self.dataSource[1] as! [[String]])[section][1]
                }
            }
            return header as UIView?
        }else{
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "errorIdentifier")
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            (cell.contentView.viewWithTag(1) as! SpringView).animation = "pop"
            (cell.contentView.viewWithTag(1) as! SpringView).animate()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row = indexPath.row
        if (self.searchController.active) {
            row = Int(filteredDataSource[row][0])!
        }
        if segmentedTabControl.selectedSegmentIndex == 0 {
            dataSourceToPassToQueueDetails = (dataSource[1] as! [[String]])
            pointToPass = row
            showHideSearchBar()
            self.performSegueWithIdentifier("toQueueDetailsView", sender: self)
        }
        if segmentedTabControl.selectedSegmentIndex == 1 {
            dataSourceToPassToReservation = (dataSource[2] as! [[String]])[row]
            showHideSearchBar()
            self.performSegueWithIdentifier("toReservationView", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 231.0/255, green: 227.0/255, blue: 235.0/255, alpha: 1.0).CGColor
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if segmentedTabControl.selectedSegmentIndex == 0 {
            return 80
        }
        if segmentedTabControl.selectedSegmentIndex == 1 {
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        self.searchController.active = false
        dispatch_async(dispatch_get_main_queue(),{
            self.setupQueueData()
        })
    }
    
    @IBAction func searchButtonAction(sender: AnyObject) {
        setupSearchBar()
        showHideSearchBar()
    }
    
    @IBAction func refreshButtonAction(sender: AnyObject) {
        setupQueueData()
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func segmentedTabControlerSelectedAction(sender: AnyObject) {
        if(segmentedTabControl.selectedSegmentIndex == 0){
            self.title = "Kolejki"
            tableView.reloadData()
        }
        if(segmentedTabControl.selectedSegmentIndex == 1){
            self.title = "Rezerwacje"
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toQueueDetailsView") {
            let queueDetails = (segue.destinationViewController as! QueueDetialsViewController)
            queueDetails.dataSource = dataSourceToPassToQueueDetails
            queueDetails.point = pointToPass
            queueDetails.link = (dataSource[0] as! [String])[1]
        }
        if(segue.identifier == "toReservationView") {
            let reservation = (segue.destinationViewController as! ReservationViewController)
            reservation.dataSource = dataSourceToPassToReservation
        }
    }
    
    private func setupQueueData(){
        if dataSource[2].count == 0 {
            segmentedTabControl.setEnabled(false, forSegmentAtIndex: 1)
        }else{
            segmentedTabControl.setEnabled(true, forSegmentAtIndex: 1)
        }
        UIView.animateWithDuration(0.07, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.refreshButton.alpha = 0
            self.activityIndicatorView.stopAnimation()
            self.activityIndicatorViewAdd.stopAnimation()
            }, completion: nil)
        
        activityIndicatorView = NVActivityIndicatorView(frame:  indicatorView.bounds, type: .BallGridPulse, color: UIColor.whiteColor(), padding: 0)
        self.indicatorView.addSubview(activityIndicatorView)
        activityIndicatorViewAdd = NVActivityIndicatorView(frame: CGRectMake(0.0, 0.0, 60.0, 60.0), padding: 0, type: .BallGridPulse, color:  /*UIColor.whiteColor()*/UIColor(red: 80.5/255, green: 51.6/255, blue: 162.6/255, alpha: 1.0))
        activityIndicatorViewAdd.center = self.view.center
        self.view.addSubview(activityIndicatorViewAdd)
        
        self.activityIndicatorView.startAnimation()
        self.activityIndicatorViewAdd.startAnimation()
        
        if self.dataSource[1].count != 0{
            self.activityIndicatorViewAdd.stopAnimation()
        }
        
        if Reachability.isConnectedToNetwork() == true {
            EndpointDataManager.sharedInstance.getQueueData((dataSource[0] as! [String])[1]) { (queueData, state) in
                if state == "good" {
                   self.dataSource[1] = queueData
                    self.tableView.reloadData({
                        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.activityIndicatorView.stopAnimation()
                            self.activityIndicatorViewAdd.stopAnimation()
                            self.refreshButton.alpha = 1
                            self.tableView.alpha = 1
                            }, completion: nil)
                    }) }else{
                    self.activityIndicatorView.stopAnimation()
                    self.activityIndicatorViewAdd.stopAnimation()
                    self.refreshButton.alpha = 1
                    GeneralManager.sharedInstance.alertShow("Nie można było zaktualizować")
                }
            } } else {
            self.activityIndicatorView.stopAnimation()
            self.activityIndicatorViewAdd.stopAnimation()
            self.refreshButton.alpha = 1
            GeneralManager.sharedInstance.alertShow("Brak połączenia z internetem")
        }
    }
    
    private func setupSearchBar(){
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            //controller.navigationController?.setToolbarHidden(false, animated: false)
            controller.searchBar.clipsToBounds = true
            
            controller.searchBar.layer.borderWidth = 1
            controller.searchBar.layer.borderColor = UIColor(red: 231.0/255, green: 227.0/255, blue: 235.0/255, alpha: 1.0).CGColor
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Szukaj"
            controller.searchBar.setValue("Anuluj", forKey:"_cancelButtonText")
            UIBarButtonItem.appearance().setTitleTextAttributes(([NSForegroundColorAttributeName: UIColor ( red: 0.2471, green: 0.1882, blue: 0.5608, alpha: 1.0 )]), forState: UIControlState.Normal) //Not exactly what should it be - changes appearance to all UIBarButtonItem buttons.
            controller.searchBar.barTintColor = UIColor ( red: 0.9059, green: 0.8902, blue: 0.9216, alpha: 1.0 )
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        searchBar = searchController.searchBar
        searchBar.delegate = self
        tableViewSearchHeader = self.tableView.tableHeaderView!
        self.tableView.reloadData()
    }
    
    private func showHideSearchBar() {
        var frame: CGRect
        if !isSearchBarHidden {
            frame = CGRectMake(0, 0, 320, 0.0)
            self.isSearchBarHidden = true
        } else {
            frame = CGRectMake(0, 0, 320, 44)
            self.isSearchBarHidden = false
        }
        UIView.animateWithDuration(0.07, animations: {() -> Void in
            self.searchController.searchBar.frame = frame
            }, completion: {(finished: Bool) -> Void in
                if self.isSearchBarHidden {
                    self.tableView.tableHeaderView = nil
                } else {
                    self.tableView.tableHeaderView = self.tableViewSearchHeader
                }
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredDataSource.removeAll(keepCapacity: false)
        if segmentedTabControl.selectedSegmentIndex == 0 {
            for x in 0...(dataSource[1] as! [[String]]).count-1{
                if (dataSource[1] as! [[String]])[x][4].lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) {
                    filteredDataSource.append(["\(x)"])
                }
            }
            self.tableView.reloadData()
        }
        if segmentedTabControl.selectedSegmentIndex == 1 {
            for x in 0...(dataSource[2] as! [[String]]).count-1{
                if (dataSource[2] as! [[String]])[x][1].lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) {
                    filteredDataSource.append(["\(x)"])
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        showHideSearchBar()
    }
    
}