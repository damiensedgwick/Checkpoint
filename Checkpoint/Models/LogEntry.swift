import Foundation

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let project: String
    let description: String
    
    init(date: Date = Date(), project: String, description: String) {
        self.id = UUID()
        self.date = date
        self.project = project
        self.description = description
    }
}

// MARK: - Extensions
extension LogEntry {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var timeRemaining: TimeInterval {
        // This will be calculated by the ViewModel
        return 0
    }
} 
