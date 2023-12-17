#if canImport(ActivityKit)
import SwiftUI
import WidgetKit
import ActivityKit

struct WidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties
        var latestMessage: String
    }
    
    // Non-changing properties
    var id: String
    var name: String
    var node: String
}

struct WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetsAttributes.self) { context in
            let message = convertAnsiToAttributedString(context.state.latestMessage)
            
            // Lock screen/banner UI
            VStack {
                HStack {
                    Text(context.attributes.name)
                        .bold()
                        .rounded()
                    
                    Spacer()
                    
                    Text(context.attributes.id)
                        .footnote()
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Text(message)
                    .footnote()
                    .padding(.horizontal, 10)
            }
            .activityBackgroundTint(.orange)
            .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                let message = convertAnsiToAttributedString(context.state.latestMessage)
                
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.name)
                        .bold()
                        .caption2()
                        .rounded()
                        .lineLimit(1)
                        .padding(.leading, 5)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.id)
                        .caption2()
                        .rounded()
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 5)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text(message)
                        .footnote()
                }
            } compactLeading: {
                Image(systemName: "externaldrive")
                    .bold()
                    .foregroundStyle(.orange)
                
            } compactTrailing: {
                Text(context.attributes.name.prefix(2))
                
            } minimal: {
                Image(systemName: "externaldrive")
                    .bold()
                    .foregroundStyle(.orange)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(.orange)
        }
    }
}

fileprivate extension WidgetsAttributes {
    static var preview: WidgetsAttributes {
        .init(id: "12345678", name: "Preview Server", node: "Swift")
    }
}

fileprivate extension WidgetsAttributes.ContentState {
    static var smiley: WidgetsAttributes.ContentState {
        .init(latestMessage: "Some message 😀")
    }
    
    static var starEyes: WidgetsAttributes.ContentState {
        .init(latestMessage: "Some message witch is very-very long god damnit how long it is please save me")
    }
}

#Preview("Notification", as: .content, using: WidgetsAttributes.preview) {
    WidgetLiveActivity()
} contentStates: {
    WidgetsAttributes.ContentState.smiley
    WidgetsAttributes.ContentState.starEyes
}

#Preview("DI", as: .dynamicIsland(.expanded), using: WidgetsAttributes.preview) {
    WidgetLiveActivity()
} contentStates: {
    WidgetsAttributes.ContentState.smiley
    WidgetsAttributes.ContentState.starEyes
}
#endif
