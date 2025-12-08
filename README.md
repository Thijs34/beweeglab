# InnoBeweegLab - Field Observation System

This repo holds our Flutter app for running field observations. Observers can take notes in parks or sport areas, while admins plan projects, watch activity on a map, and export data. The code runs on web, desktop, and mobile with a single codebase.

## What you get
- **Real-time sync:** Firebase Auth + Firestore keep users, projects, notifications, and observations up to date on every device.
- **Observer tools:** Capture individual or group observations, pick custom fields per project, and save drafts.
- **Admin tools:** Create and edit projects, manage observers, review notifications, check the Google Maps overview, and export spreadsheets.
- **Languages:** English and Dutch strings with `flutter gen-l10n` and a simple locale switcher.
- **Platforms:** Works on Android, iOS, macOS, Windows, Linux, and web (Vercel build script included).

## Tools we use
- Flutter 3.9 / Dart 3.9 with Material 3 styling (`lib/theme/app_theme.dart`).
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, and generated `firebase_options.dart`.
- Google Maps + Places autocomplete for the admin project map (`GOOGLE_PLACES_API_KEY` lives in `.env`).
- Helper packages: `shared_preferences`, `syncfusion_flutter_xlsio`, `file_saver`, `flutter_svg`, `vector_graphics`, `flutter_typeahead`, and more in `pubspec.yaml`.

## Folder cheat sheet
| Path | What's inside |
| --- | --- |
| `lib/main.dart` | Loads env values, starts Firebase, wires up routes. |
| `lib/config/` | Helpers like `AppConfig` for env keys. |
| `lib/models/` | Data shapes for projects, observations, navigation, etc. |
| `lib/services/` | Auth, user, project, observation, notification, export, locale, and Google Maps loaders. |
| `lib/screens/` | Feature folders: `auth`, `project_list`, `observer_page`, `admin_page`, `admin_map`, `admin_notifications`, `profile`. Each contains its widgets/models. |
| `lib/widgets/` | Shared UI like `AppPageHeader`, buttons, and the profile menu shell. |
| `lib/theme/` | Color and typography setup. |
| `lib/l10n/` | ARB files and generated output (configured by `l10n.yaml`). |
| `assets/map/` | Marker artwork for Google Maps. |
| `android/ ios/ macos/ windows/ linux/ web/` | Platform runners plus Firebase config files. |
| `docs/` & `diagrams/` | Project documentation and visuals. |

## Getting set up
1. **Install the basics**
   - Flutter 3.9.2 or newer on the stable channel.
   - Firebase CLI (only if you ever re-run `flutterfire configure`).
   - Dart/Flutter on your PATH.

   **Need to update Flutter?**
   - Run `flutter upgrade`.
   - Then run `flutter doctor` to verify tools and connected devices.
   - If you installed Flutter from a ZIP, download the new ZIP, replace the old folder, and run `flutter doctor` again.

2. **Clone and grab packages**
   ```bash
   git clone <repo-url>
   cd fluttermain
   flutter pub get
   ```

3. **Hook up Firebase**
   - `firebase_options.dart` already lives in `lib/`, but if you switch Firebase projects use `flutterfire configure` to regenerate it.
   - Android needs an up-to-date `android/app/google-services.json` and iOS/macOS need `Runner/GoogleService-Info.plist`.

4. **Create `.env`**
   - Add `GOOGLE_PLACES_API_KEY=your_key_here` (same one you enabled in Google Cloud for Places and Maps).
   - Never commit that file. CI (Vercel) injects the key before building.

5. **Run the app**
   ```bash
   flutter run            # choose any device
   flutter run -d chrome  # quick web build with Google Maps
   ```

## How integrations work
### Google Places + Maps
- Admins see autocomplete when typing the "Main Location" field and can open the map screen with custom markers.
- On web we lazy-load the Google Maps JS SDK (`google_maps_web_loader.dart`). If the key is missing the screen shows an error message but the rest of the app keeps working.

### Firebase
- **Auth:** Email/password login with persistence on web (`AuthService.ensurePersistence`).
- **Firestore:** `ProjectService`, `ObservationService`, and friends talk to `projects`, nested `observations`, and notification collections.

### Localization
- Two ARB files: `app_en.arb` and `app_nl.arb`.
- Edit or add ARB files, then run `flutter gen-l10n` (or simply rebuild) to refresh the code in `lib/l10n/gen/`.
- `LocaleService` stores the chosen language in `SharedPreferences`.

### Admin exports
- We rely on `syncfusion_flutter_xlsio` plus `file_saver` to export observation data as XLSX files straight from the admin UI.

## Handy commands
- `flutter run` - start the app on any device.
- `flutter test` - run unit/widget tests.
- `flutter analyze` - lint using `analysis_options.yaml`.
- `dart run build_runner watch` - only if you add new code generators later.

## Deploying the web build
- Vercel runs the `vercel-build` script from `package.json`. It downloads Flutter, writes `.env` with the `GOOGLE_PLACES_API_KEY` secret, runs `flutter pub get`, and builds `flutter build web --release`.
- Make sure Vercel (or other CI) has the right secrets for Maps/Firebase before deploying.

## Tips
- Start in `lib/services/` when you need to understand how data flows between Firebase and the UI.
- `ProjectMapScreen` shows the Google Maps integration plus how we route to other admin views.
- `ObserverPage` is the main observation experience, including drafts, group mode, and the call to `ObservationService`.
- Keep UI strings inside the ARB files so translations stay synced.
- New env values should go through `AppConfig` so we can share them across platforms.
