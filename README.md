# Sorah

Sorah is a Flutter application designed to bridge the gap between caregivers and elderly individuals ("Murobbi"). It provides a seamless, role-based platform that offers health monitoring, schedule management, and instant communication to ensure better care and connectivity.

## Features

- **Role-Based Interfaces**: Separate, tailored experiences for Caregivers and Elderly users (Murobbi) upon app startup.
- **Multilingual Support**: Supports multiple languages, including English and Assamese, ensuring accessibility for a wider audience.
- **Caregiver Dashboard**:
  - **Analytics & Progress**: Track medication adherence and completed health challenges.
  - **Instant Alerts**: Quickly send emergency or reminder alerts (e.g., Drink Water, Take Medicine, Call Me) directly to the connected Murobbi device via Firebase Firestore.
  - **Active Schedules**: View and manage daily routines and reminders (e.g., Blood Pressure Pills, Hydration, Doctor Appointments).
  - **Quick Actions**: Easy access to schedule reminders, create custom tasks, upload photos, and manage patient settings.
- **Firebase Integration**: Utilizes Firebase for secure authentication and Cloud Firestore for real-time data sync and alerts.

## Getting Started

This project is built with Flutter and uses Firebase for its backend services. 

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.13.3 or higher recommended)
- Dart SDK
- Firebase account and configuration

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd sorah
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   Ensure you have the `firebase_options.dart` generated and placed in the `lib` directory for your specific Firebase project setup.

4. Run the application:
   ```bash
   flutter run
   ```

## Additional Resources

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter API Reference](https://docs.flutter.dev/reference/)
