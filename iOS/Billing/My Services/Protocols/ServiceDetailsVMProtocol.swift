
protocol ServiceDetailsVMProtocol: ServiceBillingVMProtocol {
    var isLoading: Bool { get }
    var changeablePackages: [ChangeablePackage] { get }
    var serviceId: Int? { get }
    
    func changePackage(to packageId: Int, serviceId: Int, onSuccess: @escaping () -> Void) async
}
