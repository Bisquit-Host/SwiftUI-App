enum StatsType: String {
    case cpu,
         ram,
         ssd
}

enum ServerState: String {
    case unknown,
         starting,
         running,
         stopping,
         offline
}

enum Node: String {
    case all,
         swift,
         exodus,
         renaissance,
         invictus
}
