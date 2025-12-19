import SwiftUI

struct HostingPlanListServicePicker: View {
    @Binding private var category: BillingHostingCategory
    
    init(_ category: Binding<BillingHostingCategory>) {
        _category = category
    }
    
    var body: some View {
        Picker("Service", selection: $category) {
            ForEach(BillingHostingCategory.allCases) {
                Text($0.title)
                    .tag($0)
            }
        }
        .pickerStyle(.segmented)
        .padding([.bottom, .horizontal])
    }
}

//#Preview {
//    HostingPlanListServicePicker()
//        .darkSchemePreferred()
//}
