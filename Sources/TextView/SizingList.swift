//
//  SizingList.swift
//  
//
//  Created by Joseph Levy on 8/7/23.
//

import SwiftUI
import ViewExtractor
import Utilities

fileprivate let backgroundColor = Color(uiColor: .systemGray6)

struct SizingList<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading) { content }
            .padding(.bottom).background(backgroundColor).fixedSize()
    }
}

struct SizingSubList<Content: View>: View {
    @ViewBuilder let content: Content
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    var body: some View {
        Extract(content) { views in
            let lastID = views.last?.id
            VStack(alignment: .leading, spacing: 0) {
                ForEach(views) { view in
                    VStack(alignment: .leading, spacing: 0) {
                        view.padding(.horizontal).frame(minHeight: minRowHeight )
                        if view.id != lastID { Divider().padding(.leading) }
                    }
                }.lineSpacing(0)
            }
        }
    }
}

struct SizingSection<Content: View> : View {
    internal init(_ text: String? = nil, @ViewBuilder content: () -> Content) {
        self.text = text
        self.content = content()
    }
    
    let text: String?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(height: 0).padding(.vertical)
            if let text {  Text(text)
                    .font(.footnote)
                    .textCase(.uppercase)
                    .foregroundColor(.gray)
                    .padding(.leading).padding(.leading).padding(.bottom, 6)
                    .background(backgroundColor)
            }
            SizingSubList {content}
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
        }.background(backgroundColor)
    }
}

