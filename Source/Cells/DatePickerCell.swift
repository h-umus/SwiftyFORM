// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit

struct DatePickerCellConstants {
	struct CellExpanded {
		static let height: CGFloat = 216
	}
}


public class DatePickerCellModel {
	var title: String = ""
	var toolbarMode: ToolbarMode = .Simple
	var datePickerMode: UIDatePickerMode = .DateAndTime
	var locale: NSLocale? = nil // default is [NSLocale currentLocale]. setting nil returns to default
	var minimumDate: NSDate? = nil // specify min/max date range. default is nil. When min > max, the values are ignored. Ignored in countdown timer mode
	var maximumDate: NSDate? = nil // default is nil
	var date: NSDate = NSDate()
	var expandCollapseWhenSelectingRow = true
	var selectionStyle = UITableViewCellSelectionStyle.Default
	
	var valueDidChange: NSDate -> Void = { (date: NSDate) in
		SwiftyFormLog("date \(date)")
	}
	
	var resolvedLocale: NSLocale {
		return locale ?? NSLocale.currentLocale()
	}
}

public class DatePickerCell: UITableViewCell, SelectRowDelegate {
	weak var expandedCell: DatePickerCellExpanded?
	public let model: DatePickerCellModel

	public init(model: DatePickerCellModel) {
		/*
		Known problem: UIDatePickerModeCountDownTimer is buggy and therefore not supported
		
		UIDatePicker has a bug in it when used in UIDatePickerModeCountDownTimer mode. The picker does not fire the target-action
		associated with the UIControlEventValueChanged event the first time the user changes the value by scrolling the wheels.
		It works fine for subsequent changes.
		http://stackoverflow.com/questions/20181980/uidatepicker-bug-uicontroleventvaluechanged-after-hitting-minimum-internal
		http://stackoverflow.com/questions/19251803/objective-c-uidatepicker-uicontroleventvaluechanged-only-fired-on-second-select
		
		Possible work around: Continuously poll for changes.
		*/
		assert(model.datePickerMode != .CountDownTimer, "CountDownTimer is not supported")

		self.model = model
		super.init(style: .Value1, reuseIdentifier: nil)
		selectionStyle = model.selectionStyle
		textLabel?.text = model.title
		
		updateValue()
		
		assignDefaultColors()
	}

	public required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	public func assignDefaultColors() {
		textLabel?.textColor = UIColor.blackColor()
		detailTextLabel?.textColor = UIColor.grayColor()
	}
	
	public func assignTintColors() {
		let color = self.tintColor
		SwiftyFormLog("assigning tint color: \(color)")
		textLabel?.textColor = color
		detailTextLabel?.textColor = color
	}

	public func obtainDateStyle(datePickerMode: UIDatePickerMode) -> NSDateFormatterStyle {
		switch datePickerMode {
		case .Time:
			return .NoStyle
		case .Date:
			return .LongStyle
		case .DateAndTime:
			return .ShortStyle
		case .CountDownTimer:
			return .NoStyle
		}
	}
	
	public func obtainTimeStyle(datePickerMode: UIDatePickerMode) -> NSDateFormatterStyle {
		switch datePickerMode {
		case .Time:
			return .ShortStyle
		case .Date:
			return .NoStyle
		case .DateAndTime:
			return .ShortStyle
		case .CountDownTimer:
			return .ShortStyle
		}
	}
	
	public var humanReadableValue: String {
		if model.datePickerMode == .CountDownTimer {
			return "Unsupported"
		}
		let date = model.date
		//SwiftyFormLog("date: \(date)")
		let dateFormatter = NSDateFormatter()
		dateFormatter.locale = model.resolvedLocale
		dateFormatter.dateStyle = obtainDateStyle(model.datePickerMode)
		dateFormatter.timeStyle = obtainTimeStyle(model.datePickerMode)
		return dateFormatter.stringFromDate(date)
	}

	public func updateValue() {
		detailTextLabel?.text = humanReadableValue
	}
	
	func setDateWithoutSync(date: NSDate, animated: Bool) {
		SwiftyFormLog("set date \(date), animated \(animated)")
		model.date = date
		updateValue()
		
		expandedCell?.datePicker.setDate(model.date, animated: animated)
	}
	
	public func form_cellHeight(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
		return 60
	}
	
