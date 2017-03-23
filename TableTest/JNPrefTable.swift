//
//  TableViewController.swift
//  TableTest
//
//  Created by John Nastos on 3/9/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0


public enum PrefResult {
    case noValue
}

public struct PrefItem {
    public let key : String
    let displayName : String
    let prefType : PrefTypes

    public let description : String?
    
    private let currentValue : Any?
    
    private let defaultValue : Any
    
    var value : Any {
        guard let currentValue = currentValue,
            currentValue as? PrefResult != PrefResult.noValue
        else {
            return defaultValue
        }
        return currentValue
    }
    
    public var displayValues : [Any]?
    public var actualValues : [Any]?
    
    public init(key: String, displayName: String, description: String?,prefType: PrefTypes, currentValue : Any?, defaultValue: Any, displayValues: [Any]? = nil, actualValues: [Any]? = nil) {
        self.key = key
        self.displayName = displayName
        self.prefType = prefType
        
        self.currentValue = currentValue
        self.defaultValue = defaultValue
        
        self.description = description
        self.displayValues = displayValues
        self.actualValues = actualValues
    }
}

public enum PrefTypes : String {
    case boolPref
    case floatPref
    case intPref
    case radioPref
}

public protocol JNPrefCellDelegate {
    func prefCellValueChanged(value : Any, withPrefItem prefItem : PrefItem)
}

class JNPrefCell : UITableViewCell {
    var delegate : JNPrefCellDelegate?
    
    var mainLabel = UILabel()
    var descriptionLabel = UILabel()
    
    var mainContent = UIView()
    
    class func registerClasses(onTableView tableView: UITableView) {
        tableView.register(JNStepperCell.self, forCellReuseIdentifier: PrefTypes.intPref.rawValue)
        tableView.register(JNSliderCell.self, forCellReuseIdentifier: PrefTypes.floatPref.rawValue)
        tableView.register(JNSwitchCell.self, forCellReuseIdentifier: PrefTypes.boolPref.rawValue)
        tableView.register(JNPickerCell.self, forCellReuseIdentifier: PrefTypes.radioPref.rawValue)
    }
    
    var prefItem : PrefItem! {
        didSet {
            self.setupCell()
            
            self.mainLabel.text = prefItem.displayName
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = JNPrefCell.defaultTextFont
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        
        self.addMainView()
        self.addBasicLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("Not implemented")
    }
    
    func addMainView() {
        self.addSubview(mainContent)
        mainContent.translatesAutoresizingMaskIntoConstraints = false
        
        let views : [String:UIView] = ["mainContent":mainContent]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        
        
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[mainContent]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += verticalConstraints
        
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[mainContent]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += horizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func addBasicLabels() {
        mainLabel.text = "Main"
        descriptionLabel.text = "Description"
        
        mainLabel.font = JNPrefCell.defaultTextFont
        descriptionLabel.font = JNPrefCell.descriptionTextFont
        descriptionLabel.textColor = UIColor.darkGray
        
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(mainLabel)
        mainContent.addSubview(descriptionLabel)
        
        
        
        let views : [String:UIView] = ["mainLabel":mainLabel,"descriptionLabel":descriptionLabel]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        
        do {
            let verticalCenteringConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            allConstraints += [verticalCenteringConstraint]
        }
        
        let labelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[mainLabel]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += labelVerticalConstraints
        
        let labelHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-padding-[mainLabel]",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += labelHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func getValueAndUpdate(_ sender : Any) -> Any {
        assertionFailure("Implement in subclass")
        return 0
    }
    
    func defaultAction(sender : Any) {
        let newValue = self.getValueAndUpdate(sender)
        print("\(prefItem.key) \"\(prefItem.displayName)\" new value: \(newValue)")
        delegate?.prefCellValueChanged(value: newValue, withPrefItem: prefItem)
    }
    
    func setupCell() {
        assertionFailure("Must be implemented by subclass")
    }
    
    func didSelectCell() {
        //do nothing, but it could be subclassed
    }
}

extension JNPrefCell {
    static var defaultTextFont : UIFont { return UIFont(name: "AvenirNext-Regular", size: 16)! }
    static var descriptionTextFont : UIFont { return UIFont(name: "AvenirNext-Regular", size: 12)! }
}

class JNStepperCell : JNPrefCell {
    var stepper = UIStepper()
    var valueLabel = UILabel()
    
    override func getValueAndUpdate(_ sender: Any) -> Any {
//        if let displayValues = self.prefItem.displayValues {
//            //find the right index of it
//            //TODO: use displayValues
//            valueLabel.text = "\(Int(stepper.value))"
//            //valueLabel.text = "\(displayValues[prefItem.value as! Int])"
//        } else {
//            valueLabel.text = "\(Int(stepper.value))"
//        }
        valueLabel.text = "\(Int(stepper.value))"
        return Int(stepper.value)
    }
    
    override func setupCell() {
        self.valueLabel.font = JNPrefCell.defaultTextFont
        if let minValue = prefItem.actualValues?.first as? Int,
            let maxValue = prefItem.actualValues?.last as? Int {
            stepper.minimumValue = Double(minValue)
            stepper.maximumValue = Double(maxValue)
        }
        
        stepper.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .valueChanged)
        stepper.value = Double(prefItem.value as! Int)
        
        stepper.sizeToFit()
        valueLabel.text = "\(prefItem.value)"
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
    
    override func getValueAndUpdate(_ sender: Any) -> Any {
        return optionSwitch.isOn
    }
    
    override func setupCell() {
        optionSwitch.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .valueChanged)
        optionSwitch.isOn = self.prefItem.value as! Bool
        
        
        self.addSubview(optionSwitch)
        optionSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let views : [String:UIView] = ["optionSwitch":optionSwitch]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        
        let sliderVerticalCenteringConstraint = NSLayoutConstraint(item: optionSwitch, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        allConstraints += [sliderVerticalCenteringConstraint]
        
        
        let sliderHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[optionSwitch]-padding-|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += sliderHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)

    }
    
}

class JNSliderCell : JNPrefCell {
    var slider = UISlider()
    var valueLabel = UILabel()
    
