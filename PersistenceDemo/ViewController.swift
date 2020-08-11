//
//  ViewController.swift
//  PersistenceDemo
//
//  Created by Rudra Misra on 8/4/20.
//  Copyright © 2020 Rudra Misra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    var tableRec = [String: Int]()
    var keyList:[String] {
        get{
            return Array(tableRec.keys)
        }
    }
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    
    @IBAction func addRecord(_ sender: UIButton) {
        if nameText.text != "" && ageText.text != ""{
            tableRec.updateValue(Int(ageText.text!)!, forKey: nameText.text!)
            UserDefaults.standard.set(tableRec, forKey: "tableRec")
            addToPlist(name: nameText.text!, age: Int(ageText.text!)!)
        }
        nameText.text = ""
        ageText.text = ""
        
        userTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableRec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let key = keyList[indexPath.row]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = String(describing: tableRec[key]!) // Convert Int to String
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // For Table View
        userTableView.dataSource = self
        
        if  UserDefaults.standard.object(forKey: "tableRec") != nil{
            tableRec = UserDefaults.standard.object(forKey: "tableRec") as! [String:Int]
        }
        
        // For File opearation
        let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        plistPath = path?.appendingPathComponent("user_rec").appendingPathExtension("plist")
        readPlist()
    }
    
    let fileManager = FileManager.default
    var plistPath:URL?
    var rec = [String:Int]()
    
    func addToPlist(name:String, age:Int){
        do{
            let newRec = Record(name: name, age: age)
            let plistEncoder = PropertyListEncoder()
            let encodedRec = try plistEncoder.encode(newRec)
            try encodedRec.write(to: plistPath!, options: .noFileProtection)
        }
        catch{
            print(error.localizedDescription)
        }
        readPlist()
    }
    
    func readPlist() {
        if let p = plistPath?.path{
            if fileManager.fileExists(atPath: p){
                let plistDecoder = PropertyListDecoder()
                do{
                    let data = try Data(contentsOf: plistPath!)
                    let record = try plistDecoder.decode(Record.self, from: data)
                    rec.updateValue(record.age, forKey: record.name)
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        print(rec)
    }
    
}

struct Record: Codable {
    let name: String
    let age: Int
}
