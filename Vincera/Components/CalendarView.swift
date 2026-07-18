//
//  CalendarView.swift
//  Vincera
//
//  Created by Matt Linder on 3/25/26.
//

import SwiftUI

struct History {
    enum Day: String, CaseIterable, Identifiable {
        var id: Self { self }
        case Sun, Mon, Tue, Wed, Thu, Fri, Sat
    }
    
    enum Month: String, CaseIterable, Identifiable {
        var id: Self { self }
        case Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
        
        var intValue: Int { Self.allCases.firstIndex(of: self)! + 1 }
    }
    
    static let MONTH_DAY_COUNT: [Month: Int] = [
        .Jan: 31, .Feb: 28, .Mar: 31, .Apr: 30, .May: 31, .Jun: 30,
        .Jul: 31, .Aug: 31, .Sep: 30, .Oct: 31, .Nov: 30, .Dec: 31
    ]
    
    static let START_YEAR = 2024
    static let CURRENT_YEAR = Calendar.current.component(.year, from: Date())
    
    static var yearLoop: ClosedRange<Int> { START_YEAR...CURRENT_YEAR }
    
    static let strategy = Date.ParseStrategy(
        format: "\\(year: .padded(4))-\\(month: .twoDigits)-\\(day: .twoDigits)",
        locale: Locale(identifier: "en_US"), // Set locale explicitly for consistency
        timeZone: TimeZone(abbreviation: "UTC")! // Set time zone explicitly
    )
    
    static func getDayCount(for month: Month, of year: Int) -> Int {
        if month == .Feb && year % 4 == 0 { return 29 }
        return MONTH_DAY_COUNT[month]!
    }
    
    static func getDayOffset(for month: Month, of year: Int) -> Int {
        var offset = 1 // 2026 starts on a Thursday
        for y in START_YEAR..<year {
            offset += y % 4 == 0 ? 2 : 1 // Normal year starts one weekday later, leap year is two
        }
        for m in 0..<Month.allCases.firstIndex(of: month)! {
            offset += getDayCount(for: Month.allCases[m], of: year)
        }
        return offset % 7
    }
}

extension Date {
    // day, month, year
    func getComponents() -> CalendarComponents {
        let c = Calendar.current
        return CalendarComponents(
            day: c.component(.day, from: self),
            month: c.component(.month, from: self),
            year: c.component(.year, from: self)
        )
    }
}

struct CalendarComponents: Hashable {
    let day: Int
    let month: Int
    let year: Int
    
    var isToday: Bool { Date().getComponents() == self }
    
    func equals(_ day: Int, _ month: Int, _ year: Int) -> Bool {
        return self.day == day && self.month == month && self.year == year
    }
    
    static func == (lhs: CalendarComponents, rhs: CalendarComponents) -> Bool {
        lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
    
    static func < (lhs: CalendarComponents, rhs: CalendarComponents) -> Bool {
        lhs.year != rhs.year ?
            lhs.year < rhs.year :
            lhs.month != rhs.month ?
                lhs.month < rhs.month :
                lhs.day < rhs.day
    }
    
    static func > (lhs: CalendarComponents, rhs: CalendarComponents) -> Bool {
        lhs.year != rhs.year ?
            lhs.year > rhs.year :
            lhs.month != rhs.month ?
                lhs.month > rhs.month :
                lhs.day > rhs.day
    }
}

struct CalendarView<Content: View>: View {
    @Binding var date: Date
    @State private var components: CalendarComponents
    @State private var month: History.Month
    @ViewBuilder var dayView: (CalendarComponents) -> Content
    
    init(date: Binding<Date>, dayView: @escaping (CalendarComponents) -> Content) {
        self._date = date
        let components = date.wrappedValue.getComponents()
        self.components = components
        self.month = History.Month.allCases[components.month-1]
        self.dayView = dayView
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("",systemImage: "chevron.left", action: prevMonth)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glassProminent)
                Spacer()
                Text("\(month.rawValue) \(String(components.year))")
                    .fontWeight(.semibold)
                Spacer()
                Button("", systemImage: "chevron.right", action: nextMonth)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glassProminent)
            }
            CalendarGrid(
                month: month,
                year: components.year,
                dayView: dayView
            )
        }
        .task(id: date) {
            self.components = date.getComponents()
            self.month = History.Month.allCases[components.month-1]
        }
    }
    
    private func prevMonth() {
        if components.month == 1 && components.year == History.START_YEAR {
            Haptics.notify(.warning)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let newMonth = components.month == 1 ? 12 : components.month - 1
        let newYear = newMonth == 12 ? components.year - 1 : components.year
        let strDate = "\(newYear)-\(newMonth < 10 ? "0" : "")\(newMonth)-01"
        
        guard let newDate = formatter.date(from: strDate) else {
            Haptics.notify(.warning)
            return
        }
        date = newDate
    }
    
    private func nextMonth() {
        let today = Date().getComponents()
        if components.month == today.month && components.year == today.year {
            Haptics.notify(.warning)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let newMonth = components.month == 12 ? 1 : components.month + 1
        let newYear = newMonth == 1 ? components.year + 1 : components.year
        let strDate = "\(newYear)-\(newMonth < 10 ? "0" : "")\(newMonth)-01"
        
        guard let newDate = formatter.date(from: strDate) else {
            Haptics.notify(.warning)
            return
        }
        date = newDate
    }
}

private let ROW_HEIGHT: CGFloat = 24

struct CalendarGrid<T: View>: View {
    let month: History.Month
    let year: Int
    let dayView: (CalendarComponents) -> T
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            HStack {
                ForEach(History.Day.allCases) { day in
                    Text(day.rawValue.prefix(1))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns) {
                let offset = History.getDayOffset(for: month, of: year)
                let daysInMonth = History.getDayCount(for: month, of: year)
                
                ForEach(0..<offset, id: \.self) { offset in
                    Color.clear
                        .frame(height: ROW_HEIGHT)
                        .id("offset-\(year)-\(month.rawValue)-\(offset)")
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    dayView(CalendarComponents(day: day, month: month.intValue, year: year))
                        .frame(height: ROW_HEIGHT)
                        .frame(maxWidth: .infinity)
                        .id("day-\(year)-\(month.intValue)-\(day)")
                }
            }
        }
    }
}

struct MonthHeader: View {
    let month: History.Month
    let year: Int
    
    var body: some View {
        HStack {
            Text("\(month.rawValue) \(String(year))")
                .font(.headline)
                .padding(.vertical, 8)
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    @Previewable @State var date = Date()
    ScrollView {
        CalendarView(date: $date) { data in
            Text(String(data.day))
                .font(.caption)
                .frame(width: ROW_HEIGHT, height: ROW_HEIGHT)
                .background(
                    !MOCK_COMPLETED_WORKOUTS.isEmpty
                    ? Circle().fill(.accent.opacity(0.4))
                    : data.isToday
                    ? Circle().fill(.blue.opacity(0.3))
                    : nil
                )
        }
        .padding(.horizontal)
    }
    .navigationTitle("History")
    .navigationBarTitleDisplayMode(.inline)
    .mockNavigation
    .mockEnvironment
}
