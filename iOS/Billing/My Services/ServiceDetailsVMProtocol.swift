import Foundation

protocol ServiceDetailsVMProtocol: AnyObject, Observable {
    var changeablePackages: [ChangeablePackage] { get }
    var isPerformingAction: Bool { get }
    var serviceId: Int? { get }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async
}
