//
//  CustomThemeView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 03/07/24.
//

import SwiftUI

struct CustomThemeView: View {
    @ObservedObject var global: Global
    
    @State private var lRed: Double
    @State private var lGreen: Double
    @State private var lBlue: Double
    
    @State private var dRed: Double
    @State private var dGreen: Double
    @State private var dBlue: Double
    
    @State private var lightMode = true
    
    var displayColor: Color {
        if lightMode {
            Color(red: lRed, green: lGreen, blue: lBlue)
        } else {
            Color(red: dRed, green: dGreen, blue: dBlue)
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(displayColor)
                
                PostView(global, post: .example, author: .example, path: .constant(NavigationPath()))
                    .disabled(true)
                    .padding()
                
            } // end of zstack
            .frame(height: 200)
            .padding(.bottom)
            
            Picker("", selection: $lightMode) {
                Text("Light").tag(true)
                Text("Dark").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()
            
            HStack {
                Text("Red")
                Slider(value: lightMode ? $lRed : $dRed, in: 0...1)
            }
            .padding()
            
            HStack {
                Text("Green")
                Slider(value: lightMode ? $lGreen : $dGreen, in: 0...1)
            }
            .padding()
            
            HStack {
                Text("Blue")
                Slider(value: lightMode ? $lBlue : $dBlue, in: 0...1)
            }
            .padding()
            
            HStack {
                Button("Reset", action: resetColor).padding()
                Button("Save", action: save).padding()
            } // end of hstack
            .buttonStyle(BorderedProminentButtonStyle())
            
        } // end of vstack
        .navigationTitle("Customize Theme")
        .navigationBarTitleDisplayMode(.inline)
        
    } // end of body
    
    init(_ global: Global) {
        self.global = global
        _lRed = State(initialValue: global.customBackground["light"]?.red ?? 0)
        _lGreen = State(initialValue: global.customBackground["light"]?.green ?? 0)
        _lBlue = State(initialValue: global.customBackground["light"]?.blue ?? 0)
        _dRed = State(initialValue: global.customBackground["dark"]?.red ?? 0)
        _dGreen = State(initialValue: global.customBackground["dark"]?.green ?? 0)
        _dBlue = State(initialValue: global.customBackground["dark"]?.blue ?? 0)
    }
}

#Preview {
    CustomThemeView(Global())
}

extension CustomThemeView {
    func resetColor() {
        lRed = 0.9
        lGreen = 0.9
        lBlue = 0.9
        
        dRed = 0.1
        dGreen = 0.1
        dBlue = 0.1
        
        save()
    }
    
    func save() {
        let lightColor = CustomBackground(r: lRed, g: lGreen, b: lBlue)
        let darkColor = CustomBackground(r: dRed, g: dGreen, b: dBlue)
        
        global.customBackground["light"] = lightColor
        global.customBackground["dark"] = darkColor
    }
}
