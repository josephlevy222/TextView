//
//  FontDesignerView.swift
//
//
//  Created by Andre Albach on 14.02.22.
//

import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool) -> some View {
        if hidden { self.hidden() } else { self }
    }
}
// A small view to pick a UIFont, set a font color and a font size.
/// There is also a preview included
public struct FontDesignerView: View {
    
    /// The view model
    @ObservedObject var fontDesigner: FontDesigner
    /// Sizing captures
    @State private var width = CGFloat(100)
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    /// The minimum font size the stepper allows
    let minimumFontSize: CGFloat = 8
    /// The maximum font size the stepper allows
    let maximumFontSize: CGFloat = 100
    
    /// The body of the view
    public var body: some View {
        SizingList {
            SizingSection("Preview") {
                Text(fontDesigner.previewText)
                    .lineLimit(1)
                    .fixedSize()
                    .foregroundColor(Color(fontDesigner.fontColor))
                    .background(Color(fontDesigner.backgroundColor))
                    .frame(width: width, height: minRowHeight*2)
            }
            
            SizingSection("Font Configuration") {
                Text(fontDesigner.displayedFontName)
                    .onTapGesture {  fontDesigner.isFontPickerActive = true
                    }
                    .popover(isPresented: $fontDesigner.isFontPickerActive) {
                        SystemFontList(fontDesigner: fontDesigner)
                    }.onChange(of: fontDesigner.fontDescriptor) { newValue in }
                
                ColorPicker("Foreground color", selection: $fontDesigner.fontColor)
                ColorPicker("Background color", selection: $fontDesigner.backgroundColor)
                    .captureWidth(in: $width)
                Stepper("Size (\(Float(fontDesigner.fontSize).formatted(.number.precision(.fractionLength(0)))))", value: $fontDesigner.fontSize, in: minimumFontSize ... maximumFontSize)
            }
        }
    }
}

// MARK: - Previews

struct FontDesignerView_Previews: PreviewProvider {
    static var previews: some View {
        Button("Set Font") { FontDesigner.shared.isPresented = true  }
            .popover(isPresented: .constant(true)) {
                FontDesignerView(fontDesigner: FontDesigner.shared)
            }
    }
}
