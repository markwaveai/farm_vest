# FarmVest - Smart Dairy Management App

A comprehensive Flutter mobile application for smart dairy farm management, designed for both customers and farm employees.

## 🌟 Features

### Customer Features
- **Dashboard**: Overview of dairy units with health scores and production stats
- **Unit Details**: Detailed information about individual buffalo units
- **Live CCTV**: Real-time monitoring with fullscreen support and screenshot capability
- **Monthly Visits**: Book up to 10 visits per month with available time slots
- **Health Records**: Complete medical history with AI, vaccinations, treatments, and recovery logs
- **Revenue Analytics**: Month-wise revenue tracking with charts and insights
- **Asset Valuation**: Current valuation with growth trends and market comparison
- **Support & FAQ**: Comprehensive help system with ticket raising capability

### Employee Features

#### Supervisor Dashboard
- **Milk Production Entry**: Daily morning and evening milk recording
- **Health Issue Reporting**: Report health problems with transfer approval workflow
- **Ticket Management**: Raise and track support tickets
- **Profile Management**: Personal and work information management

#### Doctor Dashboard
- **High Priority Cases**: Critical health issues requiring immediate attention
- **Task Assignment**: Delegate tasks to assistants with instructions
- **Treatment Plans**: Create and manage medical treatment protocols
- **Health Analytics**: View comprehensive health reports and trends

#### Assistant Dashboard
- **Assigned Tasks**: View and update tasks assigned by doctors
- **Daily Monitoring**: Record temperature, eating status, and medicine administration
- **Treatment Execution**: Follow doctor instructions and update progress
- **Recovery Updates**: Mark animals as fully recovered and notify customers

### Common Features
- **Notifications**: Real-time alerts for health issues, appointments, and updates
- **Role-based Access**: Automatic role detection and appropriate UI display
- **Modern UI**: Clean, farm-themed design with green-white color scheme
- **Responsive Design**: Optimized for Android mobile devices

## 🎨 Design System

### Theme
- **Primary Colors**: Green farm theme (#4CAF50, #2E7D32, #81C784)
- **Typography**: Clean, readable fonts with proper hierarchy
- **Components**: Rounded cards, modern icons, consistent spacing
- **Layout**: Mobile-first design with intuitive navigation

### Navigation
- **Customer**: Bottom navigation with Home, Visits, CCTV, Support, Profile
- **Employee**: Drawer navigation with role-specific menu items
- **Global**: Consistent routing with go_router for smooth transitions

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/
│   ├── router/          # App routing configuration
│   ├── services/        # Business logic services
│   └── theme/           # App theme and constants
├── features/
│   ├── auth/            # Authentication screens
│   ├── customer/        # Customer-specific screens
│   ├── employee/        # Employee-specific screens
│   └── common/          # Shared screens and widgets
└── main.dart           # App entry point
```

### Key Dependencies
- **go_router**: Navigation and routing
- **provider**: State management
- **fl_chart**: Charts and analytics
- **intl**: Internationalization and date formatting
- **cached_network_image**: Image caching
- **camera**: Camera functionality
- **video_player**: Video playback

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd farm_vest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 📱 App Flow

### Authentication Flow
1. **Splash Screen**: FarmVest logo with animation
2. **User Type Selection**: Choose between Customer or Employee
3. **Login**: Mobile/UserID and Password/OTP authentication

### Customer Flow
1. **Dashboard**: Overview of all units and quick stats
2. **Unit Management**: Detailed view, health monitoring, CCTV access
3. **Booking System**: Monthly visit scheduling
4. **Analytics**: Revenue and asset valuation tracking
5. **Support**: FAQ, ticket raising, and contact options

### Employee Flow
1. **Role Detection**: Automatic role assignment (Supervisor/Doctor/Assistant)
2. **Dashboard**: Role-specific quick actions and recent activities
3. **Task Management**: Create, assign, and track tasks
4. **Health Monitoring**: Record observations and treatments
5. **Reporting**: Generate and submit various reports

## 🔧 Configuration

### App Constants
Located in `lib/core/theme/app_theme.dart`:
- Colors, typography, spacing, and component styles
- Customizable theme values for easy branding changes

### Routing
Configured in `lib/core/router/app_router.dart`:
- All app routes and navigation logic
- Role-based route protection

### Notifications
Service in `lib/core/services/notification_service.dart`:
- Real-time notification management
- Custom notification types and handlers

## 🎯 Key Screens

### Customer Screens
- **Dashboard**: Main overview with quick access cards
- **Unit Details**: Buffalo information with health indicators
- **CCTV Live**: Real-time video feed with controls
- **Monthly Visits**: Booking interface with calendar view
- **Health Records**: Tabbed view of medical history
- **Revenue**: Charts and analytics with insights
- **Asset Valuation**: Current worth with trend analysis
- **Support**: FAQ, contact options, and ticket system

### Employee Screens
- **Supervisor Dashboard**: Milk production, health updates, tickets
- **Doctor Dashboard**: Priority cases, task assignment, analytics
- **Assistant Dashboard**: Assigned tasks, monitoring, treatment execution
- **Shared Screens**: Profile management, notifications

## 🔐 Security Features

- **Role-based Access Control**: Different UI and functionality based on user role
- **Secure Authentication**: OTP and password-based login
- **Data Validation**: Form validation and input sanitization
- **Session Management**: Secure user session handling

## 🌐 Future Enhancements

- **Offline Support**: Local data caching for offline usage
- **Push Notifications**: Real-time alerts via Firebase
- **Multi-language Support**: Localization for regional languages
- **IoT Integration**: Direct sensor data integration
- **Advanced Analytics**: Machine learning insights
- **Web Dashboard**: Companion web application for administrators

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏢 About MarkWave

FarmVest is powered by MarkWave Technologies, providing innovative solutions for modern agriculture and livestock management.

**Contact Information:**
- Email: support@markwave.com
- Phone: +91 98765 43210
- Website: www.markwave.com

---

**Built with ❤️ using Flutter**
