//
//  NumberKeyboard.swift
//  LiftLogsPro
//
//  Created by Matt Linder on 7/6/24.
//

import SwiftUI

struct NumberField: View {
    let title: String
    let validate: Bool
    @Binding var num: Double?
    @State private var text: String = ""
    var isValid: Bool { text.isValidNumeric() && (!validate || !text.isEmpty) }
    
    init(_ title: String, num: Binding<Double?>, validate: Bool) {
        self.title = title
        self._num = num
        self.validate = validate
    }
    
    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .contentShape(Rectangle())
            .frame(width: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
                    .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
            )
            .onAppear { text = format(num) }
            .onChange(of: text) { checkValidAndUpdate($1) }
            .onChange(of: num) { text = format($1) }
    }
    
    func format(_ double: Double?) -> String {
        return double?.formatted().split(separator: ",").joined() ?? ""
    }
    
    private func checkValidAndUpdate(_ new: String) {
        if new.isEmpty { num = nil; return }
        if isValid, let value = Double(new) { num = value }
    }
}