	public func form_didSelectRow(indexPath: NSIndexPath, tableView: UITableView) {
		if model.expandCollapseWhenSelectingRow == false {
			print("cell is always expanded")
			return
		}

		if isExpandedCellVisible {
			resignFirstResponder()
		} else {
			becomeFirstResponder()
		}
		form_deselectRow()
	}


	// MARK: UIResponder
	
	public override func canBecomeFirstResponder() -> Bool {
		if model.expandCollapseWhenSelectingRow == false {
			return false
		}
		return true
	}
	
	public override func becomeFirstResponder() -> Bool {
		if !super.becomeFirstResponder() {
			return false
		}
		expand()
		return true
	}
	
	public override func resignFirstResponder() -> Bool {
		collapse()
		return super.resignFirstResponder()
	}

	
	// MARK: Expand collapse

	var isExpandedCellVisible: Bool {
		guard let sectionArray = form_tableView()?.dataSource as? TableViewSectionArray else {
			return false
		}
		guard let expandedItem = sectionArray.findItem(expandedCell) else {
			return false
		}
		if expandedItem.hidden {
			return false
		}
		return true
	}
	
	func toggleExpandCollapse() {
		guard let tableView = form_tableView() as? FormTableView else {
			return
		}
		guard let expandedCell = expandedCell else {
			return
		}
		tableView.toggleExpandCollapse(expandedCell: expandedCell)
	}
	
	func expand() {
		if isExpandedCellVisible {
			assignTintColors()
		} else {
			toggleExpandCollapse()
		}
	}
	
	func collapse() {
		if isExpandedCellVisible {
			toggleExpandCollapse()
		}
	}
	
}


public class DatePickerCellExpanded: UITableViewCell, CellHeightProvider {
	weak var collapsedCell: DatePickerCell?
	
	public func form_cellHeight(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
		return DatePickerCellConstants.CellExpanded.height
	}
	
	lazy var datePicker: UIDatePicker = {
		let instance = UIDatePicker()
		instance.addTarget(self, action: #selector(DatePickerCellExpanded.valueChanged), forControlEvents: .ValueChanged)
//		instance.valueDidChange = nil
		return instance
	}()
	
	func configure(model: DatePickerCellModel) {
		datePicker.datePickerMode = model.datePickerMode
		datePicker.minimumDate = model.minimumDate
		datePicker.maximumDate = model.maximumDate
		datePicker.locale = model.resolvedLocale
	}
	
	public func valueChanged() {
		guard let collapsedCell = collapsedCell else {
			return
		}
		let model = collapsedCell.model
		let date = datePicker.date
		model.date = date
		
		collapsedCell.updateValue()
		
		model.valueDidChange(date)
	}
	
	public init() {
		super.init(style: .Default, reuseIdentifier: nil)
		addSubview(datePicker)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		datePicker.frame = bounds
		
//		let tinyDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.001 * Float(NSEC_PER_SEC)))
//		dispatch_after(tinyDelay, dispatch_get_main_queue()) {
//			self.assignInitialValue()
//		}
	}
	
//	func assignInitialValue() {
//		if slider.valueDidChange != nil {
//			return
//		}
//		guard let model = collapsedCell?.model else {
//			return
//		}
//		
//		slider.zoomUIHidden = !model.zoomUI
//		
//		let sliderViewModel = model.sliderViewModel(sliderWidth: slider.bounds.width)
//		slider.model = sliderViewModel
//		slider.layout.model = sliderViewModel
//		slider.reloadSlider()
//		slider.reloadZoomLabel()
//		
//		let decimalScale: Double = pow(Double(10), Double(model.decimalPlaces))
//		let scaledValue = Double(model.value) / decimalScale
//		
//		/*
//		First we scroll to the right offset
//		Next establish two way binding
//		*/
//		slider.value = scaledValue
//		
//		slider.valueDidChange = { [weak self] (changeModel: PrecisionSlider.SliderDidChangeModel) in
//			self?.sliderDidChange(changeModel)
//		}
//	}
	
//	func setValueWithoutSync(value: Int) {
//		guard let model = collapsedCell?.model else {
//			return
//		}
//		SwiftyFormLog("set value \(value)")
//		
//		let decimalScale: Double = pow(Double(10), Double(model.decimalPlaces))
//		let scaledValue = Double(value) / decimalScale
//		slider.value = scaledValue
//	}
}
