// MIT license. Copyright (c) 2016 SwiftyFORM. All rights reserved.
import Foundation

public class TextViewFormItem: FormItem {
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
	
	typealias SyncBlock = (_ value: String) -> Void
	var syncCellWithValue: SyncBlock = { (string: String) in
		SwiftyFormLog("sync is not overridden")
	}
	
	internal var innerValue: String = ""
	public var value: String {
		get {
			return self.innerValue
		}
		set {
			self.assignValueAndSync(newValue)
		}
	}
    
    public typealias TextViewDidChangeBlock = (_ value: String) -> Void
    public var textViewDidChangeBlock: TextViewDidChangeBlock = { (value: String) in
        SwiftyFormLog("not overridden")
    }
    
    public func textViewDidChange(_ value: String) {
        innerValue = value
        textViewDidChangeBlock(value)
    }
	
	func assignValueAndSync(_ value: String) {
		innerValue = value
		syncCellWithValue(value)
	}
}
