import ScrechKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        PowerWidget()
        
        ResourcesWidget()
        
        SystemSmallWidget()
        
        // MARK: Lock Screen Widgets
        //        AccessoryCircularWindget()
        
#if canImport(ActivityKit)
        WidgetLiveActivity()
#endif
    }
}
