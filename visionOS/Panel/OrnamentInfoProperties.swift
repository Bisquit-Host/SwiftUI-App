import SwiftUI

final class OrnamentProperty: ObservableObject {
    @AppStorage("ornament_name")      var name = false
    @AppStorage("ornament_id")        var serverId = false
    @AppStorage("ornament_status")    var status = false
    @AppStorage("ornament_uptime")    var uptime = false
    @AppStorage("ornament_cpu")       var cpu = false
    @AppStorage("ornament_ram")       var ram = false
    @AppStorage("ornament_ip")        var ip = false
    @AppStorage("ornament_node")      var node = false
    @AppStorage("ornament_backups")   var backups = false
    @AppStorage("ornament_databases") var databases = false
    @AppStorage("ornament_schedules") var schedules = false
    @AppStorage("ornament_users")     var users = false
}
