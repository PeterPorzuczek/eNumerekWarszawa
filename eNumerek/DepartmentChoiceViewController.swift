//
//  DepartmentChoiceViewController.swift
//  eNumerek
//
//  Created by Piotr on 05.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import UIKit
import Spring
import KeepBackgroundCell
import NVActivityIndicatorView

class DepartmentChoiceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var informationAddtionalLabel: SpringLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var refreshButton: RefreshButton!
    
    @IBOutlet weak var infoMaskView: SpringView!
    @IBOutlet weak var infoView: SpringView!
    
    var searchController = UISearchController()
    var searchBar = UISearchBar()
    var tableViewSearchHeader = UIView()
    private var isSearchBarHidden = true
    
    var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var activityIndicatorViewAdd = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    private var dataSource:[AnyObject] = [[],[],[]]
    private var filteredDataSource:[[String]] = []
    private var dataSourceToPass:[AnyObject] = [[],[],[]]

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(self.searchController.active){
            return 1
        }else{
            if dataSource[0].count != 0{
                return dataSource[0].count
            }else{
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.active) {
            return self.filteredDataSource.count
        }else{
            if dataSource[1][section].count != 0 {
                return dataSource[1][section].count
            }else{
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = self.tableView?.dequeueReusableCellWithIdentifier("departmentCell") {
            cell.keepSubviewBackground = true
            (cell.contentView.viewWithTag(1) as! SpringView).layer.shouldRasterize = true
            (cell.contentView.viewWithTag(1) as! SpringView).layer.rasterizationScale = UIScreen.mainScreen().scale
            if (self.searchController.active) {
                (cell.contentView.viewWithTag(4) as! UILabel).text = (dataSource[1] as! [[[String]]])[Int(filteredDataSource[indexPath.row][0])!][Int(filteredDataSource[indexPath.row][1])!][0]
            }else{
                (cell.contentView.viewWithTag(4) as! UILabel).text = (dataSource[1] as! [[[String]]])[indexPath.section][indexPath.row][0]
            }
            return cell
        }else{
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "errorIdentifier")
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = self.tableView.dequeueReusableCellWithIdentifier("departmentHeaderCell"){
            if (self.searchController.active) {
                (header.contentView.viewWithTag(1) as! UILabel).text = "Wyniki wyszukiwania: "
            }else{
                (header.contentView.viewWithTag(1) as! UILabel).text = (dataSource[0] as! [String])[section]
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
        if (self.searchController.active) {
            dataSourceToPass[0] = dataSource[1][Int(filteredDataSource[indexPath.row][0])!][Int(filteredDataSource[indexPath.row][1])!]
            dataSourceToPass[2] = dataSource[2][Int(filteredDataSource[indexPath.row][0])!][Int(filteredDataSource[indexPath.row][1])!]
        }else{
            dataSourceToPass[0] = dataSource[1][indexPath.section][indexPath.row]
            dataSourceToPass[2] = dataSource[2][indexPath.section][indexPath.row]
        }
        self.performSegueWithIdentifier("toDepartmentDetailsView", sender: self)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView.indexPathsForVisibleRows![0].row == 0 && tableView.indexPathsForVisibleRows![0].section == 0 && !self.searchController.active){
            UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.informationAddtionalLabel.alpha = 1
            }, completion: nil)
        }else{
            UIView.animateWithDuration(0.3, delay: 0.20, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.informationAddtionalLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 231.0/255, green: 227.0/255, blue: 235.0/255, alpha: 1.0).CGColor
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func viewDidLoad() {
        viewPositionXZeroSetter(infoMaskView)
        if  NSUserDefaults.standardUserDefaults().objectForKey("endpointDatasource") == nil {
            infoViewShowHide()
        }
        setupData()
    }
    
    @IBAction func aboutButtonAction(sender: AnyObject) {
        infoViewShowHide()
    }
    
    @IBAction func infoViewOKButtonAction(sender: AnyObject) {
        infoViewShowHide()
    }
    
    @IBAction func searchButtonAction(sender: AnyObject) {
        setupSearchBar()
        showHideSearchBar()
    }

    @IBAction func refreshButtonAction(sender: AnyObject) {
        setupData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toDepartmentDetailsView") {
            let departmentDetails = (segue.destinationViewController as! DepartmentDetailsViewController)
            departmentDetails.dataSource = dataSourceToPass
        }
    }
    
    private func setupData(){
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
        
        if  (NSUserDefaults.standardUserDefaults().objectForKey("endpointDatasource") != nil && self.tableView.indexPathsForVisibleRows == nil ) {
            self.dataSource = NSUserDefaults.standardUserDefaults().objectForKey("endpointDatasource") as! [AnyObject]
            self.setupDataFromDataSource()
            self.tableView.reloadData({
                UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.tableView.alpha = 1
                    }, completion: nil)
            })
        }
        
        if self.tableView.indexPathsForVisibleRows != nil {
            self.activityIndicatorViewAdd.stopAnimation()
        }
        
        if Reachability.isConnectedToNetwork() == true {
            EndpointDataManager.sharedInstance.getEndpointData { state in
                if state == "good" {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("endpointDatasource")
                    NSUserDefaults.standardUserDefaults().setObject([EndpointDataManager.sharedInstance.departmentsSectionsNames, EndpointDataManager.sharedInstance.departmentsQueueEndpoints, EndpointDataManager.sharedInstance.departmentsReservationEndpoints ], forKey: "endpointDatasource")
                    self.dataSource = NSUserDefaults.standardUserDefaults().objectForKey("endpointDatasource") as! [AnyObject]
                    self.tableView.reloadData({
                        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.activityIndicatorView.stopAnimation()
                            self.activityIndicatorViewAdd.stopAnimation()
                            self.refreshButton.alpha = 1
                            self.tableView.alpha = 1
                            }, completion: nil)
                    }) }else{
                    self.setupDataFromDataSource()
                    self.activityIndicatorView.stopAnimation()
                    self.activityIndicatorViewAdd.stopAnimation()
                    self.refreshButton.alpha = 1
                    GeneralManager.sharedInstance.alertShow("Nie można było zaktualizować listy dostępnych placówek")
                }
            } } else {
            self.setupDataFromDataSource()
            self.activityIndicatorView.stopAnimation()
            self.activityIndicatorViewAdd.stopAnimation()
            self.refreshButton.alpha = 1
            GeneralManager.sharedInstance.alertShow("Brak połączenia z internetem")
        }
    }
    
    private func setupDataFromDataSource(){
        EndpointDataManager.sharedInstance.departmentsSectionsNames = dataSource[0] as! [String]
        EndpointDataManager.sharedInstance.departmentsQueueEndpoints = dataSource[1] as! [[[String]]]
        EndpointDataManager.sharedInstance.departmentsReservationEndpoints = dataSource[2] as! [[[[String]]]]
    }
    
    private func setupSearchBar(){
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.layer.borderWidth = 1
            controller.searchBar.layer.borderColor = UIColor(red: 63.0/255, green: 48.0/255, blue: 143.0/255, alpha: 1.0).CGColor
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Szukaj"
            controller.searchBar.setValue("Anuluj", forKey:"_cancelButtonText")
            UIBarButtonItem.appearance().setTitleTextAttributes(([NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: UIControlState.Normal) //Not exactly what should it be - changes appearance to all UIBarButtonItem buttons.
            controller.searchBar.barTintColor = UIColor ( red: 0.3157, green: 0.2023, blue: 0.6376, alpha: 1.0 )
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
                    if self.tableView.indexPathsForVisibleRows != nil {
                        self.tableView.setContentOffset(CGPoint(x:0,y:-64), animated:false)
                    }
                }
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredDataSource.removeAll(keepCapacity: false)
        for x in 0...(dataSource[1] as! [[[String]]]).count-1{
            for y in 0...(dataSource[1] as! [[[String]]])[x].count-1{
                if (dataSource[1] as! [[[String]]])[x][y][0].lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) {
                    filteredDataSource.append(["\(x)", "\(y)"])
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        showHideSearchBar()
    }
    
    
    func infoViewShowHide(){
        if infoMaskView.alpha == 0 {
            infoMaskView.alpha = 1
            infoMaskView.animation = "fadeIn"
            infoMaskView.animate()
            infoView.animation = "fadeIn"
            infoView.animate()
        }else{
            infoMaskView.animation = "fadeOut"
            infoMaskView.animate()
            infoView.animation = "fadeOut"
            infoView.animate()
            infoMaskView.alpha = 0
        }
    }
    
    private func viewPositionXZeroSetter(view:UIView){
        //let viewxPosition = view.frame.origin.x
        let viewyPosition = view.frame.origin.y
        let viewHeight = view.frame.size.height
        let viewWidth = view.frame.size.width
        view.frame = CGRectMake(0, viewyPosition, viewWidth, viewHeight)
    }
    
}