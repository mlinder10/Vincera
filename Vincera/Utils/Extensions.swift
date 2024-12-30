//
//  Extensions.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation
import SwiftUI

extension Array where Element: Equatable {
  mutating func toggle(_ element: Element) {
    if self.contains(where: { $0 == element }) {
      self.removeAll(where: { $0 == element })
    } else {
      self.append(element)
    }
  }
}

extension Array {
  var median: Element? {
    guard self.count > 0 else { return nil }
    return self[self.count / 2]
  }
}

private let NUMERIC_CHARS = "1234567890."

extension String {
  func isValidNumeric() -> Bool {
    return self.allSatisfy { NUMERIC_CHARS.contains($0) } && self.filter { $0 == "." }.count < 2
  }
}

extension Color {
  static func fromHex(_ hex: String) -> Color {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    var a: CGFloat = 1.0
    
    let length = hexSanitized.count
    
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return .black }
    
    if length == 6 {
      r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      b = CGFloat(rgb & 0x0000FF) / 255.0
      
    } else if length == 8 {
      r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
      g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
      b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
      a = CGFloat(rgb & 0x000000FF) / 255.0
      
    } else { return .black }
    
    return Color(red: r, green: g, blue: b, opacity: a)
  }
  
  static func random() -> Color {
    Color(red: .random(), green: .random(), blue: .random())
  }
  
  func toHex() -> String {
    let uic = UIColor(self)
    guard let components = uic.cgColor.components, components.count >= 3 else {
      return "#000000"
    }
    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    var a = Float(1.0)
    
    if components.count >= 4 {
      a = Float(components[3])
    }
    
    if a != Float(1.0) {
      return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    } else {
      return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
  }
}

extension Double {
  static func random() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
  }
}

private let IMAGE_FILE_EXT = ".jpeg"
private let IMAGE_BASE_URL = "https://vinceratraining.com/api/images/"

func fetchImage(_ filename: String?) async -> UIImage? {
  guard let filename else { return nil }
  
  let localFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/\(filename)\(IMAGE_FILE_EXT)"
  let localUrl = URL(fileURLWithPath: localFilePath) // Use fileURLWithPath instead of URL(string:)
  
  // Check if the image exists locally
  if let res = try? await URLSession.shared.data(from: localUrl) {
    if let image = UIImage(data: res.0) { return image }
  }
  
  // If the image is not found locally, try to fetch it remotely
  if let remoteUrl = URL(string: "\(IMAGE_BASE_URL)\(filename)\(IMAGE_FILE_EXT)") {
    if let res = try? await URLSession.shared.data(from: remoteUrl) {
      if let image = UIImage(data: res.0) {
        try? res.0.write(to: localUrl) // Save the image data to the local URL
        return image
      }
    }
  }
  
  return nil
}

extension Int {
  var secondFormatted: String {
    let minutes = self / 60
    let seconds = self % 60
    let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
    let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
    return "\(minutesString):\(secondsString)"
  }
}
