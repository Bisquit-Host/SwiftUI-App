import ScrechKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        PowerWidget()
        
//        SomeNewWidget()
        
        //        SystemSmallWidget()
        
        // MARK: Lock Screen Widgets
        //        AccessoryCircularWindget()
        
#if canImport(ActivityKit)
        WidgetLiveActivity()
#endif
    }
}
