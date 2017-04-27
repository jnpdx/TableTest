//
//  TableViewController.swift
//  TableTest
//
//  Created by John Nastos on 3/9/17.
//  Copyright © 2017 John Nastos. All rights reserved.
//

// for Framework

import UIKit
import CoreActionSheetPicker


public struct PrefValue {
    
    let value : PrefValueTypes
    
    static func bool(_ v : Bool) -> PrefValue {
        return PrefValue(value: .bool(value: v))
    }
    
    static func int(_ v : Int) -> PrefValue {
        return PrefValue(value: .int(value: v))
    }
    
    static func intRange(_ v : (Int,Int)) -> PrefValue {
        return PrefValue(value: .intRange(value: v))
    }

    static func float(_ v : Float) -> PrefValue {
        return PrefValue(value: .float(value: v))
    }
    
    static func string(_ v: String) -> PrefValue {
        return PrefValue(value: .string(value: v))
    }
    
    static func intArray(_ a : [Int]) -> [PrefValue] {
        return a.map { (i) -> PrefValue in
            PrefValue.int(i)
        }
    }
    
    static func stringArray(_ a : [String]) -> [PrefValue] {
        return a.map { (i) -> PrefValue in
            PrefValue.string(i)
        }
    }
    
    enum PrefValueTypes {
        case bool(value: Bool)
        case int(value: Int)
        case intRange(value: (Int, Int))
        case float(value: Float)
        case string(value : String)
        case noValue
    }
    
    var isNoValue : Bool {
        switch value {
        case .noValue:
            return true
        default:
            return false
        }
    }
    
    var boolValue : Bool {
        switch value {
        case .bool(let value):
            return value
        default:
            assertionFailure("Wrong type")
            return false
        }
    }
    
    var intValue : Int {
        switch value {
        case .int(let value):
            return value
        default:
            assertionFailure("Wrong type")
            return -1
        }
    }
    
    var intRangeValue : (Int, Int) {
        switch value {
        case .intRange(let value):
            return value
        default:
            assertionFailure("Wrong type")
            return (-1,-1)
        }
    }
    
    var floatValue : Float {
        switch value {
        case .float(let value):
            return value
        default:
            assertionFailure("Wrong type")
            return -1
        }
    }
    
    var stringValue : String {
        switch value {
        case .string(let value):
            return value
        default:
            assertionFailure("Wrong type")
            return ""
        }
    }
    
    var valueForDefaults : Any? {
        switch value {
        case .bool(let value):
            return value
        case .int(let value):
            return value
        case .intRange(let value):
            return [value.0,value.1]
        case .float(let value):
            return value
        case .string(let value):
            return value
        case .noValue:
            return nil
        }
    }
    
    static var noValue : PrefValue {
        return PrefValue(value: .noValue)
    }
    
}

public struct PrefItem {
    public let key : String
    let displayName : String
    let prefType : PrefTypes

    public let description : String?
    
    public let value : PrefValue
    
    public var displayValues : [String]?
    public var actualValues : [PrefValue]?
    
    public init(key: String, displayName: String, description: String?,prefType: PrefTypes, currentValue : PrefValue, displayValues: [String]? = nil, actualValues: [PrefValue]? = nil) {
        self.key = key
        self.displayName = displayName
        self.prefType = prefType
        
        self.value = currentValue
        
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
    case rangePref
    
    case buttonPref
}

public protocol JNPrefCellDelegate {
    func prefCellValueChanged(value : PrefValue, withPrefItem prefItem : PrefItem)
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
        tableView.register(JNRangeSliderCell.self, forCellReuseIdentifier: PrefTypes.rangePref.rawValue)
        tableView.register(JNButtonCell.self, forCellReuseIdentifier: PrefTypes.buttonPref.rawValue)
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
    
    func prefCellHeight() -> CGFloat {
        if prefItem.description != nil {
            return heightWithDescription()
        } else {
            return basicHeight()
        }
    }
    
    internal func basicHeight() -> CGFloat {
        return 60
    }
    
    internal func heightWithDescription() -> CGFloat {
        return 100
    }
    
    override func layoutSubviews() {
        if prefItem.description == nil {
            mainContent.frame = self.bounds
            return
        }
        mainContent.frame = self.bounds

        //mainContent.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height / 2.0)
        //descriptionLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height / 2.0)
    }
    
    func addMainView() {
        self.addSubview(mainContent)
    }
    
