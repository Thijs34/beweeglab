# InnoBeweegLab - Field Observation System

A Flutter app for managing and conducting field observations in public spaces like parks and sports facilities.

## About This Code

This app is the Flutter version of the React prototype from Figma. The UI and functionality have been transferred from React to Flutter, keeping the same design and user flows.

## Project Structure

### Main Entry Point
- **`lib/main.dart`** - App entry point with routing setup

### Screens (Pages)
All screens are in `lib/screens/`:

- **`auth/`** - Login and signup pages
  - `login_screen.dart` - User login
  - `signup_screen.dart` - New user registration

- **`project_list/`** - Project overview for observers
  - `project_list_screen.dart` - Lists all available projects
  - `widgets/` - Reusable components for the project list

- **`observer_page/`** - Main observation entry screen
  - `observer_page.dart` - Where observers record field observations
  - `models/` - Data models for observations, weather, activities
  - `widgets/` - UI components like session summary, success overlay

- **`admin_page/`** - Project management for admins
  - `admin_page.dart` - Create, edit, and manage projects
  - `admin_models.dart` - Data models for admin features
  - `widgets/` - Admin-specific UI components

### Shared Components
- **`lib/widgets/`** - Reusable widgets used across the app
  - `custom_button.dart` - Styled buttons
  - `custom_text_field.dart` - Styled input fields
  - `project_card.dart` - Project display cards
  - `profile_menu.dart` - User profile dropdown
  - `empty_state.dart` - Empty state placeholder
  - `auth/` - Auth-specific widgets

### Data Models
- **`lib/models/project.dart`** - Project data structure with mock data

### Styling
- **`lib/theme/app_theme.dart`** - App colors, typography, and theme settings

## Current Status

✅ **Complete:**
- All screens and pages from Figma prototype
- Navigation between screens
- UI components and layouts
- Mock/example data for testing

⚠️ **Still To Do:**
- **Styling improvements** - Fine-tune spacing, colors, and responsive design
- **Database connection** - Connect to backend/Firebase for real data storage
- **Real data** - Replace mock data with actual API calls and database queries
- **Client wishes** - Implement features requested by the client

## Getting Started

1. Make sure Flutter is installed
2. Copy `.env.example` to `.env` and paste your Google Places API key
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Google Places Autocomplete

- Enable the Places API (Legacy) and Places API (New) in Google Cloud and create a restricted API key.
- Store the key in `.env` as `GOOGLE_PLACES_API_KEY=your_key` (never commit the real key).
- The admin “Main Location” field uses this key to fetch autocomplete suggestions; without it the field still works as a plain text box.
- On Flutter web builds the Google Places JavaScript SDK loads automatically (using the same key) to avoid CORS errors.

## For the Team

- Look in `lib/screens/` to find all pages
- Each screen folder has its own `widgets/` subfolder for page-specific components
- Mock data is currently hardcoded in model files (like `project.dart`)
- The app structure follows the same flow as the React prototype
