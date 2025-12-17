import SwiftUI

struct ExtendMonthsAmountPicker: View {
    @Binding private var renewMonths: Int
    
    init(_ renewMonths: Binding<Int>) {
        _renewMonths = renewMonths
    }
    
    private let availableOptions = [1, 3, 6, 12]
    
    var body: some View {
        Picker("Extend for", selection: $renewMonths) {
            ForEach(availableOptions, id: \.self) {
                Text($0 == 1 ? "1 month" : "\($0) months")
                    .tag($0)
            }
        }
        .pickerStyle(.menu)
    }
}
