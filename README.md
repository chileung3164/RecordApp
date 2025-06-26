# ResApp - Advanced Resuscitation Assistant

## Improved File Structure

The ResApp has been reorganized to follow iOS/SwiftUI best practices with proper separation of concerns:

### 📁 Project Structure

```
ResApp/
├── 📱 ResAppApp.swift                    # Main app entry point
├── 📁 Models/                           # Data models and enums
│   └── ResuscitationModels.swift
├── 📁 Views/                            # SwiftUI views
│   ├── ContentView.swift               # Main content view
│   ├── FunctionalButtonView.swift      # Main functional interface
│   ├── ResuscitationSummaryView.swift  # Summary view
│   └── 📁 Components/                  # Reusable view components
│       ├── ModeSelectionView.swift
│       ├── InstructorModeView.swift
│       ├── NormalUserModeView.swift
│       ├── InfoView.swift
│       ├── ResuscitationRecordView.swift
│       └── ButtonStyles.swift
├── 📁 Managers/                         # Business logic managers
│   ├── ResuscitationManager.swift
│   └── CPRProtocolManager.swift
├── 📁 Services/                         # Services and systems
│   ├── ResuscitationGuidelineSystem.swift
│   ├── AudioService.swift
│   └── TimerService.swift
├── 📁 Protocols/                        # Protocol definitions
│   └── ResuscitationProtocols.swift
├── 📁 Utils/                           # Utilities and extensions
│   ├── Extensions.swift
│   └── Constants.swift
├── 📁 Resources/                        # Audio and media files
│   ├── buzzer.wav
│   └── level-up-191997.mp3
└── 📁 Assets.xcassets/                  # App icons and colors
```

### 🔧 Key Improvements

#### 1. **Separation of Concerns**
- **Models**: Data structures and enums
- **Views**: UI components and screens
- **Managers**: Business logic and state management
- **Services**: Specialized services (audio, timer, guidelines)
- **Protocols**: Interface definitions for better testability

#### 2. **Component-Based Architecture**
- Views are broken down into reusable components
- Button styles are extracted into separate file
- Mode-specific views are modularized

#### 3. **Protocol-Oriented Design**
- Managers implement protocols for better testability
- Services follow protocol patterns
- Easier to mock and unit test

#### 4. **Clean Dependencies**
- Clear separation between business logic and UI
- Services are injected where needed
- No circular dependencies

#### 5. **Scalable Structure**
- Easy to add new features
- Clear file organization
- Follows iOS/SwiftUI conventions

### 🎯 Benefits

1. **Maintainability**: Easier to find and modify specific functionality
2. **Testability**: Protocol-based design allows for better unit testing
3. **Reusability**: Components can be reused across different views
4. **Collaboration**: Clear structure makes it easier for team development
5. **Scalability**: Easy to add new features without cluttering

### 🚀 Usage

The app maintains the same functionality while providing a much cleaner and more organized codebase:

- **Instructor Mode**: Full features for medical professionals
- **Normal User Mode**: Simplified interface for general use
- **Real-time CPR guidance**
- **ECG rhythm monitoring**
- **Medication tracking**
- **Event logging**

### 📋 Technical Notes

- Removed duplicate files that existed in both root and subdirectories
- Implemented protocol-oriented design patterns
- Added proper MARK comments for better code navigation
- Separated UI components from business logic
- Created reusable services and utilities

This structure follows Apple's recommended patterns and makes the codebase much more maintainable and professional. 