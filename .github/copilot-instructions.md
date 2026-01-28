# Kanisa Flutter App - AI Coding Instructions

## Architecture Overview

This is a **church management mobile app** built with Flutter using the **GetX pattern** for state management and navigation. The app connects to a custom .NET backend API and includes features like member registration, sermon viewing, events, Bible integration, and auto-updates.

### Key Architectural Patterns

- **GetX State Management**: All controllers extend `GetxController` and use `.obs` observables
- **Global Dependencies**: Core services are registered in `main.dart` using `Get.put()` with `permanent: true`
- **Custom API Layer**: Centralized HTTP client in `lib/Network/Apis.dart` with structured response parsing
- **Results Pattern**: API responses use `Results<T>` and `ListResults<T>` wrapper classes for consistent error handling

## Project Structure

```
lib/
├── Network/         # API client and response models
├── controllers/     # GetX controllers for state management  
├── models/          # Data models (Customer, Dimension, Event, etc.)
├── screens/         # UI screens 
├── services/        # Global services (Logger, file operations)
├── theme/           # App theming
├── Utils/           # Utility functions
└── widgets/         # Reusable UI components
```

## Essential Development Patterns

### 1. API Communication
- Base URL: `http://trimline.co.ke:4006/api` (see `ApiClient` class)
- All requests include custom header: `X-Client-Identifier: "kirigiti"`
- Use `postdata()` method for both GET and POST operations
- API responses wrapped in `Results<T>` objects with `Code`, `Desc`, and `Contents`

```dart
// Example API call pattern
var response = await ApiClient().postdata('/endpoint', data: jsonData, isPost: true);
Results<Customer> result = Results.fromJson(response.body, Customer.fromJson);
```

### 2. GetX Controller Pattern
- Controllers auto-initialize data in `onInit()`
- Use `.obs` for reactive variables and `.assignAll()` for lists
- Filter business rules applied (e.g., exclude 'LCC' coded dimensions)

```dart
class DimensionController extends GetxController {
  var isLoading = false.obs;
  var dimensions = <Dimension>[].obs;
  
  @override
  void onInit() {
    fetchDimensions();
  }
}
```

### 3. Navigation & State
- Use `Get.to()` for navigation, `Get.back()` to return
- Route definitions in `main.dart` getPages array
- Phone number stored in SharedPreferences as primary user identifier

### 4. Logging System
- Custom daily file logging via `LoggerService` (debug/info/warning/error methods)
- Logs written to external storage with date-based file naming
- Always use logger for network requests and responses

## Key Business Logic

### Member Management
- Phone number is the primary identifier for customers
- Registration flow: check existence → register if new → navigate to account
- Customer model includes church-specific fields (baptism, confirmation, groups)
- Dimension filtering excludes "LCC" coded items across the app

### Auto-Update System
- Checks for updates via `https://trimline.co.ke/apps/kanisa/update.json`
- Downloads APK using Dio with progress tracking
- Version comparison against `PackageInfo.fromPlatform()`

## Development Commands

```bash
# Standard Flutter commands
flutter pub get
flutter run
flutter build apk --release

# Debug on specific device
flutter run -d <device_id>

# Check for issues
flutter analyze
```

## Important Implementation Notes

- **Permissions**: Android storage permissions requested at startup
- **Assets**: Images in `assets/` folder, referenced in pubspec.yaml
- **Network Error Handling**: Catch exceptions in `postdata()` and return HTTP 400 response
- **State Persistence**: Use SharedPreferences for user session data
- **File Operations**: Use path_provider for external storage access in updates

## Common Gotchas

- API base URL has multiple commented alternatives - verify which is active
- Dimension filtering logic excludes 'LCC' - don't remove this business rule
- GetX controllers must be initialized in main.dart or they won't be available globally
- Phone number validation and storage is critical for user flow - always handle null cases
- Update dialog is non-dismissible during download process

## Testing & Debugging

- Use `LoggerService` methods for debugging rather than print statements
- Check daily log files in external storage for production issues
- Test permissions on Android devices, especially storage access
- Verify API connectivity before testing features requiring network calls