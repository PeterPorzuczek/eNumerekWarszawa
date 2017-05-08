//
//  HelperClasses.swift
//  eNumerek
//
//  Created by Piotr on 06.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import SwiftRegExp

public class HtmlManager:NSObject {
    
    static let sharedInstance = HtmlManager()
    
    let session = NSURLSession.sharedSession()
    
    func httpPost(address:String, encoding: UInt, addressParam: String, completion: (result: String) -> Void) {
        let url_to_request = address
        let url:NSURL = NSURL(string: url_to_request)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        let paramString = addressParam
        request.HTTPBody = paramString.dataUsingEncoding(encoding)
        var result = ""
        let task = session.downloadTaskWithRequest(request){
            (let location, let response, let error) in
            guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                result = "error"
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result: result as String)
                })
                return
            }
            let urlContents = try! NSString(contentsOfURL: location!, encoding: encoding)
            guard let _:NSString = urlContents else {
                result = "error"
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result: result as String)
                })
                return
            }
            result = urlContents as String
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(result: result as String)
            })
        }
        task.resume()
    }
    
    func httpGet(address: String, encoding: UInt, completion: (result: String) -> Void) {
        let url = NSURL(string: address)
        let request = NSMutableURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            guard
                let data = data,
                let dataString = String(data: data, encoding: encoding)
                where error == nil
                else {print(error?.localizedDescription);
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(result: "error" as String)
                    }); return }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(result: dataString as String)
            })
        }
        task.resume()
    }
    
    func httpGet(address: String){
        let url = NSURL(string: address)
        let request = NSMutableURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
}

public class GeneralManager: NSObject {
    
    static let sharedInstance = GeneralManager()
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func matchesForRegexInTextToArray(regex: String!, text: String!) -> [String] {
        var result:[String] = []
        do {
            let regexp = try RegExp(pattern: regex, options: [])
            let matches = regexp.allMatches(text)
            for match in matches {
                if ((match =~ regexp) != nil){
                }else{
                    result.append(match)
                }
            }
        } catch let error as NSError {
            NSLog("invalid regex: \(error.localizedDescription)")
        }
        return result
    }
    
