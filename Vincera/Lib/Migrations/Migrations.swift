//
//  Migrations.swift
//  Vincera
//
//  Created by Matt Linder on 3/22/26.
//

import Foundation

func migrate_V1_to_V2() {
    let splitsV1: [V1.Split] = (try? StorageManager.read(.splitsV1)) ?? []
    // let daysV1: [Day] = (try? StorageManager.read(.daysV1)) ?? []
    let workoutsV1: [V1.Workout] = (try? StorageManager.read(.workoutsV1)) ?? []
    
    if !splitsV1.isEmpty {
        let splitsV2 = splitsV1.map({ s in
            Writers.Split(
                id: s.id,
                name: s.name,
                description: s.description,
                days: s.days.map({ d in
                    Writers.Day(
                        id: d.id,
                        name: d.name,
                        description: d.description,
                        color: d.color,
                        isRest: false,
                        wrappers: d.exercises.map({ w in
                            Writers.Wrapper(
                                id: UUID().uuidString,
                                rpe: w.first?.rpe ?? 5,
                                exercises: w.map({ e in
                                    Writers.Exercise(
                                        id: e.id,
                                        listId: e.listId,
                                        sets: e.sets.map({ s in
                                            Writers.Set(
                                                id: s.id,
                                                valueOne: s.valueOne ?? 0,
                                                valueTwo: s.valueTwo ?? 0,
                                                type: s.type
                                            )
                                        })
                                    )
                                })
                            )
                        })
                    )
                })
            )
        })
        
        try? StorageManager.write(.splitsV2, splitsV2)
        try? StorageManager.write(.splitsV1, [V1.Split]())
        try? StorageManager.write(.daysV1, [V1.Day]())
    }
    
    if !workoutsV1.isEmpty {
        let completedWorkoutsV2 = workoutsV1.map({ w in
            Writers.CompletedWorkout(
                id: w.id,
                dayId: w.dayId,
                name: w.name,
                notes: "",
                color: w.color,
                startedAt: w.start,
                endedAt: w.end ?? w.start,
                wrappers: w.exercises.map({ w in
                    Writers.Wrapper(
                        id: UUID().uuidString,
                        rpe: w.first?.rpe ?? 5,
                        exercises: w.map({ e in
                            Writers.Exercise(
                                id: e.id,
                                listId: e.listId,
                                sets: e.sets.map({ s in
                                    Writers.Set(
                                        id: s.id,
                                        valueOne: s.valueOne ?? 0,
                                        valueTwo: s.valueTwo ?? 0,
                                        type: s.type
                                    )
                                })
                            )
                        })
                    )
                })
            )
        })
        
        try? StorageManager.write(.completedWorkoutsV2, completedWorkoutsV2)
        try? StorageManager.write(.workoutsV1, [V1.Workout]())
    }
}
