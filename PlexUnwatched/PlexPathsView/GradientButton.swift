//
//  GradientButton.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2023-09-07.
//

import SwiftUI

struct GradientButton: View {
    var glyph: String

    var body: some View {
        ZStack {
            Image(systemName: glyph)
                .fontWeight(.medium)
            Color.clear
                .frame(width: 24, height: 24)
        }
    }
}

// #Preview {
//    GradientButton(glyph: "plus")
// }

struct GradientButton_Previews: PreviewProvider {
    static var previews: some View {
        GradientButton(glyph: "plus")
    }
}