    override func getValueAndUpdate(_ sender: Any) -> Any {
        self.valueLabel.text = "\(slider.value)"
        return slider.value
    }
    
    override func setupCell() {
        self.valueLabel.font = JNPrefCell.defaultTextFont
        
        if let minValue = prefItem.actualValues?.first as? Float,
            let maxValue = prefItem.actualValues?.last as? Float {
            slider.minimumValue = minValue
            slider.maximumValue = maxValue
        }
        
        slider.value = self.prefItem.value as! Float
        
        slider.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .touchUpOutside)
        
        valueLabel.text = "\(prefItem.value)"
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
    var curIndex = 0
    
    func indexOfValue(_ value : Int) -> Int {
        if let ints = prefItem.actualValues as? [Int] {
            return ints.index(of: value) ?? 0
        } else {
            return 0
        }
    }
    
    func getDisplayValue(_ value: Int) -> String {
        return "\(prefItem.displayValues![self.indexOfValue(value)])"
    }
    
    override func setupCell() {
        curIndex = self.indexOfValue(prefItem.value as! Int)
        
        self.valueLabel.font = JNPrefCell.defaultTextFont
        
        
        valueLabel.text = self.getDisplayValue(prefItem.value as! Int)
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
    
    override func getValueAndUpdate(_ value: Any) -> Any {
        self.valueLabel.text = self.getDisplayValue(value as! Int)
        return value
    }
    
    override func didSelectCell() {
        
        ActionSheetStringPicker.show(withTitle: prefItem.displayName, rows: prefItem.displayValues!, initialSelection: curIndex, doneBlock: { [unowned self] (picker, index, value) in
            
            let items : [Any] = {
                if let actualValues = self.prefItem.actualValues {
                    return actualValues
                }
                return self.prefItem.displayValues!
            }()
            
            guard index < items.count else {
                assertionFailure("No item corresponds to index")
                return
            }
            
        
            
            let value = items[index]
            self.defaultAction(sender: value)

            self.curIndex = index
            
        }, cancel: { (picker) in
            
        }, origin: self)
    }
}

public struct PrefItemSection {
    public let title : String
    public var items : [PrefItem]
    public var customDelegate : JNPrefCellDelegate?
    
    public init(title : String, items: [PrefItem], delegate: JNPrefCellDelegate? = nil) {
        self.title = title
        self.items = items
        if delegate != nil {
            customDelegate = delegate
        }
    }
}

open class JNPrefTableViewController: UITableViewController, JNPrefCellDelegate {

    //TODO: replace with JNPrefTableInterface
    
    public var tableData = [PrefItemSection]()
    
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        JNPrefCell.registerClasses(onTableView: self.tableView)
    }


    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData[section].items.count
    }

    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].title
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = tableData[indexPath.section]
        
        let dataItem = section.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: dataItem.prefType.rawValue, for: indexPath) as! JNPrefCell

        if let customDelegate = section.customDelegate {
            cell.delegate = customDelegate
        } else {
            cell.delegate = self
        }
        
        cell.prefItem = dataItem
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! JNPrefCell
        cell.didSelectCell()
    }
 
    open func prefCellValueChanged(value: Any, withPrefItem prefItem: PrefItem) {
        print("Delegate method called for \(prefItem.displayName) = \(value)")
    }
}

open class JNPrefTableInterface : NSObject, UITableViewDataSource, UITableViewDelegate, JNPrefCellDelegate {

    open var tableData = [PrefItemSection]()
    weak var tableView : UITableView!
    
    public init(withTableView tableView: UITableView) {
        super.init()
        self.tableView = tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        JNPrefCell.registerClasses(onTableView: self.tableView)
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].items.count
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].title
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataItem = tableData[indexPath.section].items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: dataItem.prefType.rawValue, for: indexPath) as! JNPrefCell
        
        cell.delegate = self
        
        cell.prefItem = dataItem
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! JNPrefCell
        cell.didSelectCell()
    }
    
    open func prefCellValueChanged(value: Any, withPrefItem prefItem: PrefItem) {
        print("Delegate method called for \(prefItem.displayName) = \(value)")
    }
    
}

