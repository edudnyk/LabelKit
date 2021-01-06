//
//  ContentView.swift
//  LabelKit - Example SwiftUI
//
//  Copyright (c) 2019-2021 Eugene Dudnyk
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the LabelKit project.
//

import LabelKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var textGenerator: TextGenerator
    @State var swiftUITextToggled = false
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack {
                            if swiftUITextToggled {
                                Text.applyRandomShadow(to: textGenerator.text)
                                    .animation(.easeInOut(duration: 3))
                            } else {
                                LabelView(attributedText: textGenerator.attributedString)
                                    .animation(.easeInOut(duration: 3))
                            }
                        }
                        .background(Color(.white))
                        .frame(minHeight: UIScreen.main.bounds.height)
                    }
                    Button(swiftUITextToggled ? "Animate NSAttributedString with LabelKit" : "Animate Text with SwiftUI") {
                        swiftUITextToggled.toggle()
                    }
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    .background(Color(.red))
                }.background(Color(.white))
                
                Text(swiftUITextToggled ? "Animating Text with SwiftUI" : "Animating NSAttributedString with LabelKit")
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .layoutPriority(1)
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom)
            .background(Color(.systemGray5))
            .frame(maxWidth: .infinity)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TextGenerator())
    }
}
