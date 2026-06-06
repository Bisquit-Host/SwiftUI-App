import Foundation

@Observable
final class NewOrderVM {
    var months = 1
    var osCategories: [CloudServiceOSCategory] = []
    var nests: [BillingHostingNest] = []
    var selectedOSId = 0
    var selectedNestId = 0
    var selectedEggId = 0
    var isLoadingOptions = false
    var isOrdering = false
}
