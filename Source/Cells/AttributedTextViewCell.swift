//
//  AttributedTextViewCell.swift
//  SwiftyFORM
//
//  Created by Monica Silotto on 26/10/16.
//  Copyright © 2016 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct AttributedTextViewFormItemCellSizes {
    var attributedTextViewFrame: CGRect = CGRect.zero
    var cellHeight: CGFloat = 0
}

public struct AttributedTextViewCellModel {
    var titleAttributedText: NSAttributedString?
}

public class AttributedTextViewCell: UITableViewCell, UITextViewDelegate, CellHeightProvider {
    public let textView = UITextView()
    public var model: AttributedTextViewCellModel
    
    public init(model: AttributedTextViewCellModel) {
        self.model = model
        super.init(style: .default, reuseIdentifier: nil)
        
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.delegate = self
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsetsMake(5, 16, 10, 16)
        textView.isEditable = false
        clipsToBounds = true
        
        contentView.addSubview(textView)
        
        loadWithModel(model)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadWithModel(_ model: AttributedTextViewCellModel) {
        selectionStyle = .none
        textView.attributedText = model.titleAttributedText
    }
    
    public func compute(_ cellWidth: CGFloat) -> AttributedTextViewFormItemCellSizes {
        
        var textViewFrame = CGRect.zero
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
        
        var result = AttributedTextViewFormItemCellSizes()
        result.attributedTextViewFrame = textViewFrame
        result.cellHeight = ceil(maxY)
        return result
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizes: AttributedTextViewFormItemCellSizes = compute(bounds.width)
        textView.frame = sizes.attributedTextViewFrame
    }
    
    public func form_cellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let sizes: AttributedTextViewFormItemCellSizes = compute(bounds.width)
        let value = sizes.cellHeight
        //SwiftyFormLog("compute height of row: \(value)")
        return value
    }
}
