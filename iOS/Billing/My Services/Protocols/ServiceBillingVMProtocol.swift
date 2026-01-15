import Foundation

protocol ServiceBillingVMProtocol: AnyObject, Observable {
    var service: BillingServiceDetails? { get }
    var isPerformingAction: Bool { get set }
    var topupAlertContext: TopupAlertContext? { get set }
    
    func changeAutorenew(_ enabled: Bool, serviceId: Int) async
    func renew(months: Int, serviceId: Int) async -> ServiceRenewalResponse?
}
