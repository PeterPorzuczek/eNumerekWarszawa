//
//  EndpointDataManager.swift
//  eNumerek
//
//  Created by Piotr on 06.05.2016.
//  Copyright © 2016 Piotr. All rights reserved.
//

import Foundation
import SWXMLHash

class EndpointDataManager:NSObject {
    
    static let sharedInstance = EndpointDataManager()
    
    private let address = "https://rezerwacje.um.warszawa.pl"
    
    var departmentsSectionsNames:[String] = []
    var departmentsQueueEndpoints:[[[String]]] = []
    var departmentsReservationEndpoints:[[[[String]]]] = []
    
    func getEndpointData(completion: (state:String) -> ()) {
        departmentsSectionsNames.removeAll(keepCapacity: false)
        departmentsQueueEndpoints.removeAll(keepCapacity: false)
        departmentsReservationEndpoints.removeAll(keepCapacity: false)
        HtmlManager.sharedInstance.httpGet(address, encoding: NSUTF8StringEncoding) { (result) in
            if(result != "error" && result != ""){
                let departmentsSectionsHtml = result.stringByReplacingOccurrencesOfString("\t\t", withString: "").stringByReplacingOccurrencesOfString("\t", withString: "").stringByReplacingOccurrencesOfString("      ", withString: "").stringByReplacingOccurrencesOfString("       ", withString: "").stringByReplacingOccurrencesOfString("       ", withString: "").stringByReplacingOccurrencesOfString("    ", withString: "").stringByReplacingOccurrencesOfString("  ", withString: "").componentsSeparatedByString("<div class=\"Accordion ShadowBoxContent\">")
                //print(departmentsSectionsHtml.count)
                for departmentSection in 2...departmentsSectionsHtml.count-1{
                    if(departmentsSectionsHtml[departmentSection].containsString("<h2 class=\"")){
                        self.departmentsSectionsNames.append(GeneralManager.sharedInstance.matchesForRegexInTextToArray("<h2 class=\"MostPoniatowskiego\"><span>(.*?)</span></h2>", text: departmentsSectionsHtml[departmentSection])[0])
                    }
                    self.departmentsQueueEndpoints.append([])
                    self.departmentsReservationEndpoints.append([])
                    let departmentsHtml = departmentsSectionsHtml[departmentSection].componentsSeparatedByString("<div class=\"jednostka\" id=\"")
                    for departmentHtml in 1...departmentsHtml.count-1{
                        let departmentsHtmlArray = departmentsHtml[departmentHtml].componentsSeparatedByString("\r\n")
                        self.departmentsQueueEndpoints[departmentSection-2].append([])
                        self.departmentsReservationEndpoints[departmentSection-2].append([])
                        self.departmentsQueueEndpoints[departmentSection-2][departmentHtml-1].append(String(htmlEncodedString: departmentsHtmlArray[1]))
                        var reservationIterator = 0
                        for i in 0...departmentsHtmlArray.count-1{
                            if(departmentsHtmlArray[i].containsString("<button class =\"refresh\" name=\"")){
                                self.departmentsQueueEndpoints[departmentSection-2][departmentHtml-1].append(GeneralManager.sharedInstance.matchesForRegexInTextToArray("<button class =\"refresh\" name=\"(.*?)\">Odśwież", text: departmentsHtmlArray[i])[0].stringByReplacingOccurrencesOfString("_+_", withString: "?id="))
                            }
                            if departmentsHtmlArray[i].containsString("toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,copyhistory=no,width=1000,height=660"){
                                self.departmentsReservationEndpoints[departmentSection-2][departmentHtml-1].append([])
                                self.departmentsReservationEndpoints[departmentSection-2][departmentHtml-1][reservationIterator].append(departmentsHtmlArray[i].componentsSeparatedByString("\', \'\', \'")[0].stringByReplacingOccurrencesOfString("<td style=\"cursor: pointer;\" onclick=\"window.open(\'", withString: ""))
                                self.departmentsReservationEndpoints[departmentSection-2][departmentHtml-1][reservationIterator].append(departmentsHtmlArray[i].componentsSeparatedByString(">")[1].stringByReplacingOccurrencesOfString("</td", withString: ""))
                                reservationIterator += 1
                            }
                        }
                    }
                }
                completion(state: "good")
            }else{
                completion(state: "bad")
            }
        }
    }
    
    func getQueueData(endpoint:String, completion: (queueData: [[String]], state:String) -> ()){
        var queueDataResult:[[String]] = []
        HtmlManager.sharedInstance.httpGet(endpoint, encoding: NSUTF8StringEncoding) { (result) in
            if(result != "error" && result != ""){
                let xml = SWXMLHash.parse(result)
                for root in xml.children {
                    for element in root.children {
                        if !String(element["NAZWAGRUPY"].element?.text).isEmpty {
                            let date = xml["ROOT"].element?.attributes["date"]
                            let time = xml["ROOT"].element?.attributes["time"]
                            let id = element["IDGRUPY"].element?.text
                            let letter = element["LITERAGRUPY"].element?.text
                            let name = element["NAZWAGRUPY"].element?.text
                            let currentNumber = element["AKTUALNYNUMER"].element?.text
                            let peopleInQueue = element["LICZBAKLWKOLEJCE"].element?.text
                            let activeHandlers = element["LICZBACZYNNYCHSTAN"].element?.text
                            let handlingTime = element["CZASOBSLUGI"].element?.text
                            let queueN = [date!, time!, id!, letter!, name!, currentNumber!, peopleInQueue!, activeHandlers!, handlingTime!]
                            queueDataResult.append(queueN)
                        }
                    }
                }
                completion(queueData: queueDataResult, state: "good")
            }else{
                completion(queueData: queueDataResult, state: "bad")
            }
        }
    }
    
}