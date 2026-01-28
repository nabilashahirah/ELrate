# ELRate - Academic Course Review & Rating Platform

ELRate is a mobile application that allows university students to discover, review, and rate academic courses across multiple universities. It helps students make informed course decisions based on authentic peer feedback.

## Features

- **Course Discovery** - Browse top-rated and most-reviewed courses with search and filter
- **Peer Reviews** - Submit and read course reviews from fellow students
- **Anonymous Reviews** - Option to post reviews anonymously
- **AI Content Moderation** - Reviews are checked by AI before publishing to maintain quality
- **AI Validation** - Universities and courses are validated for academic legitimacy
- **Multi-University Support** - Add and browse courses across different universities
- **Secure Authentication** - Login/signup with rate limiting, encrypted storage, and input sanitization

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Architecture | MVVM + Provider |
| Backend | Google Cloud Functions (Serverless) |
| Storage | SharedPreferences + Flutter Secure Storage |
| Encryption | AES-256-CBC |
| AI | Custom AI service for moderation & validation |
| UI | Material Design 3 |

## Project Structure

```
lib/
├── main.dart
├── models/          # Data models (User, Course, Review, University)
├── services/        # API, Auth, AI, and Secure Storage services
├── viewmodels/      # State management with ChangeNotifier
├── views/           # UI screens (Auth, Home, Search, Profile, etc.)
└── utils/           # Theme, constants, responsive helpers, security
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/nabilashahirah/elrate.git
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

## Architecture

The app follows the **MVVM** pattern:

- **Model** - Data classes for User, Course, Review, University
- **View** - Flutter widgets/screens
- **ViewModel** - Business logic using `ChangeNotifier` with `Provider` for state management

Backend is fully serverless using **Google Cloud Functions** deployed in `asia-southeast2`. No Firebase dependency — all communication is through REST APIs.

## Security

- AES-256-CBC encryption for sensitive data
- Secure storage via Android Keystore / iOS Keychain
- Rate limiting on authentication endpoints
- Input validation and sanitization
- AI-powered content moderation to filter inappropriate reviews
