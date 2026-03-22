# Magic English - Flutter Mobile App

Complete English learning application with vocabulary management, grammar checking, and progress tracking powered by Ollama AI.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Running the App](#running-the-app)
- [API Configuration](#api-configuration)
- [Features Walkthrough](#features-walkthrough)
- [State Management](#state-management)
- [Widget Components](#widget-components)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## 🌟 Features

### 1. **Smart Vocabulary Notebook**
- Add English words with automatic AI enrichment
- View pronunciation (IPA), meaning, part of speech
- See contextual examples from Ollama AI
- CEFR level classification (A1-C2)
- Search and filter vocabulary
- Track review count for each word
- Delete words from notebook

### 2. **Grammar & Style Checker**
- Check text for grammar, spelling, and style errors
- Get AI-powered suggestions for improvements
- View detailed error descriptions
- Track grammar check history
- Score-based feedback (0-10)
- Error categorization and fixes

### 3. **Learning Progress Dashboard**
- Daily streak tracking with fire 🔥 animation
- Vocabulary statistics (total learned, today's count)
- CEFR level distribution pie chart
- Part of speech bar chart
- Visual progress indicators
- Activity trend monitoring

### 4. **User Authentication**
- Email-based login/signup
- Session management with SharedPreferences
- Auto-logout on app exit
- User profile display

## 🏗️ Architecture

### Clean Architecture Pattern
```
lib/
├── main.dart              # App entry point
├── models/                # Data models (mirrors backend DTOs)
├── services/              # API client & session management
├── providers/             # State management (Provider pattern)
├── screens/               # Entire screens/pages
├── widgets/               # Reusable UI components
└── assets/                # Images, fonts, etc.
```

### Data Flow
```
UI (Screens) 
  ↓
Providers (State Management)
  ↓
Services (Business Logic)
  ↓
API Client (HTTP Requests)
  ↓
Backend/.NET 8 API
```

## 📁 Project Structure

### Models (`lib/models/models.dart`)
- `User` - User authentication and profile
- `Vocabulary` - Single vocabulary word with metadata
- `VocabularyStatistics` - Vocabulary usage statistics
- `GrammarError` - Individual grammar error
- `GrammarCheckResult` - Complete grammar check result
- `Streak` - User's learning streak
- `DailyActivity` - Daily activity record
- `Dashboard` - Complete dashboard data

### Services

#### API Client (`lib/services/api_client.dart`)
Static HTTP client with 15+ methods:
- **Users**: signup, login, logout, updateProfile
- **Vocabulary**: addVocabulary, getVocabularies, searchVocabularies, deleteVocabulary, getStatistics
- **Grammar**: checkGrammar, getGrammarHistory, deleteHistory
- **Dashboard**: getDashboard, getStreak, getActivityTrend

#### User Service (`lib/services/user_service.dart`)
Local session management:
- Save/retrieve user info
- Check authentication status
- Handle logout

### Providers (`lib/providers/app_providers.dart`)
**Four main state management classes:**

1. **AuthProvider** - Authentication state
   - `signup(name, email)` - Create new account
   - `login(email)` - Sign in
   - `logout()` - Clear session
   - Properties: currentUser, isLoading, error

2. **VocabularyProvider** - Vocabulary management
   - `addVocabulary(userId, word)` - Add new word
   - `loadVocabularies(userId)` - Fetch all words
   - `searchVocabularies(userId, query)` - Search words
   - `deleteVocabulary(id)` - Remove word
   - `loadStatistics(userId)` - Get stats

3. **GrammarProvider** - Grammar checking
   - `checkGrammar(userId, text)` - Check text
   - `loadHistory(userId)` - Fetch history
   - Properties: lastResult, history

4. **DashboardProvider** - Dashboard data
   - `loadDashboard(userId)` - Main dashboard
   - `loadStreak(userId)` - Streak info
   - `loadActivityTrend(userId)` - Activity data

### Screens

| Screen | File | Purpose |
|--------|------|---------|
| **Splash** | `main.dart` | Auth state check, loading UI |
| **Auth** | `auth_screen.dart` | Login/signup form |
| **Home** | `home_screen.dart` | Bottom nav with 3 tabs |
| **Dashboard** | `dashboard_screen.dart` | Streaks & charts |
| **Vocabulary** | `vocabulary_screen.dart` | Words list with search |
| **Add Vocabulary** | `add_vocabulary_screen.dart` | Add new word form |
| **Grammar** | `grammar_screen.dart` | Check & history tabs |

### Widgets (`lib/widgets/`)
- **StreakCard** - Displays current streak with best record
- **StatCard** - Shows statistics (icon + number + label)

## 📦 Prerequisites

### Required Software
- **Flutter SDK**: 3.0+ ([Download](https://flutter.dev/docs/get-started/install))
- **.NET 8 SDK**: For backend API
- **SQL Server**: 2019 or later (for database)
- **Ollama Cloud**: API key from [ollama.ai](https://ollama.com)
- **Android Studio** or **Xcode**: For emulator/device

### Verify Installation
```bash
flutter --version
flutter doctor  # Check all dependencies

# Output should show:
# ✓ Flutter (Channel stable)
# ✓ Android toolchain / Xcode
# ✓ Android Studio / Xcode
```

## 🚀 Installation & Setup

### 1. Clone & Navigate
```bash
cd c:\Users\vanqu\Magic_English\Mobile\magic_english
```

### 2. Get Flutter Dependencies
```bash
flutter pub get
```

Installs packages from `pubspec.yaml`:
- `http` - HTTP requests
- `provider` - State management
- `fl_chart` - Data visualization
- `google_fonts` - Typography
- `shared_preferences` - Local storage
- `intl` - Internationalization

### 3. Configure API Endpoint

Edit `lib/services/api_client.dart`:
```dart
// Line 10 - Update baseUrl based on environment
static const String baseUrl = 'http://localhost:5000/api/v1';

// For different environments:
// Android Emulator: 'http://10.0.2.2:5000/api/v1'
// Physical Device: 'http://<YOUR_PC_IP>:5000/api/v1'
// iOS Simulator: 'http://localhost:5000/api/v1'
```

### 4. Ensure Backend is Running
```bash
# In backend directory, run:
dotnet run
# API should be listening on http://localhost:5000
```

### 5. Create Emulator/Connect Device
```bash
# List available devices
flutter devices

# Create Android emulator (if none exist)
flutter emulators --create --name emulator-5554

# Start emulator
flutter emulators --launch emulator-5554
```

## ▶️ Running the App

### Development Mode (Hot Reload)
```bash
flutter run
```

### Run on Specific Device
```bash
flutter run -d <device-id>  # Use device ID from 'flutter devices'
```

### Build Release APK
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-app.apk
```

### Build Release iOS App
```bash
flutter build ios --release
# Use Xcode to deploy on TestFlight
```

## 🔌 API Configuration

### Base URL Setup
The app connects to your backend API. Update the base URL in `api_client.dart`:

```dart
// LOCAL DEVELOPMENT
static const String baseUrl = 'http://localhost:5000/api/v1';

// ANDROID EMULATOR (from emulator to host PC)
static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

// PHYSICAL DEVICE (replace with your PC IP)
static const String baseUrl = 'http://192.168.1.100:5000/api/v1';
```

### API Authentication
Currently using **Email-based authentication**. Backend creates/retrieves user by email:
```dart
// Auto-registration on login if user doesn't exist
POST /api/v1/users/login
Body: { "email": "user@example.com" }
```

### Recommended Future Enhancement: JWT Tokens
For production, implement JWT authentication:
1. Backend returns JWT token on login
2. Store token in SharedPreferences
3. Add token to all API request headers:
```dart
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
}
```

## 🎯 Features Walkthrough

### 1. Authentication Flow
```
App launches
  ↓
SplashScreen checks UserService.isLoggedIn()
  ├─ If logged in → HomeScreen
  └─ If not → AuthScreen
```

**AuthScreen Actions:**
- **Sign Up**: Create account with name + email
- **Sign In**: Login with email only
- Session saved to SharedPreferences

### 2. Dashboard Flow
```
HomeScreen (Tab 0)
  ↓
DashboardScreen
  ├─ StreakCard (🔥 Current streak)
  ├─ StatCard (📚 Total vocabulary)
  ├─ StatCard (✅ Today's activity)
  ├─ PieChart (CEFR distribution)
  └─ BarChart (Part of speech)
```

### 3. Vocabulary Flow
```
HomeScreen (Tab 1)
  ├─ VocabularyScreen
  │   ├─ Search bar
  │   ├─ Word list
  │   │   ├─ Word pronunciation
  │   │   ├─ Example sentence
  │   │   ├─ Review count
  │   │   └─ Delete button
  │   └─ FAB → AddVocabularyScreen
  │         ↓
  │   AddVocabularyScreen
  │   ├─ Text field for word
  │   ├─ Submit button
  │   └─ AI enrichment on backend
  └─ Shows CEFR level chips
```

### 4. Grammar Checking Flow
```
HomeScreen (Tab 2)
  ├─ GrammarScreen (2 tabs)
  │   ├─ Tab 1: Check Grammar
  │   │   ├─ Text input
  │   │   ├─ Submit button
  │   │   └─ Score + errors display
  │   └─ Tab 2: History
  │       └─ Previous checks list
  ```

## 🎮 State Management

### Provider Pattern
All state is managed through `ChangeNotifier` providers:

```dart
// In widget, read a provider:
final provider = context.read<VocabularyProvider>();
await provider.addVocabulary(userId, word);

// In widget, listen to changes:
Consumer<VocabularyProvider>(
  builder: (context, provider, child) {
    return Text('Words: ${provider.vocabularies.length}');
  },
)

// Listen to errors:
if (provider.error != null) {
  showSnackBar(provider.error);
}
```

### Loading States
All providers have `isLoading` boolean:
```dart
if (provider.isLoading) {
  CircularProgressIndicator()
} else {
  // Show data
}
```

## 🧩 Widget Components

### StreakCard
Displays user's learning streak:
```dart
StreakCard(
  streak: dashboard.streak,  // Streak object from model
)
// Shows: Current streak, best streak, last activity date
// Includes progress bar
```

### StatCard
Reusable statistics display:
```dart
StatCard(
  title: 'Vocabulary',
  value: '125',
  icon: Icons.book,
  color: Colors.blue,
)
```

### Charts (using fl_chart)
- **PieChart**: CEFR level distribution
- **BarChart**: Part of speech distribution

## 🧪 Testing

### Manual Testing Checklist
- [ ] App launches without crashes
- [ ] Login/signup works
- [ ] Can add a vocabulary word
- [ ] Word appears in list with AI enrichment
- [ ] Can search vocabulary
- [ ] Can delete vocabulary
- [ ] Grammar checker accepts input
- [ ] Grammar check shows results
- [ ] Dashboard loads charts
- [ ] Streak displays correctly
- [ ] Navigation between tabs works
- [ ] Logout clears session

### Unit Testing (Coming Soon)
```bash
flutter test
```

Would test:
- Model serialization/deserialization
- API client request building
- Provider state changes
- Service business logic

## 🐛 Troubleshooting

### Issue: "Connection refused" when calling API
**Solution**: 
1. Verify backend is running: `dotnet run`
2. Check base URL in `api_client.dart`
3. For Android emulator, use `10.0.2.2:5000`
4. Check firewall isn't blocking port 5000

### Issue: Models don't deserialize from JSON
**Solution**:
1. Keys in JSON must match model properties exactly
2. Use `?.` for nullable fields
3. Check response data type (array vs object)

### Issue: Flutter packages not found
**Solution**:
```bash
flutter pub get
flutter pub upgrade
flutter clean
flutter pub get
```

### Issue: Emulator too slow
**Solution**:
- Use physical device for development
- Increase emulator RAM: AVD Manager → Edit → RAM: 4GB+
- Or build for release: `flutter run --release`

### Issue: Hot reload doesn't work
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
# Or use hot restart: 'r' in terminal
```

## 📱 Device Configuration

### Android Setup
```bash
# Create new AVD
flutter emulators --create --name pixel5

# Start emulator
flutter emulators --launch pixel5

# Run app
flutter run
```

### iOS Setup (macOS)
```bash
# Pod dependencies
cd ios
pod install
cd ..

# Run on simulator
flutter run -d "iPhone 15 Pro"

# Or on physical device (requires provisioning profile)
flutter run -d <device-id>
```

## 📊 Performance Tips

1. **Lazy Loading**: Screens load data on demand, not on app start
2. **Search Debouncing**: Search API calls debounced to avoid excessive requests
3. **Image Caching**: Google Fonts cached locally
4. **Pagination**: Can be added to vocabulary list if grows large

## 🔐 Security Notes

### Current Development Setup
- ✅ Email-based auth (OK for dev/testing)
- ⚠️ No HTTPS (only for local dev)
- ⚠️ No JWT tokens (credentials stored locally)

### Production Recommendations
1. Implement JWT token-based auth
2. Use HTTPS for all API calls
3. Add certificate pinning
4. Encrypt SharedPreferences data
5. Implement refresh token mechanism
6. Add request signing

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [Backend API Documentation](../SETUP_GUIDE.md)
- [Database Schema](../DATABASE_DESIGN.md)
- [AI Prompts](../AI_PROMPTS.md)

## 📝 Development Workflow

### Before Committing
1. Run `flutter format lib/` to format code
2. Run `flutter analyze` to check for issues
3. Test on both Android and iOS emulators
4. Test on physical device if possible
5. Check that backend is running and responding

### Git Workflow
```bash
git add .
git commit -m "feat: add grammar checker screen"
git push origin main
```

## 🤝 Contributing

When adding new features:
1. Create feature branch: `git checkout -b feature/new-feature`
2. Add screen/widget with full implementation
3. Update this README with feature documentation
4. Test thoroughly
5. Submit pull request

## 📄 License

Proprietary - Magic English Learning Application 2024

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Flutter SDK**: 3.0+  
**Dart**: 3.0+