    func addBasicLabels() {
        mainLabel.text = "Main"
        descriptionLabel.text = "Description"
        
        mainLabel.font = JNPrefCell.defaultTextFont
        descriptionLabel.font = JNPrefCell.descriptionTextFont
        descriptionLabel.textColor = UIColor.darkGray
        
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(mainLabel)
        
        //descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descriptionLabel)
        
        
        
        let views : [String:UIView] = ["mainLabel":mainLabel]
        
        let metrics : [String:Any] = ["padding":16]
        
        var allConstraints = [NSLayoutConstraint]()
        
        do {
            let verticalCenteringConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            allConstraints += [verticalCenteringConstraint]
        }
        
        let labelHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-padding-[mainLabel]",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += labelHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func getValueAndUpdate(_ sender : Any) -> PrefValue {
        assertionFailure("Implement in subclass")
        return PrefValue.noValue
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
    static var boldTextFont : UIFont { return UIFont(name: "AvenirNext-Medium", size: 16)! }
    static var descriptionTextFont : UIFont { return UIFont(name: "AvenirNext-Regular", size: 12)! }
}

class JNButtonCell : JNPrefCell {
    var button = UIButton(type: .system)
    
    override func setupCell() {
        self.mainLabel.isHidden = true
        button.setTitle(self.prefItem.displayName, for: .normal)
        button.titleLabel?.font = JNPrefCell.defaultTextFont
        self.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16.0).isActive = true
        button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16.0).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
    }
    
    func buttonPressed(sender : UIButton) {
        self.defaultAction(sender: self)
    }
    
    override func getValueAndUpdate(_ sender: Any) -> PrefValue {
        //don't need to do anything here
        return PrefValue.noValue
    }
}

class JNStepperCell : JNPrefCell {
    var stepper = UIStepper()
    var valueLabel = UILabel()
    
    override func getValueAndUpdate(_ sender: Any) -> PrefValue {
        valueLabel.text = valueLabelText(n: Int(stepper.value))
        return PrefValue.int(Int(stepper.value))
    }
    
    func valueLabelText(n : Int) -> String {
        
        if let actualValues = prefItem.actualValues, let displayValues = prefItem.displayValues, let index = actualValues.index(where: { (prefVal) -> Bool in
            return prefVal.intValue == n
        }) {
            return displayValues[index]
        }
        
        return "\(n)"
    }
    
    override func setupCell() {
        self.valueLabel.font = JNPrefCell.boldTextFont
        if let minValue = prefItem.actualValues?.first?.intValue,
            let maxValue = prefItem.actualValues?.last?.intValue {
            stepper.minimumValue = Double(minValue)
            stepper.maximumValue = Double(maxValue)
        }
        
        stepper.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .valueChanged)
        stepper.value = Double(prefItem.value.intValue)
        
        stepper.sizeToFit()
        valueLabel.text = valueLabelText(n: prefItem.value.intValue)
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(stepper)
        mainContent.addSubview(valueLabel)
        
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
    
    override func getValueAndUpdate(_ sender: Any) -> PrefValue {
        return PrefValue.bool(optionSwitch.isOn)
    }
    
    override func setupCell() {
        optionSwitch.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .valueChanged)
        optionSwitch.isOn = self.prefItem.value.boolValue
        
        
        mainContent.addSubview(optionSwitch)
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
    
    override func getValueAndUpdate(_ sender: Any) -> PrefValue {
        self.valueLabel.text = "\(slider.value)"
        return PrefValue.float(slider.value)
    }
    
    override func setupCell() {
        self.valueLabel.font = JNPrefCell.boldTextFont
        
        if let minValue = prefItem.actualValues?.first?.floatValue,
            let maxValue = prefItem.actualValues?.last?.floatValue {
            slider.minimumValue = minValue
            slider.maximumValue = maxValue
        }
        
        slider.value = self.prefItem.value.floatValue
        
        slider.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(self.defaultAction(sender:)), for: .touchUpOutside)
        
        valueLabel.text = "\(prefItem.value)"
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(valueLabel)
        
        slider.frame = CGRect.zero
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(slider)
        
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

class JNRangeSliderCell : JNPrefCell {
    var valueLabel = UILabel()
    var slider = TTRangeSlider()
    
    struct UpdatePayload {
        let minVal : Int
        let maxVal : Int
    }
    
    override func getValueAndUpdate(_ sender: Any) -> PrefValue {
        guard let payload = sender as? UpdatePayload else {
            assertionFailure("Wrong type")
            return PrefValue.noValue
        }
        
        //get the corresponding display values
        guard let indexOfMin = prefItem.actualValues?.index(where: { (prefValue) -> Bool in
            return prefValue.intValue == payload.minVal
        }) else {
            return PrefValue.noValue
        }
        
        guard let indexOfMax = prefItem.actualValues?.index(where: { (prefValue) -> Bool in
            return prefValue.intValue == payload.maxVal
        }) else {
            return PrefValue.noValue
        }
        
        guard let displayMin = prefItem.displayValues?[indexOfMin] else {
            assertionFailure("No display value")
            return PrefValue.noValue
        }
        
        guard let displayMax = prefItem.displayValues?[indexOfMax] else {
            assertionFailure("No display value")
            return PrefValue.noValue
        }
        
        self.valueLabel.text = "\(displayMin) - \(displayMax)"
        return PrefValue.intRange((payload.minVal,payload.maxVal)) //TODO: send both values
    }
    
