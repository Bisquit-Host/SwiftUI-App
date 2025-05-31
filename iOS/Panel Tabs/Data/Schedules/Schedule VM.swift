import ScrechKit
import PteroNet

@Observable
final class ScheduleVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var schedules: [ScheduleAttributes] = []
    var sheetCreateTask = false
    var sheetCreate = false
    
    func fetchSchedules() async {
        do {
            let schedules: ScheduleListResponse? = try await dataListAPI(
                id,
                endpoint: .schedules
            )
            
            if let schedules = schedules?.data.map(\.attributes) {
                self.schedules = schedules
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createSchedule(_ newSchedule: NewSchedule, onSuccess: @escaping () -> Void) {
        scheduleCreateAPI(id, newSchedule: newSchedule) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    withAnimation {
                        self.schedules.append(model)
                    }
                    
                    onSuccess()
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func executeSchedule(_ scheduleId: Int) {
        scheduleExecuteAPI(id, scheduleId: scheduleId) { result in
            switch result {
            case .success:
                print("Executed")
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func deleteSchedules(_ offsets: IndexSet) async {
        for index in offsets {
            let id = schedules[index].id.description
            await deleteSchedule(id)
        }
    }
    
    func deleteSchedule(_ uuid: String) async {
        do {
            try await dataDeleteAPI(id, itemId: uuid, endpoint: .schedules)
            await fetchSchedules()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createScheduleTask(_ scheduleId: Int, newTask: NewScheduleTask, onSuccess: @escaping () -> Void) {
        scheduleTaskCreateAPI(id, scheduleId: scheduleId, newTask: newTask) { result in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        if let index = self.schedules.firstIndex(where: {
                            $0.id == scheduleId
                        }) {
                            self.schedules[index].relationships.tasks.data.append(model)
                        }
                    }
                    
                    onSuccess()
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func deleteScheduleTask(_ scheduleId: Int, taskId: Int) {
        scheduleTaskDeleteAPI(id, scheduleId: scheduleId, taskId: taskId) { result in
            switch result {
            case .success:
                //                if let index = self.scheduleTasks.firstIndex(where: { $0.attributes.id == taskId }) {
                //                    self.scheduleTasks.remove(at: index)
                //                }
                
                if let scheduleIndex = self.schedules.firstIndex(where: {
                    $0.id == scheduleId
                }) {
                    if let taskIndex = self.schedules[scheduleIndex].relationships.tasks.data.firstIndex(where: { $0.attributes.id == taskId }) {
                        self.schedules[scheduleIndex].relationships.tasks.data.remove(at: taskIndex)
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
