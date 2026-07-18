//
//  PlateCalculatorScreen.swift
//  Vincera
//
//  Created by Matt Linder on 6/24/26.
//

import SwiftUI

private enum Plate: Identifiable, CaseIterable, Equatable {
    var id: Self { self }
    
    case fourtyFive
    case thirtyFive
    case twentyFive
    case ten
    case five
    case twoAndAHalf
    
    var weight: Double {
        switch self {
        case .fourtyFive: 45
        case .thirtyFive: 35
        case .twentyFive: 25
        case .ten: 10
        case .five: 5
        case .twoAndAHalf: 2.5
        }
    }
    
    var height: CGFloat {
        switch self {
        case .fourtyFive: 90
        case .thirtyFive: 80
        case .twentyFive: 70
        case .ten: 55
        case .five: 45
        case .twoAndAHalf: 35
        }
    }
    
    var width: CGFloat {
        switch self {
        case .fourtyFive: 12
        case .thirtyFive: 12
        case .twentyFive: 12
        case .ten: 10
        case .five: 8
        case .twoAndAHalf: 6
        }
    }
    
    var color: Color {
        switch self {
        case .fourtyFive: .blue
        case .thirtyFive: .yellow
        case .twentyFive: .green
        case .ten: .black
        case .five: .red
        case .twoAndAHalf: .gray
        }
    }
}

private struct IdentifiablePlate: Identifiable, Equatable {
    let id = UUID()
    let type: Plate
}

struct PlateCalculatorScreen: View {
    @State private var barWeight: Double = 45
    @State private var usesBarbell = true
    @State private var plates = [IdentifiablePlate]()
    private var totalWeight: Double {
        let plateWeight = plates.reduce(0) { $0 + $1.type.weight }
        return usesBarbell ? barWeight + plateWeight * 2 : plateWeight
    }
    
    private let barWeights = [0.0, 15.0, 33.0, 45.0, 55.0, 65.0]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                weightTitle
                barbellView
                
                if !plates.isEmpty {
                    Button("Clear Plates", systemImage: "trash.fill", role: .destructive) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            plates.removeAll()
                        }
                    }
                }
                
                Divider().padding(.horizontal)
                
                barbellConfig
                plateSelection
            }
        }
    }
    
    @ViewBuilder
    private var weightTitle: some View {
        VStack(spacing: 4) {
            Text("TOTAL WEIGHT")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("\(totalWeight.formatted()) lbs")
                .font(.system(size: 48, weight: .black))
                .contentTransition(.numericText(value: totalWeight))
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var barbellView: some View {
        ZStack {
            if usesBarbell {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray)
                    .frame(height: 12)
                    .padding(.horizontal, 20)
            }
            
            // Render Plates
            HStack(spacing: 0) {
                Spacer()
                if usesBarbell {
                    HStack(spacing: 2) {
                        ForEach(plates.reversed()) { plate in
                            plateView(for: plate.type)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                    Spacer().frame(width: 100) // Center bar split gap
                }
                
                // Right Side Plates
                HStack(spacing: 2) {
                    ForEach(plates) { plate in
                        plateView(for: plate.type)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                
                Spacer()
            }
        }
        .frame(height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var barbellConfig: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Barbell Options")
            
            Card {
                VStack(spacing: 16) {
                    Toggle(isOn: $usesBarbell.animation(.spring())) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use Barbell")
                                .fontWeight(.medium)
                            Text("Calculates weights on a barbell")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if usesBarbell {
                        Picker("Bar Weight", selection: $barWeight.animation(.spring())) {
                            ForEach(barWeights, id: \.self) { weight in
                                Text("\(weight.formatted()) lbs").tag(weight)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var plateSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Add Plates")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(Plate.allCases) { plate in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if usesBarbell && plates.count < 8 || !usesBarbell && plates.count < 20 {
                                plates.append(IdentifiablePlate(type: plate))
                            } else {
                                Haptics.notify(.warning)
                            }
                        }
                    } label: {
                        Card {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(plate.color)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: plate.color.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    )
                                
                                Text("\(plate.weight.formatted()) lb")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func plateView(for plate: Plate) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(plate.color)
            .frame(width: plate.width, height: plate.height)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    PlateCalculatorScreen()
}
