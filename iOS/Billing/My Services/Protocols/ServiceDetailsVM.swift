import Foundation

protocol ServiceDetailsVM: AnyObject, Observable {
    init()
    
    var isLoading: Bool { get }
    
    func load(_ serviceId: Int) async
    func rename(_ newName: String, serviceId: Int) async
}
