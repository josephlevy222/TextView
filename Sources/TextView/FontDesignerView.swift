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
/// A small view to pick a UIFont, set a font color and a font size.
/// There is also a preview included
struct FontDesignerView: View {
    
    /// The view model
    @ObservedObject var fontDesigner: FontDesigner
    /// Sizing captures
    @State private var colorPickerSize = CGSize(width: 0, height: 0)
    @State private var textHeight = CGFloat(0)
    
    /// The minimum font size the stepper allows
    let minimumFontSize: CGFloat = 8
    /// The maximum font size the stepper allows
    let maximumFontSize: CGFloat = 100
    
    /// The body of the view
    var body: some View {
        ZStack {
            VStack(alignment: .leading) { // to size List
                Section("Preview") {
                    Text("SFUI") // Half Height
                    Text("SFUI") // Since use 2*colorPickerSize.height
                        .background( // use background to avoid extra size
                            Text(fontDesigner.previewText)
                                .lineLimit(1)
                                .captureHeight(in: $textHeight)
                        )
                }.font(.headline).padding(.top)
                
                Section("Font Configuration") {
                    Text("SFUI")
                    Text("Foreground color")
                    ColorPicker("Background color", selection: $fontDesigner.backgroundColor)
                        .fixedSize()
                        .padding(.horizontal).padding(.horizontal)
                        .captureSize(in: $colorPickerSize)
                    Text("Stepper Placeholder")
                }
                .font(.headline).padding(.top)
            }
            .frame(width: colorPickerSize.width)
            .hidden()
            
            List {
                Section("Preview") {
                    HStack(alignment: .center) {
                        Spacer()
                        Text(fontDesigner.previewText)
                            .lineLimit(1)
                            .fixedSize()
                            .foregroundColor(Color(fontDesigner.fontColor))
                            .background(Color(fontDesigner.backgroundColor))
                            .frame(height: colorPickerSize.height*2)
                        Spacer()
                    }
                }
                
                Section("Font Configuration") {
                    HStack {
                        Text(fontDesigner.displayedFontName)
                            .popover(isPresented: $fontDesigner.isFontPickerActive) {
                                SystemFontList(fontDesigner: fontDesigner)
                            }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Select Font")
                        fontDesigner.isFontPickerActive = true
                    }
                    ColorPicker("Foreground color", selection: $fontDesigner.fontColor)
                    ColorPicker("Background color", selection: $fontDesigner.backgroundColor)
                    Stepper("Size (\(Float(fontDesigner.fontSize).formatted(.number.precision(.fractionLength(0)))))", value: $fontDesigner.fontSize, in: minimumFontSize ... maximumFontSize)
                }
            }
        }
    }
}

// MARK: - Previews

struct FontDesignerView_Previews: PreviewProvider {
    static var previews: some View {
        Button("Set Font") { FontDesigner.show = true  }
            .popover(isPresented: .constant(true)) {
                FontDesignerView(fontDesigner: FontDesigner.preview)
            }
    }
}
