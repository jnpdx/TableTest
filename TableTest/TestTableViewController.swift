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
            var prefItem = PrefItem(key:"testKey3",displayName:"Int 1-6",prefType:PrefTypes.intPref,defaultValue: 1 as Int)
            prefItem.actualValues = [1,6]
            tableData[0].items.append(prefItem)
        }
        
        do {
            let prefItem = PrefItem(key:"testKey4",displayName:"Bool",prefType:PrefTypes.boolPref,defaultValue: true)
            tableData[0].items.append(prefItem)
        }
        
        do {
            var prefItem = PrefItem(key:"testKey5",displayName:"Int 1-7",prefType:PrefTypes.intPref,defaultValue: 2 as Int)
            prefItem.actualValues = [1,7]
            tableData[0].items.append(prefItem)
        }
        
        do {
            var prefItem = PrefItem(key:"testKey6",displayName:"Float 0-2",prefType:PrefTypes.floatPref,defaultValue: 2 as Float)
            prefItem.actualValues = [0.0 as Float,2.0 as Float]
            tableData[0].items.append(prefItem)
        }
        
        do {
            var prefItem = PrefItem(key:"testKey7",displayName:"Radio 2",prefType:PrefTypes.radioPref,defaultValue: 2)
            prefItem.actualValues = [0,1,2,3,4]
            prefItem.displayValues = ["Zero","One","Two","Three","Four"]
            tableData[0].items.append(prefItem)
        }
        
        tableData.append(PrefItemSection(title: "Fake", items:
            [
                PrefItem(key:"testKey1",displayName:"Bool",     prefType:PrefTypes.boolPref,defaultValue: false),
                PrefItem(key:"testKey2",displayName:"Float",    prefType:PrefTypes.floatPref,defaultValue: 0 as Float),
                PrefItem(key:"testKey3",displayName:"Int",      prefType:PrefTypes.intPref,defaultValue: 0 as Int),
                PrefItem(key:"testKey4",displayName:"Test 4",   prefType:PrefTypes.boolPref,defaultValue: true),
                PrefItem(key:"testKey5",displayName:"Test 5",   prefType:PrefTypes.boolPref,defaultValue: false),
                ])
        )
    }
}
