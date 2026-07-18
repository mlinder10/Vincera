//
//  ActiveWorkoutWidgetLiveActivity.swift
//  ActiveWorkoutWidget
//
//  Created by Matt Linder on 7/6/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ActiveWorkoutWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var completedSets: Int
        var totalSets: Int
    }

    var name: String
    var color: String
}

struct ActiveWorkoutWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActiveWorkoutWidgetAttributes.self) { context in
            let name = context.attributes.name
            let colorString = context.attributes.color
            let color = Color.fromHex(colorString)
            
            VStack {
                HStack(alignment: .bottom) {
                    DayIcon(name: name, color: colorString)
                    VStack(alignment: .leading) {
                        Text(name)
                    }
                    
                    Spacer()
                    
                    Text("\(context.state.completedSets) / \(context.state.totalSets) sets")
                        .fontWeight(.semibold)
                }
                ProgressView(value: Double(context.state.completedSets) / Double(context.state.totalSets))
            }
            .padding()
            .activityBackgroundTint(color)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            let name = context.attributes.name
            let colorString = context.attributes.color
            let color = Color.fromHex(colorString)
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DayIcon(name: name, color: colorString)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(context.state.completedSets) / \(context.state.totalSets) sets")
                                .fontWeight(.semibold)
                        }
                        ProgressView(value: Double(context.state.completedSets) / Double(context.state.totalSets))
                    }
                }
            } compactLeading: {
                DayIcon(
                    name: name,
                    color: colorString,
                    size: 36
                )
            } compactTrailing: {
                Text(name).foregroundStyle(color)
            } minimal: {
                DayIcon(name: name, color: colorString)
            }
            .widgetURL(URL(string: "vincera://"))
            .keylineTint(color)
        }
    }
}

extension ActiveWorkoutWidgetAttributes {
    fileprivate static var preview: ActiveWorkoutWidgetAttributes {
        ActiveWorkoutWidgetAttributes(
            name: "Push",
            color: "#ff0000"
        )
    }
}

extension ActiveWorkoutWidgetAttributes.ContentState {
    fileprivate static var halfDone: ActiveWorkoutWidgetAttributes.ContentState {
        ActiveWorkoutWidgetAttributes.ContentState(
            completedSets: 5,
            totalSets: 10
        )
     }
}

#Preview(
    "Notification",
//    as: .dynamicIsland(.expanded),
    as: .content,
    using: ActiveWorkoutWidgetAttributes.preview
) {
   ActiveWorkoutWidgetLiveActivity()
} contentStates: {
    ActiveWorkoutWidgetAttributes.ContentState.halfDone
}
