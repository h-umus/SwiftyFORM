// MIT license. Copyright (c) 2016 SwiftyFORM. All rights reserved.
import UIKit

public class OptionViewControllerCellSizes {
    public let titleLabelFrame: CGRect
    public let valueLabelFrame: CGRect
    public let errorLabelFrame: CGRect
    public let cellHeight: CGFloat
    
    public init(titleLabelFrame: CGRect, valueLabelFrame: CGRect, errorLabelFrame:CGRect, cellHeight: CGFloat) {
        self.titleLabelFrame = titleLabelFrame
        self.valueLabelFrame = valueLabelFrame
        self.errorLabelFrame = errorLabelFrame
        self.cellHeight = cellHeight
    }
}

public struct OptionViewControllerCellModel {
	var title: String = ""
	var placeholder: String = ""
	var optionField: OptionPickerFormItem? = nil
	var selectedOptionRow: OptionRowModel? = nil

	var valueDidChange: (OptionRowModel?) -> Void = { (value: OptionRowModel?) in
		SwiftyFormLog("value \(value)")
	}
}

public class OptionViewControllerCell: UITableViewCell, SelectRowDelegate {
    public let valueLabel = UILabel()
    public let errorLabel = UILabel()
	fileprivate let model: OptionViewControllerCellModel
	fileprivate var selectedOptionRow: OptionRowModel? = nil
	fileprivate weak var parentViewController: UIViewController?
	
	public init(parentViewController: UIViewController, model: OptionViewControllerCellModel) {
		self.parentViewController = parentViewController
		self.model = model
		self.selectedOptionRow = model.selectedOptionRow
		super.init(style: .default, reuseIdentifier: nil)
		accessoryType = .disclosureIndicator
		textLabel?.text = model.title
        valueLabel.textColor = kValueLabelColor
        contentView.addSubview(valueLabel)
        
        errorLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        errorLabel.textColor = UIColor.red
        errorLabel.numberOfLines = 0
        contentView.addSubview(errorLabel)
        updateErrorLabel((model.optionField?.liveValidateValueText())!)
        
		updateValue()
	}
	
	public required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func humanReadableValue() -> String? {
		if let option = selectedOptionRow {
			return option.title
		} else {
			return model.placeholder
		}
	}
    
    public enum TitleWidthMode {
        case auto
        case assign(width: CGFloat)
    }
    
    public var titleWidthMode: TitleWidthMode = .auto
    
    public func compute(_ cellWidth: CGFloat) -> OptionViewControllerCellSizes {
        
        var titleLabelFrame = CGRect.zero
        var valueLabelFrame = CGRect.zero
        var errorLabelFrame = CGRect.zero
        var cellHeight: CGFloat = 0
        let veryTallCell = CGRect(x: 0, y: 0, width: cellWidth, height: CGFloat.greatestFiniteMagnitude)
        let area = veryTallCell.insetBy(dx: 16, dy: 0)
        
        var (topRect, _) = area.divided(atDistance: 44, from: .minYEdge)
        topRect = CGRect.init(x: topRect.origin.x, y: topRect.origin.y, width: topRect.width - 18, height: topRect.height)
        if true {
            let size = textLabel?.sizeThatFits(area.size)
            var titleLabelWidth = size!.width
            
            switch titleWidthMode {
            case .auto:
                valueLabel.textAlignment = .right
                break
            case let .assign(width):
                valueLabel.textAlignment = .left
                let w = CGFloat(width)
                if w > titleLabelWidth {
                    titleLabelWidth = w
                }
            }
            
            var (slice, remainder) = topRect.divided(atDistance: titleLabelWidth, from: .minXEdge)
            titleLabelFrame = slice
            (_, remainder) = remainder.divided(atDistance: 10, from: .minXEdge)
            remainder.size.width += 4
            valueLabelFrame = remainder
        }
        let size = errorLabel.sizeThatFits(area.size)
        if size.height > 0.1 {
            var r = topRect
            r.origin.y = topRect.maxY - 6
            let (slice, _) = r.divided(atDistance: size.height, from: .minYEdge)
            errorLabelFrame = slice
            cellHeight = ceil(errorLabelFrame.maxY + 10)
        }
        
        return OptionViewControllerCellSizes(titleLabelFrame: titleLabelFrame, valueLabelFrame: valueLabelFrame, errorLabelFrame: errorLabelFrame, cellHeight: cellHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let sizes: OptionViewControllerCellSizes = compute(bounds.width)
        textLabel?.frame = sizes.titleLabelFrame
        valueLabel.frame = sizes.valueLabelFrame
        errorLabel.frame = sizes.errorLabelFrame
    }
	
	fileprivate func updateValue() {
		let s = humanReadableValue()
		SwiftyFormLog("update value \(s)")
		valueLabel.text = s
        _ = validateAndUpdateErrorIfNeeded(selectedOptionRow?.identifier ?? "", shouldInstallTimer: true, checkSubmitRule: false)
	}
    
    public func updateErrorLabel(_ result: ValidateResult) {
        switch result {
        case .valid:
            errorLabel.text = nil
        case .hardInvalid(let message):
            errorLabel.text = message
        case .softInvalid(let message):
            errorLabel.text = message
        }
    }
    
    public var lastResult: ValidateResult?
    
    public var hideErrorMessageAfterFewSecondsTimer: Timer?
    public func invalidateTimer() {
        if let timer = hideErrorMessageAfterFewSecondsTimer {
            timer.invalidate()
            hideErrorMessageAfterFewSecondsTimer = nil
        }
    }
    
    public func installTimer() {
        invalidateTimer()
        let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(TextFieldFormItemCell.timerUpdate), userInfo: nil, repeats: false)
        hideErrorMessageAfterFewSecondsTimer = timer
    }
    