    override func setupCell() {
        let min = prefItem.value.intRangeValue.0
        let max = prefItem.value.intRangeValue.1
        
        slider.minValue = Float(prefItem.actualValues!.first!.intValue)
        slider.maxValue = Float(prefItem.actualValues!.last!.intValue)
        
        slider.selectedMinimum = Float(min)
        slider.selectedMaximum = Float(max)
        
        _ = self.getValueAndUpdate(UpdatePayload(minVal: min, maxVal: max))
        
        slider.hideLabels = true
        //slider.selectedHandleDiameterMultiplier = 1.0
        slider.delegate = self
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        mainContent.addSubview(slider)
        
        self.valueLabel.font = JNPrefCell.boldTextFont
        
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(valueLabel)
        
        let views : [String:UIView] = ["valueLabel":valueLabel,"slider":slider]
        
        let metrics : [String:Any] = ["padding":6]
        
        var allConstraints = [NSLayoutConstraint]()
        
        do {
            let labelVerticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[valueLabel]|",
                options: [],
                metrics: metrics,
                views: views)
            allConstraints += labelVerticalConstraints
        }
        
        do {
            let labelVerticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[slider]|",
                options: [],
                metrics: metrics,
                views: views)
            allConstraints += labelVerticalConstraints
        }
        
        let sliderHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[valueLabel]-padding-[slider(200)]|",
            options: [],
            metrics: metrics,
            views: views)
        allConstraints += sliderHorizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
}

extension JNRangeSliderCell : TTRangeSliderDelegate {
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        print("Delegate")
        _ = self.getValueAndUpdate(UpdatePayload(minVal: Int(sender.selectedMinimum), maxVal: Int(sender.selectedMaximum)))
    }
    
    func didEndTouches(in sender: TTRangeSlider!) {
        print("End")
        //call the send method
        self.defaultAction(sender: UpdatePayload(minVal: Int(sender.selectedMinimum), maxVal: Int(sender.selectedMaximum)))
    }
}

class JNPickerCell : JNPrefCell {
    var valueLabel = UILabel()
    var curIndex = 0
    
    func indexOfValue(_ value : PrefValue) -> Int {
        
        switch value.value {
        case .int( _):
            guard let index = prefItem.actualValues?.index(where: { (prefValue) -> Bool in
                return prefValue.intValue == value.intValue
            }) else {
                return 0
            }
            return index
        case .string( _):
            guard let index = prefItem.actualValues?.index(where: { (prefValue) -> Bool in
                return prefValue.stringValue == value.stringValue
            }) else {
                return 0
            }
            return index
        default:
            assertionFailure("Wrong type to do comparison")
            return 0
        }
    }
    
    func getDisplayValue(_ index: Int) -> String {
        return prefItem.displayValues![index]
    }
    
    override func setupCell() {
        curIndex = self.indexOfValue(prefItem.value)
        
        self.valueLabel.font = JNPrefCell.boldTextFont
        
        
        valueLabel.text = self.getDisplayValue(curIndex)
        valueLabel.sizeToFit()
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainContent.addSubview(valueLabel)
        
        
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
    
    override func getValueAndUpdate(_ value: Any) -> PrefValue {
        guard let prefValue = value as? PrefValue else {
            assertionFailure("Expected PrefValue")
            return PrefValue.noValue
        }
        self.valueLabel.text = self.getDisplayValue(self.curIndex)
        return prefValue
    }
    
    override func didSelectCell() {
        
        ActionSheetStringPicker.show(withTitle: prefItem.displayName, rows: prefItem.displayValues!, initialSelection: curIndex, doneBlock: { [unowned self] (picker, index, value) in
            
            guard let items = self.prefItem.actualValues else {
                assertionFailure("No items")
                return
            }
            
            guard index < items.count else {
                assertionFailure("No item corresponds to index")
                return
            }
            
            //must set the curIndex before the defaultAction call
            self.curIndex = index
            
            self.defaultAction(sender: items[index])
            
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
 
    open func prefCellValueChanged(value: PrefValue, withPrefItem prefItem: PrefItem) {
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
    
    open func prefCellValueChanged(value: PrefValue, withPrefItem prefItem: PrefItem) {
        print("Delegate method called for \(prefItem.displayName) = \(value)")
    }
    
}

