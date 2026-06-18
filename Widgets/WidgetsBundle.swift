import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        BillingBalanceWidget()
        
        PowerWidget()
        
        ResourcesWidget()
        
        //        SystemSmallWidget()
        
        // MARK: Lock Screen Widgets
        //        AccessoryCircularWidget()
        
#if canImport(ActivityKit)
        WidgetLiveActivity()
#endif
    }
}
