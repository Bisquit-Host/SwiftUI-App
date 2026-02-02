import SwiftUI

struct MonthAmountPicker: View {
    @Binding private var months: Int
    
    init(_ months: Binding<Int>) {
        _months = months
    }
    
    private let availableOptions = [1, 3, 6, 12]
    
    var body: some View {
        Picker("Renew for", selection: $months) {
            ForEach(availableOptions, id: \.self) {
                Text("\($0) months")
                    .tag($0)
            }
        }
        .pickerStyle(.menu)
        .tint(.primary)
    }
}
