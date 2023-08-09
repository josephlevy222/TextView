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
    @Published public var fontSize: CGFloat = 16
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
                
            }
            .store(in: &subscriptions)
        
        $fontSize
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updatePreviewText()
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
