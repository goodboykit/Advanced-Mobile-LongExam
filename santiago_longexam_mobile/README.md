# Santiago Long Exam Mobile

A Flutter application that connects to the Santiago Long Exam backend API.

## Features

- View items from the backend
- CRUD operations for items and users
- Modern Material Design 3 UI
- Provider state management
- HTTP API integration

## Getting Started

1. Make sure the backend server is running on `http://localhost:5000`
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Backend Integration

This app connects to the Santiago Long Exam backend API endpoints:
- `/api/items` - Item management
- `/api/users` - User management

## Dependencies

- `http` - HTTP client for API calls
- `provider` - State management
- `shared_preferences` - Local storage
- `cupertino_icons` - iOS-style icons