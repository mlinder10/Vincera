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
    
    func unit(_ unit: String) -> some View {
        self.overlay {
            HStack {
                Spacer()
                Text(unit)
            }
        }
    }
    
    private func format(_ num: Double?) -> String {
        return num?.formatted().split(separator: ",").joined() ?? ""
    }
    
    private func checkValidAndUpdate(_ new: String) {
        if new.isEmpty { num = nil; return }
        if isValid, let value = Double(new) { num = value }
    }
}

protocol Number: Equatable {
    init?(_: String)
    
    func formatted() -> String
}

extension Int: Number {}
extension Double: Number {}

struct UnboundNumberField<T: Number>: View {
    @State private var selection: TextSelection?
    @FocusState private var isFocused: Bool
    @State private var text: String = ""
    @Binding var num: T?
    let title: String
    let validate: Bool
    var isValid: Bool { text.isValidNumeric() && (!validate || !text.isEmpty) }
    var width: CGFloat = 80
    var height: CGFloat = 32
    
    init(_ title: String, num: Binding<T?>, validate: Bool = false) {
        self._num = num
        self.title = title
        self.validate = validate
    }
    
    var body: some View {
        TextField(title, text: $text, selection: $selection)
            .keyboardType(.decimalPad)
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
    
    func unit(_ unit: String) -> some View {
        self.overlay(alignment: .trailing) {
            Text(unit)
                .font(.caption.bold())
                .padding(.trailing, 8)
        }
    }
    
    private func format(_ num: T?) -> String {
        return num?.formatted().split(separator: ",").joined() ?? ""
    }
    
    private func checkValidAndUpdate(_ new: String) {
        if new.isEmpty { num = nil; return }
        if isValid, let value = T(new) { num = value }
    }
}

#Preview {
    @Previewable @State var t: Int? = 0
    UnboundNumberField("", num: $t, validate: false)
}
