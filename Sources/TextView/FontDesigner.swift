//
//  FontDesigner.swift
//
//
//  Created by Andre Albach on 14.02.22.
//

import Combine
import SwiftUI

/// The view model for `FontDesignerView`.
final public class FontDesigner: ObservableObject {
    
    /// The font and background color
    @Published public var fontColor: CGColor = UIColor.label.cgColor
    @Published public var backgroundColor: CGColor = UIColor.label.cgColor
    /// The font size
    @Published public var fontSize: CGFloat = 17
    /// The font descriptor, if available
    @Published public var fontDescriptor: UIFontDescriptor? = nil
    
    
    // MARK: - UI controlling
    
    /// The font name string, displayed by the font picker
    @Published private(set) var displayedFontName: String = NSLocalizedString("Font", comment: "")
    /// The preview text to preview how the font configuration looks like
    @Published private(set) var previewText: AttributedString = AttributedString("Some preview text")
    
    /// Indicator, if the font picker is currently visible
    @Published public var isFontPickerActive: Bool = false
    @Published public var isPresented: Bool = false
    var textView : TextView.MyTextView?
    public var selection = NSRange()
    // MARK: - Other
    
    /// A store for all the subscriptions. So we can react on the changes
    private var subscriptions: Set<AnyCancellable> = []
    
    /// Initialisation
    public init() {
        $fontDescriptor
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                self?.updatePreviewText()
                guard let fontName = newValue?.postscriptName else { return }
                  
                self?.displayedFontName = "\(fontName)" 
                self?.updatePreviewText()
                self?.updateTextView()
                
            }
            .store(in: &subscriptions)
        
        $fontSize
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePreviewText()
                self?.updateTextView()
            }
            .store(in: &subscriptions)
        
        $fontColor
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePreviewText()
                self?.updateTextView()
            }
            .store(in: &subscriptions)
        
        $backgroundColor
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePreviewText()
                self?.updateTextView()
            }
            .store(in: &subscriptions)
        
        $isFontPickerActive
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink {  _ in
            }
            .store(in: &subscriptions)
    }
    
    /// This function will update the preview text and use the latest values
    private func updatePreviewText() {
        var text = AttributedString(displayedFontName)
        if let fontDescriptor = fontDescriptor {
            text.uiKit.font = UIFont(descriptor: fontDescriptor, size: fontSize)
            
        } else {
            text.uiKit.font = UIFont.systemFont(ofSize: fontSize)
        }
        previewText = text
    }
    
    private func updateTextView() {
        guard let textView else {return}
        let text = NSMutableAttributedString(attributedString: textView.attributedText)
        var range = selection
        let attributes = text.attributes(at: 0, effectiveRange: &range)
        // Take care of font and size
        var newFont : UIFont
        let descriptor: UIFontDescriptor
        let font = attributes[.font] as? UIFont
        descriptor = fontDescriptor ?? font?.fontDescriptor ?? UIFont.preferredFont(forTextStyle: .body).fontDescriptor
        newFont = UIFont(descriptor: descriptor, size: fontSize)
        text.removeAttribute(.font, range: selection)
        if descriptor.symbolicTraits.intersection(.traitItalic) == .traitItalic, let font = newFont.italic() {
            newFont = UIFont(descriptor: font.fontDescriptor, size: fontSize)
        }
        text.addAttribute(.font, value: newFont, range: selection)
        // Take care of background color
        text.removeAttribute(.backgroundColor, range: selection)
        text.addAttribute(.backgroundColor, value: backgroundColor, range: selection)
        // Take care of foreground color
        text.removeAttribute(.foregroundColor, range: selection)
        text.addAttribute(.foregroundColor, value: fontColor, range: selection)
        textView.attributedText = text
    }
}


// MARK: - Preview data

extension FontDesigner {
    /// Some preview data
    static public let shared: FontDesigner = {
        let designer = FontDesigner()
        designer.fontSize = 17
        designer.fontColor = UIColor.black.cgColor
        designer.backgroundColor = UIColor.white.cgColor
        designer.fontDescriptor = UIFont.systemFont(ofSize: designer.fontSize).fontDescriptor
        
        return designer
    }()
    
}
