//
//  TextView.swift
//  TextView-Example
//
//  Created by Joseph Levy on 1/31/23.
//  Working for iOS 15 and 16 3/8/23
//  Popover for font in iOS added 8/9/23

import SwiftUI
public struct TextViewWithPopover : View {
    public init(attributedText: Binding<AttributedString>, allowsEditingTextAttributes: Bool = false, fontDesigner: FontDesigner = FontDesigner.shared) {
        _attributedText = attributedText
        self.allowsEditingTextAttributes = allowsEditingTextAttributes
        _fontDesigner = .init(wrappedValue: fontDesigner)
    }

    @Binding public var attributedText: AttributedString
    public var allowsEditingTextAttributes = false
    @ObservedObject public var fontDesigner : FontDesigner = FontDesigner.shared
    public var body: some View {
        TextView(attributedText: $attributedText, allowsEditingTextAttributes: allowsEditingTextAttributes, fontDesigner: fontDesigner)
            .popover(isPresented: $fontDesigner.isPresented) {
                let _ = print("Font Design Shown")
                FontDesignerView(fontDesigner: fontDesigner).onDisappear {
                    print("Font Designer Disappeared")
                }
            }
    }
}
    
public struct TextView: UIViewRepresentable {
    public init(attributedText: Binding<AttributedString>, allowsEditingTextAttributes: Bool, fontDesigner: FontDesigner = FontDesigner.shared) {
        self._attributedText = attributedText
        self.allowsEditingTextAttributes = allowsEditingTextAttributes
        self.fontDesigner = fontDesigner
        self._attributedText = attributedText
    }
    
    @ObservedObject public var fontDesigner : FontDesigner

    //debugPrint(String(returnValue[run.range].characters))
    @Binding public var attributedText: AttributedString
    public var allowsEditingTextAttributes: Bool 
    
    let defaultFont = UIFont.preferredFont(forTextStyle: .body)
    
