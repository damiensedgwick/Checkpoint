import SwiftUI

struct TimerWindowView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var timerService = TimerService.shared
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 32) {
            // Timer Display
            VStack(spacing: 16) {
                Text("Work Timer")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color(.separatorColor), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: progress)
                    
                    // Time display
                    VStack(spacing: 4) {
                        Text(timerService.formatTime(timerService.timeRemaining))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(timerService.timeRemaining < 300 ? .red : .primary)
                        
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Controls
            VStack(spacing: 16) {
                Button(action: {
                    dataManager.stopTimer()
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop Timer")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    openWindow(id: "logging")
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Work Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
        }
        .frame(width: 300, height: 400)
        .padding(32)
        .background(Color(.windowBackgroundColor))
    }
    
    private var progress: Double {
        guard dataManager.currentInterval > 0 else { return 0 }
        return 1 - (timerService.timeRemaining / dataManager.currentInterval)
    }
}

#Preview {
    TimerWindowView()
} 