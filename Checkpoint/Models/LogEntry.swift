import Foundation

struct LogEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let project: String
    let description: String
    let duration: TimeInterval?
    
    init(date: Date = Date(), project: String, description: String, duration: TimeInterval? = nil) {
        self.id = UUID()
        self.date = date
        self.project = project
        self.description = description
        self.duration = duration
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
    
    var formattedDuration: String {
        guard let duration = duration else { return "N/A" }
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
} 
