//
//  UIFontPickerRepresentable.swift
//
//
//  Created by Andre Albach on 14.02.22.
//

import SwiftUI
/// From Apple Developer Documentation
//func showFontPicker(_ sender: Any) {
//    let fontConfig = UIFontPickerViewController.Configuration()
//    fontConfig.includeFaces = true
//    let fontPicker = UIFontPickerViewController(configuration: fontConfig)
//    fontPicker.delegate = self
//    self.present(fontPicker, animated: true, completion: nil)
//}
/// A representable to display a `UIFont` picker
struct SystemFontList : View {
    let fontDesigner: FontDesigner
    var body: some View {
        VStack(alignment: .leading) {
            Text("System Font (SF)").padding(.leading).padding(.top)
                .onTapGesture {
                    fontDesigner.fontDescriptor = UIFont.systemFont(ofSize: fontDesigner.fontSize).fontDescriptor
                    fontDesigner.isFontPickerActive = false
                }
            FontListView(fontDesigner: fontDesigner)
        }
    }
}

struct FontListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIFontPickerViewController
    
    /// Reference to the underlaying view model
    let fontDesigner: FontDesigner
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true
        let vc = UIFontPickerViewController(configuration: fontConfig)
        vc.delegate = context.coordinator
        vc.selectedFontDescriptor = fontDesigner.fontDescriptor
        //    vc.present(vc, animated: true, completion: nil) // to present as modal
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIFontPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(fontDesigner: fontDesigner)
    }
    
    /// Coordinator class to get callbacks when a font is picked
    final class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        
        /// Reference to the underlaying view model
        private let fontDesigner: FontDesigner
        
        /// Initialisation
        /// - Parameter fontDesigner: The underlaying view model
        init(fontDesigner: FontDesigner) {
            self.fontDesigner = fontDesigner
        }
        
        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            fontDesigner.fontDescriptor = viewController.selectedFontDescriptor
            fontDesigner.isFontPickerActive = false
        }
    }
}


// MARK: - Preview

struct UIFontPickerRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        SystemFontList(fontDesigner: FontDesigner.shared)
    }
}
