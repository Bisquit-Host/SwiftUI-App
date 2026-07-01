import Foundation

@Observable
final class NewOrderVM {
    var months = 1
    var osCategories: [CloudServiceOSCategory] = []
    var nests: [BillingHostingNest] = []
    var selectedOSID = 0
    var selectedNestID = 0
    var selectedEggID = 0
    var isLoadingOptions = false
    var isOrdering = false
}
