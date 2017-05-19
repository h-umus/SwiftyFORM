// MIT license. Copyright (c) 2016 SwiftyFORM. All rights reserved.
import Foundation

public class OptionRowModel: CustomStringConvertible {
	public let title: String
	public let identifier: String
	
	public init(_ title: String, _ identifier: String) {
		self.title = title
		self.identifier = identifier
	}
	
	public var description: String {
		return "\(title)-\(identifier)"
	}
}

public class OptionPickerFormItem: FormItem {
	override func accept(visitor: FormItemVisitor) {
		visitor.visit(object: self)
	}
	
	public var placeholder: String = ""

	@discardableResult
	public func placeholder(_ placeholder: String) -> Self {
		self.placeholder = placeholder
		return self
	}
	
	public var title: String = ""

	@discardableResult
	public func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	public var options = [OptionRowModel]()
    
    public var reloadPersistentValidationState: (Void) -> Void = {}
    
    public let validatorBuilder = ValidatorBuilder()
    
    @discardableResult
    public func validate(_ specification: Specification, message: String) -> Self {
        validatorBuilder.hardValidate(specification, message: message)
        return self
    }
    
    @discardableResult
    public func softValidate(_ specification: Specification, message: String) -> Self {
        validatorBuilder.softValidate(specification, message: message)
        return self
    }
    
    @discardableResult
    public func submitValidate(_ specification: Specification, message: String) -> Self {
        validatorBuilder.submitValidate(specification, message: message)
        return self
    }
    
    @discardableResult
    public func required(_ message: String) -> Self {
        submitValidate(CountSpecification.min(1), message: message)
        return self
    }
    
    public func liveValidateValueText() -> ValidateResult {
        return  validatorBuilder.build().liveValidate(self.selected?.identifier)
    }
    
    public func liveValidateText(_ text: String) -> ValidateResult {
        return validatorBuilder.build().validate(text, checkHardRule: true, checkSoftRule: true, checkSubmitRule: false)
    }
    
    public func submitValidateValueText() -> ValidateResult {
        return validatorBuilder.build().submitValidate(self.selected?.identifier)
    }
    
    public func submitValidateText(_ text: String) -> ValidateResult {
        return validatorBuilder.build().validate(text, checkHardRule: true, checkSoftRule: true, checkSubmitRule: true)
    }
    
    public func validateText(_ text: String, checkHardRule: Bool, checkSoftRule: Bool, checkSubmitRule: Bool) -> ValidateResult {
        return validatorBuilder.build().validate(text, checkHardRule: checkHardRule, checkSoftRule: checkSoftRule, checkSubmitRule: checkSubmitRule)
    }
    
	@discardableResult
	public func append(_ name: String, identifier: String? = nil) -> Self {
		options.append(OptionRowModel(name, identifier ?? name))
		return self
	}
	
	public func selectOptionWithTitle(_ title: String) {
		for option in options {
			if option.title == title {
				self.setSelectedOptionRow(option)
				SwiftyFormLog("initial selected option: \(option)")
			}
		}
	}
	
	public func selectOptionWithIdentifier(_ identifier: String) {
		for option in options {
			if option.identifier == identifier {
				self.setSelectedOptionRow(option)
				SwiftyFormLog("initial selected option: \(option)")
			}
		}
	}

	public typealias SyncBlock = (_ selected: OptionRowModel?) -> Void
	public var syncCellWithValue: SyncBlock = { (selected: OptionRowModel?) in
		SwiftyFormLog("sync is not overridden")
	}
	
	internal var innerSelected: OptionRowModel? = nil
	public var selected: OptionRowModel? {
		get {
			return self.innerSelected
		}
		set {
			self.setSelectedOptionRow(newValue)
		}
	}
	
	public func setSelectedOptionRow(_ selected: OptionRowModel?) {
		SwiftyFormLog("option: \(String(describing: selected?.title))")
		innerSelected = selected
		syncCellWithValue(selected)
	}
	
	public typealias ValueDidChange = (_ selected: OptionRowModel?) -> Void
	public var valueDidChange: ValueDidChange = { (selected: OptionRowModel?) in
		SwiftyFormLog("value did change not overridden")
	}
    
    public var obtainTitleWidth: (Void) -> CGFloat = {
        return 0
    }
    
    public var assignTitleWidth: (CGFloat) -> Void = { (width: CGFloat) in
        // do nothing
    }
}

public class OptionRowFormItem: FormItem {
	override func accept(visitor: FormItemVisitor) {
		visitor.visit(object: self)
	}
	
	public var title: String = ""

	@discardableResult
	public func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	public var selected: Bool = false
	
	public var context: AnyObject?
}
