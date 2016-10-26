// MIT license. Copyright (c) 2016 SwiftyFORM. All rights reserved.
import UIKit

public class OptionViewControllerCellSizes {
    public let titleLabelFrame: CGRect
    public let optionLabelFrame: CGRect
    
    public init(titleLabelFrame: CGRect, optionLabelFrame: CGRect) {
        self.titleLabelFrame = titleLabelFrame
        self.optionLabelFrame = optionLabelFrame
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
    public let optionLabel = UILabel()
	fileprivate let model: OptionViewControllerCellModel
	fileprivate var selectedOptionRow: OptionRowModel? = nil
	fileprivate weak var parentViewController: UIViewController?
	
	public init(parentViewController: UIViewController, model: OptionViewControllerCellModel) {
		self.parentViewController = parentViewController
		self.model = model
		self.selectedOptionRow = model.selectedOptionRow
		super.init(style: .value1, reuseIdentifier: nil)
        contentView.addSubview(optionLabel)
		accessoryType = .disclosureIndicator
		textLabel?.text = model.title
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
        var optionLabelFrame = CGRect.zero
        let veryTallCell = CGRect(x: 0, y: 0, width: cellWidth, height: CGFloat.greatestFiniteMagnitude)
        let area = veryTallCell.insetBy(dx: 16, dy: 0)
        
        var (topRect, _) = area.divided(atDistance: 44, from: .minYEdge)
        topRect = CGRect.init(x: topRect.origin.x, y: topRect.origin.y, width: topRect.width - 18, height: topRect.height)
        if true {
            let size = textLabel?.sizeThatFits(area.size)
            var titleLabelWidth = size!.width
            
            switch titleWidthMode {
            case .auto:
                optionLabel.textAlignment = .right
                break
            case let .assign(width):
                optionLabel.textAlignment = .left
                let w = CGFloat(width)
                if w > titleLabelWidth {
                    titleLabelWidth = w
                }
            }
            
            var (slice, remainder) = topRect.divided(atDistance: titleLabelWidth, from: .minXEdge)
            titleLabelFrame = slice
            (_, remainder) = remainder.divided(atDistance: 10, from: .minXEdge)
            remainder.size.width += 4
            optionLabelFrame = remainder
        }
        
        return OptionViewControllerCellSizes(titleLabelFrame: titleLabelFrame, optionLabelFrame: optionLabelFrame)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let sizes: OptionViewControllerCellSizes = compute(bounds.width)
        textLabel?.frame = sizes.titleLabelFrame
        optionLabel.frame = sizes.optionLabelFrame
    }
	
	fileprivate func updateValue() {
		let s = humanReadableValue()
		SwiftyFormLog("update value \(s)")
		optionLabel.text = s
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
