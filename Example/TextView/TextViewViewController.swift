// MIT license. Copyright (c) 2016 SwiftyFORM. All rights reserved.
import UIKit
import SwiftyFORM

class TextViewViewController: FormViewController {

	override func populate(_ builder: FormBuilder) {
		builder.navigationTitle = "TextViews"
		builder += longSummary
		builder += notes
		builder += commentArea
		builder += userDescription
		builder += SectionHeaderTitleFormItem().title("Buttons")
		builder += randomizeButton
		builder += clearButton
        builder += SectionHeaderTitleFormItem(title: "Attributed Text View")
        builder += htmlArea
        builder += textSwitch
	}

	lazy var longSummary: TextViewFormItem = {
		let instance = TextViewFormItem()
		instance.title("Long summary").placeholder("placeholder")
		instance.value = "Lorem ipsum"
		return instance
		}()
	
	lazy var notes: TextViewFormItem = {
		let instance = TextViewFormItem()
		instance.title("Notes").placeholder("I'm a placeholder")
		return instance
		}()
	
	lazy var commentArea: TextViewFormItem = {
		let instance = TextViewFormItem()
		instance.title("Comments").placeholder("I'm also a placeholder")
		return instance
		}()
	
	lazy var userDescription: TextViewFormItem = {
		let instance = TextViewFormItem()
		instance.title("Description").placeholder("Yet another placeholder")
		return instance
		}()
	
	lazy var randomizeButton: ButtonFormItem = {
		let instance = ButtonFormItem()
		instance.title = "Randomize"
		instance.action = { [weak self] in
			self?.randomize()
		}
		return instance
		}()
	
	lazy var clearButton: ButtonFormItem = {
		let instance = ButtonFormItem()
		instance.title = "Clear"
		instance.action = { [weak self] in
			self?.clear()
		}
		return instance
		}()
	
    lazy var htmlArea: AttributedTextViewFormItem = {
        let instance = AttributedTextViewFormItem()
        let text = "<h1>HTML Ipsum Presents</h1> <p><strong>Pellentesque habitant morbi tristique</strong> senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. <em>Aenean ultricies mi vitae est.</em> Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, <code>commodo vitae</code>, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis.</p> <h2>Header Level 2</h2> <ol> <li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li> <li>Aliquam tincidunt mauris eu risus.</li> </ol> <blockquote><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus magna. Cras in mi at felis aliquet congue. Ut a est eget ligula molestie gravida. Curabitur massa. Donec eleifend, libero at sagittis mollis, tellus est malesuada tellus, at luctus turpis elit sit amet quam. Vivamus pretium ornare est.</p></blockquote> <h3>Header Level 3</h3> <ul> <li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li> <li>Aliquam tincidunt mauris eu risus.</li> </ul>"
        do {
            let str = try NSAttributedString(data: (text.data(using: String.Encoding.unicode, allowLossyConversion: true)!),
                                             options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                             documentAttributes: nil)
            instance.title(str)
        } catch {
            print(error)
        }
        return instance
    }()
    
    lazy var textSwitch: AttributedTextViewSwitchFormItem = {
        let instance = AttributedTextViewSwitchFormItem()
        let text = "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante."
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .justified
        
        let str = NSAttributedString.init(string: text, attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSBaselineOffsetAttributeName: 0])
        instance.title(str)
        instance.value = true
        return instance
    }()
    
	func pickRandom(_ strings: [String]) -> String {
		if strings.count == 0 {
			return ""
		}
		let i = randomInt(0, strings.count - 1)
		return strings[i]
	}
	
	func appendRandom(_ textView: TextViewFormItem, strings: [String]) {
		let notEmpty = textView.value.characters.count != 0
		var s = ""
		if notEmpty {
			s = " "
		}
		textView.value += s + pickRandom(strings)
	}
	
	func randomize() {
		appendRandom(longSummary, strings: ["Hello", "World", "Cat", "Water", "Fish", "Hund"])
		appendRandom(notes, strings: ["Hat", "Ham", "Has"])
		commentArea.value += pickRandom(["a", "b", "c"])
		userDescription.value += pickRandom(["x", "y", "z", "w"])
	}

	func clear() {
		longSummary.value = ""
		notes.value = ""
		commentArea.value = ""
		userDescription.value = ""
	}
}
