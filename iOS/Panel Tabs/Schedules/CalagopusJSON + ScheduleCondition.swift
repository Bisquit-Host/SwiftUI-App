import Calagopus

extension CalagopusJSON {
    static var onlineScheduleCondition: CalagopusJSON {
        .object([
            "type": .string("or"),
            "conditions": .array([
                .object(["type": .string("server_state"), "state": .string("starting")]),
                .object(["type": .string("server_state"), "state": .string("running")])
            ])
        ])
    }
}
