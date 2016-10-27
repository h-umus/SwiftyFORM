//
//  AttributedTextViewControllerFormItem.swift
//  SwiftyFORM
//
//  Created by Monica Silotto on 27/10/16.
//  Copyright © 2016 Simon Strandgaard. All rights reserved.
//

import Foundation

public class AttributedTextViewControllerFormItem: FormItem {
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
    
    public var maximumNumberOfLines: Int?
    public var maximumHeigth: CGFloat?
    
    typealias SyncBlock = (_ value: NSAttributedString?) -> Void
    var syncCellWithValue: SyncBlock = { (string: NSAttributedString?) in
        SwiftyFormLog("sync is not overridden")
    }
    
    // MARK: - ViewController
    
    @discardableResult
    public func viewController(_ aClass: UIViewController.Type) -> Self {
        createViewController = { (dismissCommand: CommandProtocol) in
            return aClass.init()
        }
        return self
    }
    
    @discardableResult
    public func storyboard(_ name: String, bundle storyboardBundleOrNil: Bundle?) -> Self {
        createViewController = { (dismissCommand: CommandProtocol) in
            let storyboard: UIStoryboard = UIStoryboard(name: name, bundle: storyboardBundleOrNil)
            return storyboard.instantiateInitialViewController()
        }
        return self
    }
    
    // the view controller must invoke the dismiss block when it's being dismissed
    public typealias CreateViewController = (CommandProtocol) -> UIViewController?
    public var createViewController: CreateViewController?
    
    // dismissing the view controller
    public typealias PopViewController = (ViewControllerFormItemPopContext) -> Void
    public var willPopViewController: PopViewController?
}
