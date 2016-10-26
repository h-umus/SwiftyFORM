//
//  AttributedTextViewFormItem.swift
//  SwiftyFORM
//
//  Created by Monica Silotto on 26/10/16.
//  Copyright © 2016 Simon Strandgaard. All rights reserved.
//

import Foundation

public class AttributedTextViewFormItem: FormItem {
    override func accept(visitor: FormItemVisitor) {
        visitor.visit(object: self)
    }
    
    public var title: NSAttributedString?
    
    @discardableResult
    public func title(_ title: NSAttributedString?) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func title(_ title: String, _ attributes: [String: AnyObject]? = nil) -> Self {
        self.title = NSAttributedString(string: title, attributes: attributes)
        return self
    }
    
    typealias SyncBlock = (_ value: NSAttributedString?) -> Void
    var syncCellWithValue: SyncBlock = { (string: NSAttributedString?) in
        SwiftyFormLog("sync is not overridden")
    }
    
    internal var innerValue: NSAttributedString?
    public var value: NSAttributedString? {
        get {
            return self.innerValue
        }
        set {
            self.assignValueAndSync(newValue)
        }
    }
    
    func assignValueAndSync(_ value: NSAttributedString?) {
        innerValue = value
        syncCellWithValue(value)
    }
}
