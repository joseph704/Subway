//
//  UpTimeTabelViewController.swift
//  bangseph
//
//  Created by 차요셉 on 17/06/2019.
//  Copyright © 2019 차요셉. All rights reserved.
//

import UIKit

class UpTimeTabelViewController: UITableViewController, XMLParserDelegate {
    @IBOutlet var tbData: UITableView!
    var url : String?
    
    var parser = XMLParser()
    
    var posts = NSMutableArray()
    
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
   
    }

    func beginParsing()
    {
        posts = []
        parser = XMLParser(contentsOf: (URL(string:url!))!)!
        parser.delegate = self
        parser.parse()
        tbData!.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "row")
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
        if element.isEqual(to: "SUBWAYENAME"){
            
            yadmNm.append("\(string)행")
        } else if element.isEqual(to: "ARRIVETIME"){
            addr.append(string)
        }
            
        else if element.isEqual(to: "XPos"){
            XPos.append(string)
        } else if element.isEqual(to: "YPos"){
            YPos.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if(elementName as NSString).isEqual(to: "row"){
            if !yadmNm.isEqual(nil){
                elements.setObject(yadmNm, forKey: "SUBWAYENAME" as NSCopying)
            }
            if !addr.isEqual(nil){
                elements.setObject(addr, forKey: "ARRIVETIME" as NSCopying)
            }
            
            if !XPos.isEqual(nil){
                elements.setObject(XPos, forKey: "XPos" as NSCopying)
            }
            if !YPos.isEqual(nil){
                elements.setObject(YPos, forKey: "YPos" as NSCopying)
            }
            
            posts.add(elements)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "uptime", for: indexPath)
        
        cell.textLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "ARRIVETIME") as! NSString as String
        cell.detailTextLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "SUBWAYENAME") as! NSString as String
        return cell
    }
}
