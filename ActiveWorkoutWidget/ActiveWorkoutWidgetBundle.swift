//
//  ActiveWorkoutWidgetBundle.swift
//  ActiveWorkoutWidget
//
//  Created by Matt Linder on 7/6/26.
//

import WidgetKit
import SwiftUI

@main
struct ActiveWorkoutWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActiveWorkoutWidget()
        ActiveWorkoutWidgetControl()
        ActiveWorkoutWidgetLiveActivity()
    }
}
