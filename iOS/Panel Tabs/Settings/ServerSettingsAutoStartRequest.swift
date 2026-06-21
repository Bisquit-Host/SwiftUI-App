import Calagopus

struct ServerSettingsAutoStartRequest: Encodable {
    let behavior: CalagopusServerAutoStartBehavior
}
