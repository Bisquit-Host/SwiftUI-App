import CloudKit

struct Plan: Hashable {
    var recordId: CKRecord.ID?
    let name, type, url: String
    let cpu, ram, disk, price_euro, price_rub, price_usd: Double
    
    init(recordId: CKRecord.ID? = nil,
         _ name: String,
         type: String,
         url: String,
         cpu: Double,
         ram: Double,
         disk: Double,
         price_euro: Double,
         price_rub: Double,
         price_usd: Double
    ) {
        self.recordId = recordId
        self.name = name
        self.type = type
        self.url = url
        self.cpu = cpu
        self.ram = ram
        self.disk = disk
        self.price_euro = price_euro
        self.price_rub = price_rub
        self.price_usd = price_usd
    }
}

enum PlanRecordKeys: String {
    case type = "Plan"
}

extension Plan {
    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let type = record["type"] as? String,
              let url = record["url"] as? String,
              let cpu = record["cpu"] as? Double,
              let ram = record["ram"] as? Double,
              let disk = record["disk"] as? Double,
              let price_euro = record["price_euro"] as? Double,
              let price_rub = record["price_rub"] as? Double,
              let price_usd = record["price_usd"] as? Double else {
            return nil
        }
        
        self.init(recordId: record.recordID,
                  name,
                  type: type,
                  url: url,
                  cpu: cpu,
                  ram: ram,
                  disk: disk,
                  price_euro: price_euro,
                  price_rub: price_rub,
                  price_usd: price_usd
        )
    }
}
