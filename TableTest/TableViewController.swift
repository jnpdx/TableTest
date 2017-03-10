//
//  TableViewController.swift
//  TableTest
//
//  Created by John Nastos on 3/9/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

struct PrefItem {
    let key : String
    let displayName : String
    let prefType : PrefTypes

    var description : String?
    
    let defaultValue : Any
    var displayValues : [Any]?
    var actualValues : [Any]?
    
    
    var actionBlock : ((_ : Any) -> Void)?
    
    init(key: String, displayName: String, prefType: PrefTypes, defaultValue : Any) {
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
    case radioPref
}

class JNPrefCell : UITableViewCell {
    var prefItem : PrefItem! {
        didSet {
            self.setupCell()
            
            self.textLabel?.text = prefItem.displayName
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = self.defaultTextFont
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("Not implemented")
    }
    
    func setupCell() {
        assertionFailure("Must be implemented by subclass")
    }
    
    func didSelectCell(fromViewController vc : UITableViewController) {
        //do nothing, but it could be subclassed
    }
}

extension JNPrefCell {
    var defaultTextFont : UIFont { return UIFont(name: "AvenirNext-Regular", size: 16)! }
}

class JNStepperCell : JNPrefCell {
    var stepper = UIStepper()
    var valueLabel = UILabel()
    
    func stepperPressed() {
        valueLabel.text = "\(Int(stepper.value))"
        prefItem.actionBlock?(Int(stepper.value))
    }
    
    override func setupCell() {
        self.valueLabel.font = self.defaultTextFont
        if let minValue = prefItem.actualValues?.first as? Int,
            let maxValue = prefItem.actualValues?.last as? Int {
            stepper.minimumValue = Double(minValue)
            stepper.maximumValue = Double(maxValue)
        }
        
        stepper.addTarget(self, action: #selector(self.stepperPressed), for: .valueChanged)
        stepper.value = Double(prefItem.defaultValue as! Int)
        
        stepper.sizeToFit()
        valueLabel.text = "\(prefItem.defaultValue)"
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stepper)
        self.addSubview(valueLabel)
        
        let views : [String:UIView] = ["stepper":stepper,"valueLabel":valueLabel]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        

        let sliderVerticalCenteringConstraint = NSLayoutConstraint(item: stepper, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        allConstraints += [sliderVerticalCenteringConstraint]
        
        let labelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[valueLabel]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += labelVerticalConstraints
        
        let sliderHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[valueLabel]-padding-[stepper]-padding-|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += sliderHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }

}

class JNSwitchCell : JNPrefCell {
    
    var optionSwitch = UISwitch()
    
    func switchChanged() {
        self.prefItem.actionBlock?(optionSwitch.isOn)
    }
    
    override func setupCell() {
        optionSwitch.addTarget(self, action: #selector(self.switchChanged), for: .valueChanged)
        optionSwitch.isOn = self.prefItem.defaultValue as! Bool
        self.accessoryView = optionSwitch
    }
    
}

class JNSliderCell : JNPrefCell {
    var slider = UISlider()
    var valueLabel = UILabel()
    
    func sliderChanged() {
        self.valueLabel.text = "\(slider.value)"
        self.prefItem?.actionBlock?(slider.value)
    }
    
    override func setupCell() {
        self.valueLabel.font = self.defaultTextFont
        
        if let minValue = prefItem.actualValues?.first as? Float,
            let maxValue = prefItem.actualValues?.last as? Float {
            slider.minimumValue = minValue
            slider.maximumValue = maxValue
        }
        
        slider.value = self.prefItem.defaultValue as! Float
        
        slider.addTarget(self, action: #selector(self.sliderChanged), for: .touchUpInside)
        slider.addTarget(self, action: #selector(self.sliderChanged), for: .touchUpOutside)
        
        valueLabel.text = "\(prefItem.defaultValue)"
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(valueLabel)
        
        slider.frame = CGRect.zero
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(slider)
        
        let views : [String:UIView] = ["slider":slider,"valueLabel":valueLabel]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        
        
        let sliderVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[slider]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += sliderVerticalConstraints
        
        let labelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[valueLabel]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += labelVerticalConstraints
        
        let sliderHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[valueLabel]-padding-[slider(100)]-padding-|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += sliderHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
}

class JNPickerCell : JNPrefCell {
    var valueLabel = UILabel()
    
    override func setupCell() {
        self.valueLabel.font = self.defaultTextFont
        
        valueLabel.text = "\(prefItem.displayValues![prefItem.defaultValue as! Int])"
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(valueLabel)
        
        
        let views : [String:UIView] = ["valueLabel":valueLabel]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        
        let labelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[valueLabel]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += labelVerticalConstraints
        
        let sliderHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[valueLabel]-padding-|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += sliderHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    override func didSelectCell(fromViewController vc : UITableViewController) {
        print("Open action picker")
        
        ActionSheetStringPicker.show(withTitle: prefItem.displayName, rows: prefItem.displayValues!, initialSelection: 0, doneBlock: { [unowned self] (picker, index, value) in
            
            if let value = value as? String {
                self.valueLabel.text = value
                self.prefItem.actionBlock?(value)
            }
            
        }, cancel: { (picker) in
            
        }, origin: self)
    }
}

struct PrefItemSection {
    let title : String
    var items : [PrefItem]
}

class JNPrefTableViewController: UITableViewController {

    var tableData = [PrefItemSection]()
    
    func constructTableData() {
        
        tableData.append(PrefItemSection(title: "Real", items: []))
        
        do {
            var prefItem = PrefItem(key:"testKey3",displayName:"Int 1-6",prefType:PrefTypes.intPref,defaultValue: 1 as Int)
            prefItem.actualValues = [1,6]
            prefItem.actionBlock = { (newValue : Any) in
                print("New value: \(newValue)")
            }
            tableData[0].items.append(prefItem)
        }
        
        do {
            var prefItem = PrefItem(key:"testKey4",displayName:"Bool",prefType:PrefTypes.boolPref,defaultValue: true)
            prefItem.actionBlock = { (newValue : Any) in
                print("\(prefItem.key) new value: \(newValue)")
            }
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
            prefItem.actionBlock = { (newValue : Any) in
                print("\(prefItem.key) new value: \(newValue)")
            }
            tableData[0].items.append(prefItem)
        }
        
        do {
            var prefItem = PrefItem(key:"testKey7",displayName:"Radio 2",prefType:PrefTypes.radioPref,defaultValue: 2)
            prefItem.actualValues = [0,1,2,3,4]
            prefItem.displayValues = ["Zero","One","Two","Three","Four"]
            prefItem.actionBlock = { (newValue : Any) in
                print("\(prefItem.key) new value: \(newValue)")
            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.constructTableData()
        //self.tableView.style = UITableViewStyle.grouped

        self.tableView.register(JNStepperCell.self, forCellReuseIdentifier: PrefTypes.intPref.rawValue)
        self.tableView.register(JNSliderCell.self, forCellReuseIdentifier: PrefTypes.floatPref.rawValue)
        self.tableView.register(JNSwitchCell.self, forCellReuseIdentifier: PrefTypes.boolPref.rawValue)
        self.tableView.register(JNPickerCell.self, forCellReuseIdentifier: PrefTypes.radioPref.rawValue)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataItem = tableData[indexPath.section].items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: dataItem.prefType.rawValue, for: indexPath) as! JNPrefCell

        cell.prefItem = dataItem
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! JNPrefCell
        cell.didSelectCell(fromViewController: self)
    }
 
}
