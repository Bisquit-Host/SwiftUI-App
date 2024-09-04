import ScrechKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        PowerWidget()
        
        //        SystemSmallWidget()
        
        // MARK: Lock Screen Widgets
        //        AccessoryCircularWindget()
        
#if canImport(ActivityKit)
        WidgetLiveActivity()
#endif
    }
}
