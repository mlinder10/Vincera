//
//  Split.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

extension V1 {
    
    struct PremiumSplit: Identifiable {
        var id: String { productId }
        let productId: String
        let split: Writers.Split
    }
    
    @Observable
    final class Split: Codable, Identifiable, Hashable {
        var id: String
        var name: String
        var description: String
        var days: [Day]
        
        init(id: String, name: String, description: String, days: [Day]) {
            self.id = id
            self.name = name
            self.description = description
            self.days = days
        }
        
        init() {
            self.id = UUID().uuidString
            self.name = ""
            self.description = ""
            self.days = []
        }
        
        func clone() -> Split {
            return Split(
                id: UUID().uuidString,
                name: name,
                description: description,
                days: days.map { $0.clone() })
        }
        
        func cloneWithUUID() -> Split {
            return Split(
                id: id,
                name: name,
                description: description,
                days: days.map { $0.clone() })
        }
        
        func addDay() {
            days.append(Day("Day \(days.count + 1)"))
        }
        
        func isBuiltin() -> Bool {
            return id.hasPrefix(VINCERA_SPLIT_PREFIX)
        }
        
        func moveDay(from: IndexSet, to: Int) {
            days.move(fromOffsets: from, toOffset: to)
        }
        
        func deleteDay(at: IndexSet) {
            days.remove(atOffsets: at)
        }
    }
}


