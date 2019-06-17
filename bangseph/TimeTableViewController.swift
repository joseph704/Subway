//
//  TimeTableViewController.swift
//  bangseph
//
//  Created by 차요셉 on 03/06/2019.
//  Copyright © 2019 차요셉. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
class TimeTableViewController: UIViewController, XMLParserDelegate {
    var url : String?
    var parser = XMLParser()
    
    var dposts = NSMutableArray()
    
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var yadmNm = NSMutableString()
    var addr = NSMutableString()
    
    var XPos = NSMutableString()
    var YPos = NSMutableString()
    
    var hospitalname = ""
    var hospitalname_utf8 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       beginParsing()
    print(dposts)
}
    
    
    func beginParsing()
    {
        dposts = []
        parser = XMLParser(contentsOf: (URL(string:url!))!)!
        parser.delegate = self
        parser.parse()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "realtimeStationArrival")
        {
            elements = NSMutableDictionary()
            elements = [:]
            yadmNm = NSMutableString()
            yadmNm = ""
            addr = NSMutableString()
            addr = ""
            
            XPos = NSMutableString()
            XPos = ""
            YPos = NSMutableString()
            YPos = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        // 각각에 맞게 넣음
        if element.isEqual(to: "statnNm"){
            yadmNm.append(string)
        } else if element.isEqual(to: "updnLine"){
            addr.append(string)
        }
            
        else if element.isEqual(to: "bstatnNm"){
            XPos.append(string)
        } else if element.isEqual(to: "trainLineNm"){
            YPos.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if(elementName as NSString).isEqual(to: "row"){
            if !yadmNm.isEqual(nil){
                elements.setObject(yadmNm, forKey: "statnNm" as NSCopying)
            }
            if !addr.isEqual(nil){
                elements.setObject(addr, forKey: "updnLine" as NSCopying)
            }
            
            if !XPos.isEqual(nil){
                elements.setObject(XPos, forKey: "bstatnNm" as NSCopying)
            }
            if !YPos.isEqual(nil){
                elements.setObject(YPos, forKey: "trainLineNm" as NSCopying)
            }
            
            dposts.add(elements)
        }
    }
    
}
