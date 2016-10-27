//
//  AttributedTextViewControllerCell.swift
//  SwiftyFORM
//
//  Created by Monica Silotto on 27/10/16.
//  Copyright © 2016 Simon Strandgaard. All rights reserved.
//

import UIKit

public struct AttributedTextViewControllerFormItemCellSizes {
    var attributedTextViewFrame: CGRect = CGRect.zero
    var cellHeight: CGFloat = 0
}

public struct AttributedTextViewControllerCellModel {
    var titleAttributedText: NSAttributedString?
    var maximumNumberOfLines: Int?
    var maximumHeigth: CGFloat?
}

public class AttributedTextViewControllerCell: UITableViewCell, UITextViewDelegate, CellHeightProvider, SelectRowDelegate {
    public let textView = UITextView()
    public var model: AttributedTextViewControllerCellModel
    let innerDidSelectRow: (AttributedTextViewControllerCell, AttributedTextViewControllerCellModel) -> Void
    
    public init(model: AttributedTextViewControllerCellModel, didSelectRow: @escaping (AttributedTextViewControllerCell, AttributedTextViewControllerCellModel) -> Void) {
        self.model = model
        self.innerDidSelectRow = didSelectRow
        super.init(style: .default, reuseIdentifier: nil)
        accessoryType = .disclosureIndicator
        
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.delegate = self
        
        textView.textContainerInset = UIEdgeInsetsMake(5, 16, 10, 16)
        textView.isEditable = false
        
        textView.textContainer.maximumNumberOfLines = model.maximumNumberOfLines ?? 4;
        textView.textContainer.lineBreakMode = .byTruncatingTail;
        clipsToBounds = true
        
        contentView.addSubview(textView)
        
        loadWithModel(model)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadWithModel(_ model: AttributedTextViewControllerCellModel) {
        textView.attributedText = model.titleAttributedText
    }
    
    public func form_didSelectRow(indexPath: IndexPath, tableView: UITableView) {
        SwiftyFormLog("will invoke")
        // hide keyboard when the user taps this kind of row
        tableView.form_firstResponder()?.resignFirstResponder()
        
        innerDidSelectRow(self, model)
        SwiftyFormLog("did invoke")
    }
    
    public func compute(_ cellWidth: CGFloat) -> AttributedTextViewControllerFormItemCellSizes {
        
        var textViewFrame = CGRect.zero
        var maxY: CGFloat = 0
        let maxHeight = model.maximumHeigth ?? 100
        let veryTallCell = CGRect(x: 0, y: 0, width: cellWidth, height: maxHeight)
        var (slice, remainder) = veryTallCell.divided(atDistance: 10, from: .minYEdge)
        
        let bottomRemainder = remainder
        
        (slice, remainder) = remainder.divided(atDistance: 10, from: .minYEdge)
        maxY = slice.maxY
        
        if true {
            let availableSize = veryTallCell.size
            let size = textView.sizeThatFits(availableSize)
            (slice, remainder) = bottomRemainder.divided(atDistance: size.height, from: .minYEdge)
            textViewFrame = slice
            textViewFrame = CGRect(x: textViewFrame.origin.x,
                                   y: textViewFrame.origin.y,
                                   width: textViewFrame.width - 16,
                                   height: textViewFrame.height)
        }
        maxY = max(textViewFrame.maxY, maxY)
        
        var result = AttributedTextViewControllerFormItemCellSizes()
        result.attributedTextViewFrame = textViewFrame
        result.cellHeight = ceil(maxY)
        return result
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizes: AttributedTextViewControllerFormItemCellSizes = compute(bounds.width)
        textView.frame = sizes.attributedTextViewFrame
    }
    
    public func form_cellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let sizes: AttributedTextViewControllerFormItemCellSizes = compute(bounds.width)
        let value = sizes.cellHeight
        return value
    }
}
