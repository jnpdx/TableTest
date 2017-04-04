//
//  TestTableViewController.swift
//  TableTest
//
//  Created by John Nastos on 3/10/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

import Foundation
import JNPrefTable


class TestTableViewController : JNPrefTableViewController {
    override func viewDidLoad() {
        self.constructTableData()
        
        super.viewDidLoad()
    }
    
    func constructTableData() {
        
        tableData.append(PrefItemSection(title: "Real", items: []))
        
        do {
            var prefItem = PrefItem(key:"testKey3",displayName:"Int 1-6", description: "test",prefType:PrefTypes.intPref, currentValue: 1,defaultValue: 1 as Int)
            prefItem.actualValues = [1,6]
            tableData[0].items.append(prefItem)
        }
        
        do {
            let prefItem = PrefItem(key:"testKey4",displayName:"Bool", description: "test"
                ,prefType:PrefTypes.boolPref, currentValue: false,defaultValue: true)
            tableData[0].items.append(prefItem)
        }
        
        do {
            var prefItem = PrefItem(key:"testKey5",displayName:"Int 1-7", description: "test",prefType:PrefTypes.intPref, currentValue: 1,defaultValue: 2 as Int)
            prefItem.actualValues = [1,7]
            tableData[0].items.append(prefItem)
        }
    }
}
