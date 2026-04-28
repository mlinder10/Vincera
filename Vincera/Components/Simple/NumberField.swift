//
//  NumberKeyboard.swift
//  LiftLogsPro
//
//  Created by Matt Linder on 7/6/24.
//

import SwiftUI

struct NumberField: View {
    @State private var selection: TextSelection?
    @FocusState private var isFocused: Bool
    @State private var text: String = ""
    @Binding var num: Double?
    let title: String
    let validate: Bool
    var isValid: Bool { text.isValidNumeric() && (!validate || !text.isEmpty) }
    
    init(_ title: String, num: Binding<Double?>, validate: Bool) {
        self._num = num
        self.title = title
        self.validate = validate
    }
    
    var body: some View {
        TextField(title, text: $text, selection: $selection)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .frame(width: 80, height: 32)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
                    .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
            )
            .onAppear { text = format(num) }
            .onChange(of: text) { checkValidAndUpdate($1) }
            .onChange(of: num) { text = format($1) }
            .focused($isFocused)
            .onChange(of: isFocused) { oldValue, newValue in
                if isFocused {
                    selection = .init(range: text.startIndex..<text.endIndex)
                }
            }
    }
    
    func format(_ double: Double?) -> String {
        return double?.formatted().split(separator: ",").joined() ?? ""
    }
    
    private func checkValidAndUpdate(_ new: String) {
        if new.isEmpty { num = nil; return }
        if isValid, let value = Double(new) { num = value }
    }
}
