# ResApp - Advanced Resuscitation Assistant

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![iPadOS](https://img.shields.io/badge/iPadOS-15.0+-blue.svg)](https://developer.apple.com/ipados/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)

## 🏥 About ResApp

ResApp is a comprehensive **medical resuscitation assistant** designed specifically for **iPad devices**. Built for healthcare professionals and medical education, it provides real-time guidance, tracking, and documentation during emergency resuscitation procedures.

### 🎯 Purpose
- **Training Mode**: Medical education and simulation scenarios
- **Clinical Mode**: Real-time patient resuscitation assistance
- **Documentation**: Comprehensive session logging and PDF export
- **Compliance**: Follows established emergency protocols and guidelines

## ✨ Key Features

### 🚑 **Core Functionality**
- **Real-time CPR Guidance**: Step-by-step CPR instructions with timing
- **ECG Rhythm Monitoring**: Track and log cardiac rhythms
- **Medication Management**: Dosage tracking for emergency medications (Adrenaline, Amiodarone)
- **Defibrillation Support**: Energy level management and shock delivery tracking
- **Event Logging**: Comprehensive timeline of all resuscitation events
- **Audio Feedback**: Alert sounds and guidance audio cues

### 📊 **Session Management**
- **Timer System**: Precise time tracking for CPR cycles and events
- **Patient Outcome Tracking**: ROSC (Return of Spontaneous Circulation) monitoring
- **Session History**: Complete log of past resuscitation sessions
- **PDF Export**: Generate detailed session reports
- **Data Persistence**: Secure local storage of session data

### 🎓 **Dual Mode System**
- **Training Mode**: 
  - Educational scenarios
  - Fast-forward capabilities for training
  - Simulation-friendly features
  - Performance tracking
  
- **Clinical Mode**:
  - Real-time patient care
  - Critical timing accuracy
  - Streamlined interface
  - Emergency-optimized workflow

## 📱 Device Compatibility

### **Universal iPad Support**
ResApp features a **responsive design** that works perfectly across all iPad models:

- **iPad mini** (8.3" & 7.9") - Compact optimized layout
- **iPad Air** (10.9" & 10.5") - Standard responsive design  
- **iPad** (10.9" & 9.7") - Balanced layout optimization
- **iPad Pro 11"** - Professional layout with enhanced spacing
- **iPad Pro 12.9"** - Maximum layout with spacious design

### **No-Scroll Design**
- All content fits within screen bounds on every iPad size
- No scrolling required on the main interface
- Optimized typography and spacing for each device class

### **Requirements**
- **iOS/iPadOS**: 15.0 or later
- **Device**: iPad (all models supported)
- **Storage**: ~50MB for app and session data
- **Permissions**: Audio playback for guidance sounds

## 🚀 Installation & Setup

### **Prerequisites**
1. **Xcode 14.0+** installed on macOS
2. **iOS/iPadOS SDK 15.0+**
3. **Swift 5.0+** support
4. Valid Apple Developer account for device deployment

### **Installation Steps**

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/ResApp.git
   cd ResApp
   ```

2. **Open in Xcode**
   - Open `ResApp.xcodeproj` in Xcode
   - Ensure iPad deployment target is selected

3. **Configure Signing**
   - Select your development team in project settings
   - Configure app bundle identifier

4. **Build & Deploy**
   - Connect iPad device via USB or use Simulator
   - Build and run the project (⌘+R)

### **Quick Setup Script**
```bash
# Use the included setup script
chmod +x add_files_to_project.sh
./add_files_to_project.sh
```

## 📖 Usage Guide

### **Getting Started**

1. **Launch ResApp** on your iPad
2. **Choose Your Mode**:
   - **Training Mode**: For education and simulation
   - **Clinical Mode**: For actual patient care

### **Training Mode Features**
- Practice resuscitation scenarios
- Fast-forward through CPR cycles for training efficiency
- Session playback and review
- Educational feedback and guidance

### **Clinical Mode Features**
- Real-time patient resuscitation assistance
- Critical timing accuracy
- Streamlined emergency interface
- Immediate access to essential functions

### **Core Functions**

#### **CPR Management**
- Start/stop CPR cycles with precise timing
- Audio guidance for compression rates
- Visual indicators for cycle completion

#### **Rhythm Assessment**
- Log ECG rhythm changes
- Track shockable vs non-shockable rhythms
- Protocol-based recommendations

#### **Medication Administration**
- **Adrenaline**: Track multiple doses with timing
- **Amiodarone**: Monitor loading and maintenance doses
- Custom medication logging
- Dosage recommendations based on protocols

#### **Defibrillation**
- Energy level selection (150J-360J)
- Shock delivery tracking
- Post-shock protocol guidance

#### **Session Documentation**
- Real-time event logging
- Patient outcome recording
- Session summary generation
- PDF export for medical records

## 🏗️ Technical Architecture

### 📁 **Project Structure**

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
│       ├── ModeSelectionView.swift     # Responsive mode selection
│       ├── InstructorModeView.swift    # Training mode interface
│       ├── NormalUserModeView.swift    # Clinical mode interface
│       ├── InfoView.swift              # Information and help
│       ├── SessionDetailView.swift     # Session details
│       ├── SessionHistoryView.swift    # Session history
│       ├── AddEventView.swift          # Event logging
│       ├── EditEventView.swift         # Event editing
│       └── ButtonStyles.swift          # Custom button styles
├── 📁 Managers/                         # Business logic managers
│   ├── ResuscitationManager.swift      # Core resuscitation logic
│   └── CPRProtocolManager.swift        # CPR protocol management
├── 📁 Services/                         # Services and systems
│   ├── ResuscitationGuidelineSystem.swift  # Medical guidelines
│   ├── AudioService.swift              # Audio feedback system
│   ├── TimerService.swift              # Precision timing service
│   ├── PDFExportService.swift          # Session report generation
│   └── SessionStorageService.swift     # Data persistence
├── 📁 Protocols/                        # Protocol definitions
│   └── ResuscitationProtocols.swift    # Interface definitions
├── 📁 Utils/                           # Utilities and extensions
│   ├── Extensions.swift                # Swift extensions
│   ├── Constants.swift                 # App constants
│   └── ShareSheet.swift                # iOS sharing integration
├── 📁 Resources/                        # Audio and media files
│   ├── buzzer.wav                      # Alert sound
│   ├── level-up-191997.mp3            # Success audio
│   ├── QEH.png                         # Hospital logo
│   └── MDSSC.png                       # Training center logo
└── 📁 Assets.xcassets/                  # App icons and colors
    ├── AppIcon.appiconset/             # App icons
    ├── AccentColor.colorset/           # App accent color
    ├── QEH.imageset/                   # QEH logo assets
    └── MDSSC.imageset/                 # MDSSC logo assets
```

### 🔧 **Architecture Principles**

#### **1. Separation of Concerns**
- **Models**: Data structures and enums
- **Views**: UI components and responsive design
- **Managers**: Business logic and state management
- **Services**: Specialized services (audio, timing, storage)
- **Protocols**: Interface definitions for testability

#### **2. Responsive Design System**
- **GeometryReader**: Dynamic layout calculations
- **Device Detection**: Screen size-based optimizations
- **Adaptive Typography**: Font scaling across iPad sizes
- **Universal Compatibility**: Single codebase for all iPads

#### **3. Protocol-Oriented Design**
- Managers implement protocols for better testability
- Services follow protocol patterns
- Easier to mock and unit test
- Improved code maintainability

#### **4. Clean Dependencies**
- Clear separation between business logic and UI
- Services are injected where needed
- No circular dependencies
- Modular architecture for scalability

## 📊 Recent Improvements

### **Universal iPad Responsiveness (Latest Update)**
- ✅ **No-scroll design** - All content fits on screen for every iPad size
- ✅ **Adaptive typography** - Font sizes optimize for each device class
- ✅ **Dynamic spacing** - Layout adjusts to screen dimensions
- ✅ **Compact optimization** - Space-efficient design for smaller iPads
- ✅ **Large screen enhancement** - Spacious layout for iPad Pro models

### **Performance Enhancements**
- Optimized session data storage
- Improved audio service efficiency
- Enhanced timer precision
- Streamlined PDF generation

## ⚕️ Medical Disclaimer

**IMPORTANT MEDICAL NOTICE**

This application is designed for **educational and training purposes only**. ResApp does not replace:
- Proper medical training
- Clinical judgment
- Established emergency protocols
- Professional medical supervision

**Always follow your institution's guidelines and seek appropriate medical supervision.**

### **Compliance & Standards**
- Follows established resuscitation guidelines
- Designed for healthcare professional use
- Educational tool for medical training
- Not a substitute for clinical expertise

## 🏥 Institutional Partners

### **Queen Elizabeth Hospital (QEH)**
- Clinical guidance and validation
- Real-world testing environment
- Medical protocol compliance

### **MDSSC Training Center**
- Medical education expertise
- Training scenario development
- Educational best practices

## 🛠️ Development & Contributing

### **Development Environment**
- **Language**: Swift 5.0+
- **Framework**: SwiftUI 3.0+
- **Architecture**: MVVM with Protocol-Oriented Design
- **Minimum Deployment**: iOS/iPadOS 15.0
- **IDE**: Xcode 14.0+

### **Code Style**
- Follow Swift API Design Guidelines
- Use MARK comments for code organization
- Implement proper error handling
- Write comprehensive documentation

### **Testing**
- Unit tests for business logic
- UI tests for critical workflows
- Protocol-based mocking for services
- Device compatibility testing

## 📄 License & Legal

### **Copyright**
© 2025 QEH MDSSC. All Rights Reserved.

### **Usage Rights**
This software is developed for educational and medical training purposes. Commercial use requires explicit permission from the copyright holders.

### **Medical Liability**
Users of this software acknowledge that it is an educational tool and does not replace professional medical judgment or established emergency protocols.

## 📞 Support & Contact

### **Technical Support**
- Create issues on GitHub repository
- Provide detailed bug reports with device information
- Include steps to reproduce any problems

### **Medical Content Inquiries**
- Contact: QEH MDSSC Training Center
- Email: [Contact Information]
- Website: [Institution Website]

### **Feature Requests**
- Submit enhancement requests via GitHub
- Provide clear use case descriptions
- Consider medical protocol compliance

---

**ResApp** - Advancing Emergency Medicine Through Technology

*Built with ❤️ for healthcare professionals and medical education* 