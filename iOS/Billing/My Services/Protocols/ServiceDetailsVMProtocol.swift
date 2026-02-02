import Foundation

protocol ServiceDetailsVMProtocol: ServiceBillingVMProtocol {
    var changeablePackages: [ChangeablePackage] { get }
    var serviceId: Int? { get }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async
}
