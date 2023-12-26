import ScrechKit
import PteroNet

@Observable
final class ScheduleVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var schedules: [ScheduleAttributes] = []
    var sheetCreateTask = false
    
    func fetchSchedules() {
        getDataListAPI(id, endpoint: .schedules) { (result: Result<ScheduleListResponse?, Error>) in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.schedules = model.map {
                            $0.attributes
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createSchedule(_ newSchedule: NewSchedule) {
        createScheduleAPI(id, newSchedule: newSchedule) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    withAnimation {
                        self.schedules.append(model)
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func executeSchedule(_ scheduleId: Int) {
        executeScheduleAPI(id, scheduleId: scheduleId) { result in
            switch result {
            case .success:
                print("Executed")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteSchedules(_ offsets: IndexSet) {
        for index in offsets {
            let id = schedules[index].id.description
            deleteSchedule(id)
        }
    }
    
    func deleteSchedule(_ uuid: String) {
        deleteDataAPI(id, itemId: uuid, endpoint: .schedules) { result in
            switch result {
            case .success:
                self.fetchSchedules()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func createScheduleTask(_ scheduleId: Int, newTask: NewScheduleTask) {
        createScheduleTaskAPI(id, scheduleId: scheduleId, newTask: newTask) { result in
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
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func deleteScheduleTask(_ scheduleId: Int, taskId: Int) {
        deleteScheduleTaskAPI(id, scheduleId: scheduleId, taskId: taskId) { result in
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