    // Returns true  when valid
    // Returns false when invalid
    public func validateAndUpdateErrorIfNeeded(_ text: String, shouldInstallTimer: Bool, checkSubmitRule: Bool) -> Bool {
        
        let tableView: UITableView? = form_tableView()
        
        let result: ValidateResult = model.optionField!.validateText(text, checkHardRule: true, checkSoftRule: true, checkSubmitRule: checkSubmitRule)
        if let lastResult = lastResult {
            if lastResult == result {
                switch result {
                case .valid:
                    //SwiftyFormLog("same valid")
                    return true
                case .hardInvalid:
                    //SwiftyFormLog("same hard invalid")
                    invalidateTimer()
                    if shouldInstallTimer {
                        installTimer()
                    }
                    return false
                case .softInvalid:
                    //SwiftyFormLog("same soft invalid")
                    invalidateTimer()
                    if shouldInstallTimer {
                        installTimer()
                    }
                    return true
                }
            }
        }
        lastResult = result
        
        switch result {
        case .valid:
            //SwiftyFormLog("different valid")
            if let tv = tableView {
                tv.beginUpdates()
                errorLabel.text = nil
                setNeedsLayout()
                tv.endUpdates()
                
                invalidateTimer()
            }
            return true
        case let .hardInvalid(message):
            //SwiftyFormLog("different hard invalid")
            if let tv = tableView {
                tv.beginUpdates()
                errorLabel.text = message
                setNeedsLayout()
                tv.endUpdates()
                
                invalidateTimer()
                if shouldInstallTimer {
                    installTimer()
                }
            }
            return false
        case let .softInvalid(message):
            //SwiftyFormLog("different soft invalid")
            if let tv = tableView {
                tv.beginUpdates()
                errorLabel.text = message
                setNeedsLayout()
                tv.endUpdates()
                
                invalidateTimer()
                if shouldInstallTimer {
                    installTimer()
                }
            }
            return true
        }
    }
    
    public func timerUpdate() {
        invalidateTimer()
        let s = selectedOptionRow?.identifier ?? ""
        _ = validateAndUpdateErrorIfNeeded(s, shouldInstallTimer: false, checkSubmitRule: false)
    }
    
    public func reloadPersistentValidationState() {
        invalidateTimer()
        let s = selectedOptionRow?.identifier ?? ""
        _ = validateAndUpdateErrorIfNeeded(s, shouldInstallTimer: false, checkSubmitRule: true)
    }
    
    public func form_cellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let sizes: OptionViewControllerCellSizes = compute(bounds.width)
        let value = sizes.cellHeight
        return value
    }
	
	public func setSelectedOptionRowWithoutPropagation(_ option: OptionRowModel?) {
		SwiftyFormLog("set selected option: \(option?.title) \(option?.identifier)")
		
		selectedOptionRow = option
		updateValue()
	}
	
	fileprivate func viaOptionList_userPickedOption(_ option: OptionRowModel) {
		SwiftyFormLog("user picked option: \(option.title) \(option.identifier)")
		
		if selectedOptionRow === option {
			SwiftyFormLog("no change")
			return
		}
		
		selectedOptionRow = option
		updateValue()
		model.valueDidChange(option)
	}

	public func form_didSelectRow(indexPath: IndexPath, tableView: UITableView) {
		SwiftyFormLog("will invoke")
		
		guard let vc: UIViewController = parentViewController else {
			SwiftyFormLog("Expected a parent view controller")
			return
		}
		guard let nc: UINavigationController = vc.navigationController else {
			SwiftyFormLog("Expected parent view controller to have a navigation controller")
			return
		}
		guard let optionField = model.optionField else {
			SwiftyFormLog("Expected model to have an optionField")
			return
		}
		
		// hide keyboard when the user taps this kind of row
		tableView.form_firstResponder()?.resignFirstResponder()

		let childViewController = OptionListViewController(optionField: optionField) { [weak self] (selected: OptionRowModel) in
			self?.viaOptionList_userPickedOption(selected)
			nc.popViewController(animated: true)
		}
		nc.pushViewController(childViewController, animated: true)
		
		SwiftyFormLog("did invoke")
	}
}