    public func makeUIView(context: Context) -> UITextView {
        let uiView = MyTextView()//fontDesigner: fontDesigner, frame: CGRect(x: 0, y: 0, width: 100, height: 100))// changeFont
        uiView.font = defaultFont
        //uiView.typingAttributes = [.font : defaultFont ]
        uiView.allowsEditingTextAttributes = allowsEditingTextAttributes
        uiView.textContainerInset = .zero
        uiView.contentInset = UIEdgeInsets()
        uiView.textAlignment = .center // like Text
        uiView.contentInsetAdjustmentBehavior = .never // .always or .automatic
        //uiView.usesStandardTextScaling = true
        uiView.delegate = context.coordinator
        uiView.attributedText = attributedText.nsAttributedString

        return uiView
    }
    
    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText.nsAttributedString
    }
    
    public func makeCoordinator() -> TextView.Coordinator {
        Coordinator($attributedText, fontDesigner: fontDesigner)
    }
    
    public class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<AttributedString>
        var fontDesigner: FontDesigner
        
        public init(_ text: Binding<AttributedString>, fontDesigner: FontDesigner ) {
            self.text = text
            self.fontDesigner = fontDesigner
        }

        public func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.attributedText.attributedString
        }
        
        public func textViewDidChangeSelection(_ textView: UITextView) {
            fontDesigner.selection = textView.selectedRange
            let selection = fontDesigner.selection
            fontDesigner.textView = textView
            textView.attributedText.enumerateAttribute(.font, in: selection) { (value, range, stopFlag)  in
                if let value, range == selection {
                    // All the same font set fontDesigner font to it
                    let font =  value as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
                    fontDesigner.fontDescriptor = font.fontDescriptor
                    fontDesigner.fontSize = font.pointSize
                } else { // or do nothing?
                    fontDesigner.fontDescriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor
                    fontDesigner.fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
                }
                stopFlag.pointee = true
            }
            textView.attributedText.enumerateAttribute(.backgroundColor, in: selection)  { (value, range, stopFlag)  in
                if let value, range == selection {
                    fontDesigner.backgroundColor = (value as? UIColor ?? UIColor.white).cgColor
                } else { fontDesigner.backgroundColor = UIColor.white.cgColor }
                stopFlag.pointee = true
            }
            textView.attributedText.enumerateAttribute(.foregroundColor, in: selection)  { (value, range, stopFlag)  in
                if let value, range == selection {
                    fontDesigner.fontColor = (value as? UIColor ?? UIColor.white).cgColor
                } else { fontDesigner.fontColor = UIColor.black.cgColor }
                stopFlag.pointee = true
            }
        }
        
    }

    public class MyTextView: UITextView {

        let fontDesigner = FontDesigner.shared
//        lazy var vc = {
//            let vc = UIHostingController(rootView: FontDesignerView(fontDesigner: fontDesigner))
//            vc.modalPresentationStyle = .popover
//            return vc
//        }()
//        lazy var  popover : UIPopoverPresentationController = {
//            let popover = vc.popoverPresentationController!
//            popover.sourceView = self
//            return popover
//        }()
        
        func changeFont(_ sender: Any?) -> Void  {
//            let range = selectedTextRange
            let selection = selectedRange
//            let beginningOfSelection = caretRect(for: (range?.start)!)
//            let endOfSelection = caretRect(for: (range?.end)!)
//            popover.sourceRect = CGRect(x: (beginningOfSelection.origin.x + endOfSelection.origin.x)/2,
//                                        y: (beginningOfSelection.origin.y + beginningOfSelection.size.height)/2,
//                                        width: 0, height: 0)
            fontDesigner.selection = selection
            fontDesigner.textView = self
            fontDesigner.isPresented = true
        }
        
        // This works in iOS 16 but never called in 15 I believe
        open override func buildMenu(with builder: UIMenuBuilder) {
            builder.remove(menu: .lookup) // Remove Lookup, Translate, Search Web
            //builder.remove(menu: .standardEdit) // Keep Cut, Copy, Paste
            //builder.remove(menu: .replace) // Keep Replace
            builder.remove(menu: .share) // Remove Share
            //builder.remove(menu: .textStyle) // Keep Format
            // Add new .textStyle actions
    
            let strikethroughAction = UIAction(title: "Strikethough") { action in
                self.toggleStrikethrough(action.sender)
            }
            
#if targetEnvironment(macCatalyst)
            let subscriptAction = UIAction(title: "Subscript", image: UIImage(systemName: "textformat.subscript")) { action in
                self.toggleSubscript(action.sender)
            }
            let superscriptAction = UIAction(title: "Superscript", image: UIImage(systemName: "textformat.superscript")) { action in
                self.toggleSuperscript(action.sender)
            }
#else
            let subscriptAction = UIAction(image: UIImage(systemName: "textformat.subscript")) { action in
                self.toggleSubscript(action.sender)
            }
            let superscriptAction = UIAction(image: UIImage(systemName: "textformat.superscript")) { action in
                self.toggleSuperscript(action.sender)
            }
            
            let fontAction = UIAction(title: "Font") { [unowned self] action in
                //let shareVC = UIActivityViewController(activityItems: items, applicationActivities: activities)
               // let vc = action.presentationSourceItem
                if #available(iOS 16.0, *) {
                    self.changeFont(action.presentationSourceItem)
                } else {
                    self.changeFont(action.sender)
                }
                
            }
            
#endif
           
            builder.replaceChildren(ofMenu: .textStyle)  { elements in
                var children = elements
#if !targetEnvironment(macCatalyst)
                children.insert(fontAction,at: 0)
                #endif
                children.append(strikethroughAction)
                children.append(subscriptAction)
                children.append(superscriptAction)
                return children
            }
            super.buildMenu(with: builder)
        }
        
        // This is needed for iOS 15
        open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if #unavailable(iOS 16.0) {
                let menuController = UIMenuController.shared
                if var menuItems = menuController.menuItems,
                   menuItems[0].title == "Bold" && menuItems.count < 6 {
                    menuItems.append(UIMenuItem(title: "Strikethrough", action: .toggleStrikethrough))
                    menuItems.append(UIMenuItem(title: "Subscript", action: .toggleSubscript))
                    menuItems.append(UIMenuItem(title: "Superscript", action: .toggleSuperscript))
                    menuController.menuItems = menuItems
                }
                // Get rid of menu item not wanted
                if action.description.contains("_share") // Share
                    || action.description.contains("_translate") // Translate
                    || action.description.contains("_define") { // Blocks Lookup
                    return false
                }
            }
            return super.canPerformAction(action, withSender: sender)
        }
        
        public func updateAttributedText(with attributedString: NSAttributedString) {
            attributedText = attributedString
            if let update = delegate?.textViewDidChange { update(self) }
        }
        
        @objc func changeFontFunc(_ sender: Any?) { self.changeFont(sender)}
        
        @objc func toggleStrikethrough(_ sender: Any?) {
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            var isAllStrikethrough = true
            attributedString.enumerateAttribute(.strikethroughStyle,
                                                in: selectedRange,
                                                options: []) { (value, range, stopFlag) in
                let strikethrough = value as? NSNumber
                if strikethrough == nil {
                    isAllStrikethrough = false
                    stopFlag.pointee = true
                }
            }
            if isAllStrikethrough {
                attributedString.removeAttribute(.strikethroughStyle, range: selectedRange)
            } else {
                attributedString.addAttribute(.strikethroughStyle, value: 1, range: selectedRange)
            }
            updateAttributedText(with: attributedString)
        }
        
        @objc override func toggleUnderline(_ sender: Any?) {
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            var isAllUnderlined = true
            attributedString.enumerateAttribute(.underlineStyle,
                                                in: selectedRange,
                                                options: []) { (value, range, stopFlag) in
                let underline = value as? NSNumber
                if  underline == nil  {
                    isAllUnderlined = false
                    stopFlag.pointee = true
                }
            }
            if isAllUnderlined {
                // Bug in iOS 15 when all selected and underlined that I can't fix as yet
                attributedString.removeAttribute(.underlineStyle, range: selectedRange)
            } else {
                attributedString.addAttribute(.underlineStyle,
                                              value: 1,
                                              range: selectedRange)
            }
            updateAttributedText(with: attributedString)
        }
        
        @objc override func toggleBoldface(_ sender: Any?) {
            toggleSymbolicTrait(sender, trait: .traitBold)
        }
        
        @objc override func toggleItalics(_ sender: Any?) {
            toggleSymbolicTrait(sender, trait: .traitItalic)
        }
        
        private func toggleSymbolicTrait(_ sender: Any?, trait: UIFontDescriptor.SymbolicTraits) {
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            var isAll = true
            attributedString.enumerateAttribute(.font, in: selectedRange,
                                                options: []) { (value, range, stopFlag) in
                let uiFont = value as? UIFont
                if let descriptor = uiFont?.fontDescriptor {
                    isAll = isAll && descriptor.symbolicTraits.intersection(trait) == trait
                    if !isAll { stopFlag.pointee = true }
                }
            }
            attributedString.enumerateAttribute(.font, in: selectedRange,
                                                options: []) {(value, range, stopFlag) in
                let uiFont = value as? UIFont
                if  let descriptor = uiFont?.fontDescriptor {
                    // Fix bug in largeTitle by setting bold weight directly
                    var weight = descriptor.symbolicTraits.intersection(.traitBold) == .traitBold ? .bold : descriptor.weight
                    weight = trait != .traitBold ? weight : (isAll ? .regular : .bold)
                    if let fontDescriptor = isAll ? descriptor.withSymbolicTraits(descriptor.symbolicTraits.subtracting(trait))
                        : descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(trait)) {
                        attributedString.addAttribute(.font, value: UIFont(descriptor: fontDescriptor.withWeight(weight),
                                                                           size: descriptor.pointSize), range: range)
                    }
                }
            }
            updateAttributedText(with: attributedString)
        }
        
        @objc func toggleSubscript(_ sender: Any?) { toggleScript(sender, sub: true) }
        
        @objc func toggleSuperscript(_ sender: Any?) { toggleScript(sender, sub: false) }
        
        private func toggleScript(_ sender: Any?, sub: Bool = false) {
            let newOffset = sub ? -0.3 : 0.4
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            var isAllScript = true
            attributedString.enumerateAttributes(in: selectedRange,
                                                 options: []) { (attributes, range, stopFlag) in
                let offset = attributes[.baselineOffset] as? CGFloat ?? 0.0
                if offset == 0.0 { //  normal
                    isAllScript = false
                } else { // its super or subscript so set to normal
                    // Enlarge font and remove baselineOffset
                    var newFont : UIFont
                    let descriptor: UIFontDescriptor
                    if let font = attributes[.font] as? UIFont {
                        descriptor = font.fontDescriptor
                        newFont = UIFont(descriptor: descriptor, size: descriptor.pointSize/0.75)
                        attributedString.removeAttribute(.baselineOffset, range: range)
                        if descriptor.symbolicTraits.intersection(.traitItalic) == .traitItalic, let font = newFont.italic() {
                            newFont = font
                        }
                    } else { newFont = UIFont.preferredFont(forTextStyle: .body) }
                    attributedString.addAttribute(.font, value: newFont, range: range)
                }
            }
            attributedString.enumerateAttributes(in: selectedRange,
                                                 options: []) {(attributes, range, stopFlag) in
                var newFont : UIFont
                let descriptor: UIFontDescriptor
                if let font = attributes[.font] as? UIFont {
                    descriptor = font.fontDescriptor
                    newFont = font
                    if !isAllScript { // everything is already normal if isAllScript
                        attributedString.addAttribute(.baselineOffset, value: newOffset*descriptor.pointSize,
                                                      range: range)
                        newFont = UIFont(descriptor: descriptor, size: 0.75*descriptor.pointSize)
                    }
                    if descriptor.symbolicTraits.intersection(.traitItalic) == .traitItalic, let font = newFont.italic() {
                        newFont = font
                    }
                } else { newFont = UIFont.preferredFont(forTextStyle: .body) }
                attributedString.addAttribute(.font, value: newFont, range: range)
            }
            updateAttributedText(with: attributedString)
        }
    }
}


fileprivate extension Selector {
    static let toggleBoldface = #selector(TextView.MyTextView.toggleBoldface(_:))
    static let toggleItalics = #selector(TextView.MyTextView.toggleItalics(_:))
    static let toggleUnderline = #selector(TextView.MyTextView.toggleUnderline(_:))
    static let toggleStrikethrough = #selector(TextView.MyTextView.toggleStrikethrough(_:))
    static let toggleSubscript = #selector(TextView.MyTextView.toggleSubscript(_:))
    static let toggleSuperscript = #selector(TextView.MyTextView.toggleSuperscript(_:))
    static let changeFont = #selector(TextView.MyTextView.changeFontFunc(_:))
}



