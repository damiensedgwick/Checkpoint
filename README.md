# Checkpoint - Work Session Tracker

A beautiful macOS menu bar app built with SwiftUI that helps you track your work sessions and maintain productivity through timed checkpoints.

## Features

### ⏰ Timer Management
- **Customizable intervals**: Set work session durations from 15 minutes to 4 hours
- **Visual timer display**: Beautiful circular progress indicator with countdown
- **Menu bar integration**: Quick access to timer controls from the menu bar
- **Notifications**: Get notified when your timer completes
- **Persistent state**: Timer continues running even if you close the app

### 📝 Work Logging
- **Quick logging**: Log your work sessions with project and description
- **Smart suggestions**: Quick-select common project types
- **Rich descriptions**: Multi-line text support for detailed logging

### 📊 Log Management
- **Comprehensive view**: Beautiful table view of all your work logs
- **Search functionality**: Find specific entries by project or description
- **Project filtering**: Filter logs by project type
- **Data export**: Export your logs as JSON for backup or analysis
- **Individual deletion**: Remove specific log entries
- **Bulk operations**: Clear all logs when needed

### ⚙️ Settings & Configuration
- **Default interval**: Set your preferred work session interval
- **Data management**: Export and reset functionality
- **App information**: Version and build details

## Keyboard Shortcuts

- `⌘L` - Log work now
- `⌘T` - Start timer
- `⌘S` - Stop timer
- `⌘W` - Show timer window (when timer is running)
- `⌘V` - View logs
- `⌘,` - Open settings
- `⌘Q` - Quit app

## Installation

1. Clone this repository
2. Open `checkpoint.xcodeproj` in Xcode
3. Build and run the project
4. The app will appear in your menu bar

## Usage

### Starting a Work Session
1. Click the hourglass icon in your menu bar
2. Select "Start Timer" or press `⌘T`
3. The timer will begin counting down
4. Optionally open the timer window to see visual progress

### Logging Your Work
1. When your timer completes (or anytime), select "Log work now"
2. Fill in the project name and description
3. Click "Save Log" to record your work

### Viewing Your Logs
1. Select "View logs" from the menu
2. Use the search bar to find specific entries
3. Filter by project using the dropdown
4. Export your data or clear entries as needed

## Architecture

The app follows modern SwiftUI best practices with:

- **MVVM Architecture**: Clean separation of concerns
- **ObservableObject**: Reactive data management
- **UserDefaults**: Local data persistence
- **Window Groups**: Multiple window support
- **Menu Bar Integration**: Native macOS experience

### Key Components

- `DataManager`: Central data persistence and management
- `TimerService`: Timer functionality and notifications
- `LogEntry`: Data model for work logs
- `MenuBarView`: Menu bar interface
- `LoggingView`: Work logging form
- `LogReadingView`: Log management interface
- `TimerWindowView`: Visual timer display
- `SettingsView`: App configuration

## Data Storage

All data is stored locally on your machine using UserDefaults:
- Work logs are saved as JSON
- Timer settings are persisted
- Timer state is maintained across app restarts

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Development

This project uses:
- SwiftUI for the user interface
- Combine for reactive programming
- UserDefaults for data persistence
- NSUserNotification for system notifications

## License

This project is open source and available under the MIT License.