    func alertShow(message: String){
        let alert = UIAlertView()
        alert.title = "Błąd"
        alert.message = message
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

@IBDesignable class RefreshButton: UIButton {

    override func drawRect(rect: CGRect) {
        AdditionalIcons.drawRefreshIcon(frame: rect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

@IBDesignable class BackButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        AdditionalIcons.drawBackIcon(frame: rect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

public class AdditionalIcons : NSObject {
    public class func drawBackIcon(frame frame: CGRect = CGRectMake(0, 0, 256, 256)) {
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let backGroup: CGRect = CGRectMake(frame.minX + floor(frame.width * 0.00039 + 0.4) + 0.1, frame.minY + floor(frame.height * 0.10547 + 0.5), floor(frame.width * 0.46406 - 0.3) - floor(frame.width * 0.00039 + 0.4) + 0.7, floor(frame.height * 0.89453 + 0.5) - floor(frame.height * 0.10547 + 0.5))
        let backLinesPath = UIBezierPath()
        backLinesPath.moveToPoint(CGPointMake(backGroup.minX + 0.83434 * backGroup.width, backGroup.minY + 1.00000 * backGroup.height))
        backLinesPath.addLineToPoint(CGPointMake(backGroup.minX + 0.00000 * backGroup.width, backGroup.minY + 0.50816 * backGroup.height))
        backLinesPath.addLineToPoint(CGPointMake(backGroup.minX + 0.86204 * backGroup.width, backGroup.minY + 0.00000 * backGroup.height))
        backLinesPath.addLineToPoint(CGPointMake(backGroup.minX + 1.00000 * backGroup.width, backGroup.minY + 0.08112 * backGroup.height))
        backLinesPath.addLineToPoint(CGPointMake(backGroup.minX + 0.27558 * backGroup.width, backGroup.minY + 0.50816 * backGroup.height))
        backLinesPath.addLineToPoint(CGPointMake(backGroup.minX + 0.97196 * backGroup.width, backGroup.minY + 0.91867 * backGroup.height))
        backLinesPath.addLineToPoint(CGPointMake(backGroup.minX + 0.83434 * backGroup.width, backGroup.minY + 1.00000 * backGroup.height))
        backLinesPath.closePath()
        backLinesPath.miterLimit = 4
        
        fillColor.setFill()
        backLinesPath.fill()
    }
    
    public class func drawRefreshIcon(frame frame: CGRect = CGRectMake(0, 0, 256, 256)) {
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let refreshGroup: CGRect = CGRectMake(frame.minX + floor(frame.width * 0.00000 + 0.5), frame.minY + floor(frame.height * 0.00000 + 0.5), floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5))
        let refreshLinesPath = UIBezierPath()
        refreshLinesPath.moveToPoint(CGPointMake(refreshGroup.minX + 0.50000 * refreshGroup.width, refreshGroup.minY + 0.21094 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.74089 * refreshGroup.width, refreshGroup.minY + 0.34102 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.59876 * refreshGroup.width, refreshGroup.minY + 0.21094 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.68789 * refreshGroup.width, refreshGroup.minY + 0.26152 * refreshGroup.height))
        refreshLinesPath.addLineToPoint(CGPointMake(refreshGroup.minX + 0.74089 * refreshGroup.width, refreshGroup.minY + 0.23503 * refreshGroup.height))
        refreshLinesPath.addLineToPoint(CGPointMake(refreshGroup.minX + 0.78906 * refreshGroup.width, refreshGroup.minY + 0.23503 * refreshGroup.height))
        refreshLinesPath.addLineToPoint(CGPointMake(refreshGroup.minX + 0.78906 * refreshGroup.width, refreshGroup.minY + 0.42773 * refreshGroup.height))
        refreshLinesPath.addLineToPoint(CGPointMake(refreshGroup.minX + 0.59635 * refreshGroup.width, refreshGroup.minY + 0.42773 * refreshGroup.height))
        refreshLinesPath.addLineToPoint(CGPointMake(refreshGroup.minX + 0.59635 * refreshGroup.width, refreshGroup.minY + 0.37956 * refreshGroup.height))
        refreshLinesPath.addLineToPoint(CGPointMake(refreshGroup.minX + 0.70716 * refreshGroup.width, refreshGroup.minY + 0.37956 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.50000 * refreshGroup.width, refreshGroup.minY + 0.25911 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.66380 * refreshGroup.width, refreshGroup.minY + 0.30488 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.58672 * refreshGroup.width, refreshGroup.minY + 0.25911 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.25911 * refreshGroup.width, refreshGroup.minY + 0.50000 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.36751 * refreshGroup.width, refreshGroup.minY + 0.25911 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.25911 * refreshGroup.width, refreshGroup.minY + 0.36751 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.50000 * refreshGroup.width, refreshGroup.minY + 0.74089 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.25911 * refreshGroup.width, refreshGroup.minY + 0.63249 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.36751 * refreshGroup.width, refreshGroup.minY + 0.74089 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.73607 * refreshGroup.width, refreshGroup.minY + 0.54336 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.61562 * refreshGroup.width, refreshGroup.minY + 0.74089 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.71680 * refreshGroup.width, refreshGroup.minY + 0.65898 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.76497 * refreshGroup.width, refreshGroup.minY + 0.52409 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.73848 * refreshGroup.width, refreshGroup.minY + 0.53132 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.75052 * refreshGroup.width, refreshGroup.minY + 0.52168 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.78424 * refreshGroup.width, refreshGroup.minY + 0.55299 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.77702 * refreshGroup.width, refreshGroup.minY + 0.52650 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.78665 * refreshGroup.width, refreshGroup.minY + 0.53854 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.50000 * refreshGroup.width, refreshGroup.minY + 0.78906 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.76016 * refreshGroup.width, refreshGroup.minY + 0.69030 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.63971 * refreshGroup.width, refreshGroup.minY + 0.78906 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.21094 * refreshGroup.width, refreshGroup.minY + 0.50000 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.34102 * refreshGroup.width, refreshGroup.minY + 0.78906 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.21094 * refreshGroup.width, refreshGroup.minY + 0.65898 * refreshGroup.height))
        refreshLinesPath.addCurveToPoint(CGPointMake(refreshGroup.minX + 0.50000 * refreshGroup.width, refreshGroup.minY + 0.21094 * refreshGroup.height), controlPoint1: CGPointMake(refreshGroup.minX + 0.21094 * refreshGroup.width, refreshGroup.minY + 0.34102 * refreshGroup.height), controlPoint2: CGPointMake(refreshGroup.minX + 0.34102 * refreshGroup.width, refreshGroup.minY + 0.21094 * refreshGroup.height))
        refreshLinesPath.closePath()
        refreshLinesPath.miterLimit = 4

        fillColor.setFill()
        refreshLinesPath.fill()
    }
    
}

