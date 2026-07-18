//
//  DayIcon.swift
//  Vincera
//
//  Created by Matt Linder on 7/9/26.
//

import SwiftUI

struct DayIcon: View {
    let name: String
    let color: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.fromHex(color).opacity(0.2))
                .frame(width: 44, height: 44)
            
            Text(name.prefix(1))
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.fromHex(color))
        }
    }
}
