//
//  TableViewController.swift
//  TableTest
//
//  Created by John Nastos on 3/9/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

import UIKit

let tableData : [[PrefItem<Any,Any>]] = [
    [
        PrefItem(key:"testKey1",displayName:"Bool",  prefType:PrefTypes.boolPref,defaultValue: false),
        PrefItem(key:"testKey2",displayName:"Float",prefType:PrefTypes.floatPref,defaultValue: 0 as Float),
        PrefItem(key:"testKey3",displayName:"Int",prefType:PrefTypes.intPref,defaultValue: 0 as Int),
        PrefItem(key:"testKey4",displayName:"Test 4",prefType:PrefTypes.boolPref,defaultValue: false),
        PrefItem(key:"testKey5",displayName:"Test 5",prefType:PrefTypes.boolPref,defaultValue: false)]
]

struct PrefItem<T,U> {
    let key : String
    let displayName : String
    let prefType : PrefTypes

    let description : String?
    
    let defaultValue : T
    let displayValues : [U]?
    let actualValues : [T]?
    
    init(key: String, displayName: String, prefType: PrefTypes, defaultValue : T) {
        self.key = key
        self.displayName = displayName
        self.prefType = prefType
        self.defaultValue = defaultValue
        
        description = nil
        displayValues = nil
        actualValues = nil
    }
}

enum PrefTypes : String {
    case boolPref
    case floatPref
    case intPref
}

class JNPrefCell : UITableViewCell {
    var prefItem : PrefItem<Any, Any>!
}

class JNStepperCell : JNPrefCell {
    var stepper : UIStepper!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        stepper = UIStepper(frame: CGRect.zero)
        stepper.sizeToFit()
        self.accessoryView = stepper
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class JNSwitchCell : JNPrefCell {
    
    var optionSwitch : UISwitch!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        optionSwitch = UISwitch()
        self.accessoryView = optionSwitch
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class JNSliderCell : JNPrefCell {
    
}

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(JNStepperCell.self, forCellReuseIdentifier: PrefTypes.intPref.rawValue)
        self.tableView.register(JNSliderCell.self, forCellReuseIdentifier: PrefTypes.floatPref.rawValue)
        self.tableView.register(JNSwitchCell.self, forCellReuseIdentifier: PrefTypes.boolPref.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataItem = tableData[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: dataItem.prefType.rawValue, for: indexPath) as! JNPrefCell

        cell.prefItem = dataItem
        
        cell.textLabel?.text = dataItem.displayName
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
