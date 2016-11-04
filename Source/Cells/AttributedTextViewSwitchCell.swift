//
//  AttributedTextViewSwitchCell.swift
//  SwiftyFORM
//
//  Created by Monica Silotto on 26/10/16.
//  Copyright © 2016 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct AttributedTextViewSwitchFormItemCellSizes {
    var attributedTextViewFrame: CGRect = CGRect.zero
    var switchFrame: CGRect = CGRect.zero
    var cellHeight: CGFloat = 0
}

public struct AttributedTextViewSwitchCellModel {
    var titleAttributedText: NSAttributedString?
    
    var valueDidChange: (Bool) -> Void = { (value: Bool) in
        SwiftyFormLog("value \(value)")
    }
}

public class AttributedTextViewSwitchCell: UITableViewCell, UITextViewDelegate, CellHeightProvider {
    public var model: AttributedTextViewSwitchCellModel
    public let textView = UITextView()
    public let switchView: UISwitch
    
    public init(model: AttributedTextViewSwitchCellModel) {
        self.model = model
        self.switchView = UISwitch()
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.delegate = self
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsMake(5, 16, 10, 16)
        textView.isUserInteractionEnabled = false
        clipsToBounds = true
        
        switchView.addTarget(self, action: #selector(SwitchCell.valueChanged), for: .valueChanged)
        
        contentView.addSubview(textView)
        contentView.addSubview(switchView)
        
        loadWithModel(model)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadWithModel(_ model: AttributedTextViewSwitchCellModel) {
        textView.attributedText = model.titleAttributedText
    }
    
    public func compute(_ cellWidth: CGFloat) -> AttributedTextViewSwitchFormItemCellSizes {
        
        var textViewFrame = CGRect.zero
        var switchFrame = CGRect.zero
        var maxY: CGFloat = 0
        let veryTallCell = CGRect(x: 0, y: 0, width: cellWidth, height: CGFloat.greatestFiniteMagnitude)
        var (slice, remainder) = veryTallCell.divided(atDistance: 10, from: .minYEdge)
        
        let bottomRemainder = remainder
        
        (slice, remainder) = remainder.divided(atDistance: 10, from: .minYEdge)
        maxY = slice.maxY
        
        if true {
            let availableSize = veryTallCell.size
            let size = textView.sizeThatFits(availableSize)
            (slice, remainder) = bottomRemainder.divided(atDistance: size.height, from: .minYEdge)
            textViewFrame = slice
        }
        maxY = max(textViewFrame.maxY, maxY)
        switchFrame = CGRect(x: cellWidth - switchView.frame.size.width - 16,
                             y: textViewFrame.size.height,
                             width: switchView.frame.size.width,
                             height: switchView.frame.size.height)
        maxY = max(switchFrame.maxY, maxY)
        
        maxY += 10 // switch bottom insets
        
        var result = AttributedTextViewSwitchFormItemCellSizes()
        result.attributedTextViewFrame = textViewFrame
        result.switchFrame = switchFrame
        result.cellHeight = ceil(maxY)
        return result
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizes: AttributedTextViewSwitchFormItemCellSizes = compute(bounds.width)
        textView.frame = sizes.attributedTextViewFrame
        switchView.frame = sizes.switchFrame
    }
    
    public func form_cellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let sizes: AttributedTextViewSwitchFormItemCellSizes = compute(bounds.width)
        let value = sizes.cellHeight
        //SwiftyFormLog("compute height of row: \(value)")
        return value
    }
    
    public func valueChanged() {
        SwiftyFormLog("value did change")
        model.valueDidChange(switchView.isOn)
    }
    
    public func setValueWithoutSync(_ value: Bool, animated: Bool) {
        SwiftyFormLog("set value \(value), animated \(animated)")
        switchView.setOn(value, animated: animated)
    }
}
