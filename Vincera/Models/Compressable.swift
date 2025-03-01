//
//  Encoded.swift
//  Vincera
//
//  Created by Matt Linder on 2/24/25.
//

import Foundation

protocol Compressable {}

private let varSep = "|"
private let daySep: String = "/"
private let wrapperSep: String = "?"
private let exerciseSep: String = "~"
private let setSep: String = "`"

enum Compressing {
    // MARK: format
    // 1st char (s/d/w) determine split, day, workout
    static func compress<T: Encodable>(_ value: T) throws(VinceraError) -> String {
        let compressed = switch value {
        case is Split: "s" + compressSplit(value as! Split)
        case is Day: "d" + compressDay(value as! Day)
        case is Workout: throw .notImplemented
        default: throw .notImplemented
        }
        return compressed.data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    // MARK: split
    // <name>\001<description>\001<days> (days seperate by \002)
    private static func compressSplit(_ split: Split) -> String {
        return (
            split.name + varSep +
            split.description + varSep +
            split.days
                .map({ compressDay($0) })
                .joined(separator: daySep)
        )
    }
    
    // MARK: day
    // <name>\003<description>\003<color>\003<exercises> (wrappers seperated by \004, exercises seperated by \005)
    private static func compressDay(_ day: Day) -> String {
        return (
            day.name + varSep +
            day.description + varSep +
            day.color + varSep +
            day.exercises
                .map({
                    $0
                        .map({ compressExercise($0) })
                        .joined(separator: exerciseSep)
                })
                .joined(separator: wrapperSep)
        )
    }
    
    // MARK: workout
    // exclude for now
    
    // MARK: exercise
    // <listId>\006<unitOne>\006<unitTwo>\006<rpe>\006<sets> (sets seperated by \007)
    private static func compressExercise(_ exercise: Exercise) -> String {
        return (
            exercise.listId + varSep +
            exercise.unitOne.compressed + varSep +
            exercise.unitTwo.compressed + varSep +
            exercise.rpe.formatted() + varSep +
            exercise.sets
                .map({ compressSet($0) })
                .joined(separator: setSep)
        )
    }
    
    // MARK: sets
    // <valueOne>\008<valueTwo>\008<type>
    private static func compressSet(_ set: VinceraSet) -> String {
        return (
            (set.valueOne?.formatted() ?? "0") + varSep +
            (set.valueTwo?.formatted() ?? "0") + varSep +
            set.type.compressed
        )
    }
}

enum DecodingError: Error {
    case badString
    case badWorkout
    case badSplit
    case badDay
    case badExercise
    case badSet
}

enum Decoding {
    static func decode(_ value: String) throws(DecodingError) -> Compressable { throw .badString }
    
    private static func decodeSplit(_ value: String) throws(DecodingError) -> Split { throw .badSplit }
    
    private static func decodeDay(_ value: String) throws(DecodingError) -> Day { throw .badDay }
    
    private static func decodeExercise(_ value: String) throws(DecodingError) -> Exercise { throw .badExercise}
    
    private static func decodeSet(_ value: String) throws(DecodingError) -> VinceraSet { throw .badSet}
}
