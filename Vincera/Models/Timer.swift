//
//  Timer.swift
//  Vincera
//
//  Created by Matt Linder on 1/2/25.
//

import AVFoundation
import AudioToolbox
import UserNotifications

private nonisolated let NOTIFICATION_IDENTIFIER = "com.vincera.timer"

struct TimerData {
    var show = false
    var lastStart: Date? = nil
    var prevDuration: Int = 60
    var duration: Int = 60
    var initialDuration: Int = 60
    var isPaused = true
    var publisher = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    private var vibrationTimer: Timer?
    
    mutating func togglePause() {
        isPaused.toggle()
        prevDuration = duration
        lastStart = isPaused ? nil : Date.now
        if isPaused { cancelNotification() }
        else { scheduleNotification() }
    }
    
    mutating func reset() {
        duration = initialDuration
        prevDuration = initialDuration
        isPaused = true
        lastStart = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    func getPercentage() -> Double {
        return Double(duration) / Double(initialDuration)
    }
    
    mutating func handleChange(_: Int, _ new: Int) {
        duration = new
        prevDuration = new
        isPaused = true
        lastStart = nil
    }
    
    mutating func handleCount(_: Any) {
        guard let lastStart, !isPaused else { return }
        let elapsed = Int(Date().timeIntervalSince(lastStart))
        duration = elapsed > prevDuration ? 0 : prevDuration - elapsed
        if duration == 0 { handleZero() }
    }
    
    private mutating func handleZero() {
        isPaused = true
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
        
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer Done!"
        content.body = "Time to get back to your workout!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alarm.wav"))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(duration), repeats: false)
        let request = UNNotificationRequest(identifier: NOTIFICATION_IDENTIFIER, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NOTIFICATION_IDENTIFIER])
    }
}
