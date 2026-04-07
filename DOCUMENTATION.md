# SnapIdeas — Complete Project Documentation

> **Version:** 3.1.1+5 | **Framework:** Flutter (SDK ^3.9.0) | **Backend:** Supabase

SnapIdeas is a cross-platform mobile application that helps photographers and models achieve the perfect shot. It combines a curated inspiration library with real-time AI-powered pose guidance, face filters, and an integrated content management system.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tech Stack & Dependencies](#2-tech-stack--dependencies)
3. [Project Architecture](#3-project-architecture)
4. [Feature Modules](#4-feature-modules)
   - 4.1 [Splash](#41-splash)
   - 4.2 [Auth](#42-auth)
   - 4.3 [Home](#43-home)
   - 4.4 [Explore](#44-explore)
   - 4.5 [Categories](#45-categories)
   - 4.6 [Images & Magic Camera](#46-images--magic-camera)
   - 4.7 [Favorites](#47-favorites)
   - 4.8 [Quotes](#48-quotes)
   - 4.9 [Profile](#49-profile)
   - 4.10 [Settings](#410-settings)
   - 4.11 [Admin Portal](#411-admin-portal)
5. [Core Layer](#5-core-layer)
   - 5.1 [Services](#51-services)
   - 5.2 [Models](#52-models)
   - 5.3 [Theme System](#53-theme-system)
   - 5.4 [Shared Widgets](#54-shared-widgets)
6. [Database Schema](#6-database-schema)
7. [State Management](#7-state-management)
8. [AI / ML Pipeline](#8-ai--ml-pipeline)
9. [Getting Started](#9-getting-started)
10. [Configuration](#10-configuration)
11. [Platform Support](#11-platform-support)

---

## 1. Overview

| Property        | Value                                            |
| --------------- | ------------------------------------------------ |
| App Name        | SnapIdeas                                        |
| Package ID      | `snap_ideas`                                     |
| Version         | `3.1.1+5`                                        |
| Description     | Your professional guide to perfect poses         |
| Backend         | Supabase (Auth, Database, Storage)               |
| Target Platforms| Android, iOS, Web, Windows, macOS, Linux         |

### Key Features

| Feature            | Description                                                                |
| ------------------ | -------------------------------------------------------------------------- |
| 📸 Inspiration Library | Curated photo ideas, filtered by category & sub-category              |
| 🤖 Magic Camera    | Real-time AI pose detection and coaching via live camera feed              |
| 😄 Face Filters    | Overlay stickers/assets anchored to facial landmarks                       |
| ❤️ Likes & Favorites | Per-user like system for both images and quotes                         |
| 💬 Quotes          | Motivational photography quotes, categorized and likeable                  |
| 👤 Profile         | User profile with avatar, display name, and liked content                  |
| ⚙️ Settings         | Dark/light theme toggle, privacy policy, terms of service                 |
| 🛡️ Admin Portal    | Full CMS — manage categories, images, quotes, filters, and data            |

---

## 2. Tech Stack & Dependencies

### Core Framework

| Package              | Version      | Purpose                            |
| -------------------- | ------------ | ---------------------------------- |
| `flutter`            | SDK          | Cross-platform UI framework        |
| `supabase_flutter`   | `^2.10.3`    | Auth, Postgres DB, Storage         |
| `provider`           | `^6.1.5+1`   | Reactive state management          |
| `shared_preferences` | `^2.5.3`     | Local key-value persistence        |

### UI & UX

| Package                      | Version    | Purpose                            |
| ---------------------------- | ---------- | ---------------------------------- |
| `google_fonts`               | `^6.3.2`   | Custom typography                  |
| `flutter_staggered_grid_view`| `^0.7.0`   | Masonry / staggered photo grids    |
| `cached_network_image`       | `^3.4.1`   | Efficient image loading & caching  |
| `shimmer`                    | `^3.0.0`   | Skeleton loading placeholders      |
| `photo_view`                 | `^0.15.0`  | Pinch-to-zoom fullscreen viewer    |
| `appinio_swiper`             | `^2.1.1`   | Tinder-style swipe card UI         |

### Camera & Media

| Package                  | Version   | Purpose                                    |
| ------------------------ | --------- | ------------------------------------------ |
| `camera`                 | `^0.11.3` | Live camera stream access                  |
| `image_picker`           | `^1.2.1`  | Gallery / camera image selection           |
| `flutter_image_compress` | `^2.4.0`  | Image compression before upload            |
| `gal`                    | `^2.3.0`  | Save images to device gallery              |
| `path_provider`          | `^2.1.5`  | Access to file system paths                |

### AI / ML Kit

| Package                          | Version    | Purpose                              |
| -------------------------------- | ---------- | ------------------------------------ |
| `google_mlkit_pose_detection`    | `^0.14.0`  | Skeleton / landmark pose detection   |
| `google_mlkit_selfie_segmentation` | `^0.10.0`| Background removal from selfies      |
| `google_mlkit_face_detection`    | `^0.13.0`  | Face bounding box & landmark data    |

### Utilities

| Package              | Version    | Purpose                                   |
| -------------------- | ---------- | ----------------------------------------- |
| `http`               | `^1.6.0`   | HTTP client                               |
| `sensors_plus`       | `^7.0.0`   | Accelerometer / gyroscope data            |
| `flutter_tts`        | `^4.2.5`   | Text-to-speech voice coaching             |
| `share_plus`         | `^12.0.1`  | Share images / content externally         |
| `permission_handler` | `^12.0.1`  | Runtime permission requests               |

---

## 3. Project Architecture

The project follows a **Feature-First** architecture — all files related to a domain live together. Shared, cross-cutting concerns live in the `core` layer.

```
lib/
├── main.dart                     # App entry point, Supabase init, ThemeProvider
├── core/
│   ├── models/                   # Shared data models
│   ├── services/                 # Backend & ML service classes
│   ├── theme/                    # AppTheme (light/dark) & ThemeProvider
│   ├── utils/                    # Global utility helpers
│   └── widgets/                  # Reusable shared widgets
└── features/
    ├── splash/                   # Startup splash screen
    ├── auth/                     # Login, signup, forgot password
    ├── home/                     # Main navigation hub
    ├── explore/                  # Discovery & search
    ├── categories/               # Category grid & sub-category browser
    ├── images/                   # Image detail, fullscreen viewer, magic camera
    ├── favorites/                # Liked images screen
    ├── quotes/                   # Motivational quotes feed
    ├── profile/                  # User profile & edit
    ├── settings/                 # App settings, legal pages
    └── admin/                    # Admin content management portal
```

### Feature Folder Convention

```
features/<feature_name>/
├── screens/      # Full-page UI widgets
├── widgets/      # Feature-specific reusable components
├── models/       # Feature-specific data models (if needed)
└── providers/    # Feature-specific ChangeNotifiers (if needed)
```

### Application Entry Point (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '<SUPABASE_URL>',
    anonKey: '<SUPABASE_ANON_KEY>',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SnapIdeasApp(),
    ),
  );
}
```

`SnapIdeasApp` reads from `ThemeProvider` to apply the current `ThemeMode` and boots directly into `SplashScreen`.

---

## 4. Feature Modules

### 4.1 Splash

| File | Description |
| ---- | ----------- |
| `splash/screens/splash_screen.dart` | Entry screen shown on app launch; checks Supabase auth session and routes to Home or Login |

**Navigation flow:**
```
App Launch
    └── SplashScreen
            ├── session found  → HomeScreen
            └── no session     → LoginScreen
```

---

### 4.2 Auth

Handles all user identity operations using Supabase Auth.

| File | Description |
| ---- | ----------- |
| `auth/screens/login_screen.dart` | Email + password login form |
| `auth/screens/signup_screen.dart` | New user registration with profile creation |
| `auth/screens/forgot_password_screen.dart` | Password reset via Supabase email magic link |

Sessions are persisted automatically via Supabase's built-in JWT + `shared_preferences` storage.

---

### 4.3 Home

| File | Description |
| ---- | ----------- |
| `home/screens/home_screen.dart` | Main app shell with bottom navigation bar; hosts Explore, Favorites, Quotes, Profile & Settings tabs |

---

### 4.4 Explore

| File | Description |
| ---- | ----------- |
| `explore/screens/explore_screen.dart` | All-photos discovery grid; fetches via `SupabaseService.getAllImages()` |
| `explore/screens/discovery_screen.dart` | Alternative swipe / staggered-card discovery layout |

---

### 4.5 Categories

| File | Description |
| ---- | ----------- |
| `categories/screens/category_grid_screen.dart` | Displays all top-level categories in a responsive grid |
| `categories/screens/sub_category_screen.dart` | Shows sub-categories and their photo collection for a selected category |

**Data flow:**
```
SupabaseService.getCategories()
    └── CategoryGridScreen
            └── (user selects)
                    └── SupabaseService.getSubCategories(id)
                            └── SubCategoryScreen
```

---

### 4.6 Images & Magic Camera

The most technically complex feature module.

| File | Description |
| ---- | ----------- |
| `images/screens/image_detail_screen.dart` | Full photo detail view with posing instructions, like, share, and download actions |
| `images/screens/fullscreen_image_viewer.dart` | Pinch-to-zoom fullscreen image viewer using `photo_view` |
| `images/screens/magic_camera_screen.dart` | **Core AI feature** — Live camera with real-time pose detection, face filters, and voice coaching |

#### Magic Camera — Capabilities

| Capability | Implementation |
| ---------- | -------------- |
| Live camera feed | `camera` package (`CameraController`) |
| Pose landmark detection | `google_mlkit_pose_detection` (stream mode) |
| Pose similarity score | Custom `PoseDetectionService.calculateSimilarity()` |
| Voice coaching | `flutter_tts` via `TtsService` |
| Selfie background segmentation | `google_mlkit_selfie_segmentation` |
| Face filter overlays | `google_mlkit_face_detection` + `FaceFilterService` |
| Device orientation | `sensors_plus` |

---

### 4.7 Favorites

| File | Description |
| ---- | ----------- |
| `favorites/screens/favorites_screen.dart` | Displays all images liked by the current user via `SupabaseService.getLikedImages()` |

---

### 4.8 Quotes

| File | Description |
| ---- | ----------- |
| `quotes/screens/quotes_screen.dart` | Feed of motivational photography quotes with category filter, like toggle, and share |

Quotes and their likes are stored in the `quotes` and `quote_likes` Supabase tables with per-user RLS policies.

---

### 4.9 Profile

| File | Description |
| ---- | ----------- |
| `profile/screens/profile_screen.dart` | Displays user avatar, display name, email, and liked-image count |
| `profile/screens/edit_profile_screen.dart` | Edit display name and profile photo (picked, compressed, then uploaded to Supabase Storage) |
| `profile/screens/help_support_screen.dart` | In-app help & support information |
| `profile/screens/legal_screen.dart` | Legal notices and links |

---

### 4.10 Settings

| File | Description |
| ---- | ----------- |
| `settings/screens/settings_screen.dart` | App preferences — theme toggle, account actions, sign out |
| `settings/screens/privacy_policy_screen.dart` | Full privacy policy |
| `settings/screens/terms_of_service_screen.dart` | Terms of service |
| `settings/screens/help_support_screen.dart` | Help & FAQ content |

---

### 4.11 Admin Portal

A full content management system accessible to admin users only.

| File | Description |
| ---- | ----------- |
| `admin/screens/admin_dashboard_screen.dart` | Dashboard overview with navigation cards to all admin sections |
| `admin/screens/admin_category_screen.dart` | Create and delete top-level categories and sub-categories |
| `admin/screens/admin_images_tab.dart` | Browse, search, and manage all uploaded images |
| `admin/screens/admin_upload_screen.dart` | Upload new photo ideas (image + posing instructions + category) |
| `admin/screens/admin_edit_image_screen.dart` | Edit metadata (instructions, category) for an existing image |
| `admin/screens/admin_assets_screen.dart` | Manage static asset files referenced in the app |
| `admin/screens/admin_filters_screen.dart` | View all face filters in the `face_filters` table |
| `admin/screens/admin_filter_upload_screen.dart` | Upload new face filter entries (name, type, icon, asset, anchor, scale, offsets) |
| `admin/screens/admin_quotes_tab.dart` | View, add, and delete quotes; manage quote categories |
| `admin/screens/admin_data_sync_screen.dart` | Tools to sync or refresh cached/local data |
| `admin/screens/admin_data_clear_screen.dart` | Bulk-delete or clear Supabase table data (danger zone) |

---

## 5. Core Layer

### 5.1 Services

All services live in `lib/core/services/` and are primarily **static utility classes**.

#### `SupabaseService`

Central data-access layer — all methods are `static`.

**Categories & Sub-categories**

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `getCategories()` | `List<Map>` | All categories ordered by name |
| `getSubCategories(categoryId)` | `List<Map>` | Sub-categories for a category |
| `addCategory(name)` | `void` | Insert a new category |
| `addSubCategory(categoryId, name)` | `void` | Insert a new sub-category |
| `deleteCategory(id)` | `void` | Delete a category |
| `deleteSubCategory(id)` | `void` | Delete a sub-category |

**Images**

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `getImagesByCategory(category)` | `List<String>` | Image URLs for a category |
| `getAllImages()` | `List<String>` | All image URLs |

**Likes (Images)**

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `toggleLike(imageUrl)` | `bool` | Like / unlike; returns new state |
| `isImageLiked(imageUrl)` | `bool` | Check if current user liked image |
| `getLikeCount(imageUrl)` | `int` | Total likes for an image |
| `getLikedImages()` | `List<String>` | All images liked by current user |

**Quotes**

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `getQuotes()` | `List<Map>` | All quotes |
| `getQuotesByCategory(category)` | `List<Map>` | Quotes filtered by category |
| `toggleQuoteLike(quoteId)` | `bool` | Like / unlike a quote |
| `isQuoteLiked(quoteId)` | `bool` | Check like status |
| `getQuoteLikeCount(quoteId)` | `int` | Total likes for a quote |

**Face Filters**

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `getFaceFilters()` | `List<Map>` | All face filter records |
| `addFaceFilter(filterData)` | `void` | Insert a new face filter |
| `deleteFaceFilter(id)` | `void` | Delete by UUID |

---

#### `PoseDetectionService`

Wraps `google_mlkit_pose_detection` in stream mode for real-time analysis.

| Method | Returns | Description |
| ------ | ------- | ----------- |
| `processImage(inputImage)` | `List<Pose>` | Detect poses from a camera frame |
| `calculateSimilarity(reference, user)` | `double` (0–100) | Score comparing two poses via joint angles |
| `getPoseFeedback(reference, user)` | `String` | Coaching message (e.g., "Raise Left Arm") |
| `dispose()` | `void` | Release detector resources |

**Feedback threshold:** An angular difference > 25° at any joint triggers a directional coaching message.

---

#### Other Services

| Service | File | Description |
| ------- | ---- | ----------- |
| `FaceDetectionService` | `face_detection_service.dart` | Face bounding box & landmark detection via ML Kit |
| `FaceFilterService` | `face_filter_service.dart` | Positioning & rendering face filter overlays relative to landmarks |
| `FilterAssetService` | `filter_asset_service.dart` | Loads and caches face filter image assets |
| `SelfieSegmentationService` | `selfie_segmentation_service.dart` | Background/foreground segmentation mask generation |
| `TtsService` | `tts_service.dart` | `speak(text)` / `stop()` via `flutter_tts` for voice coaching |
| `AppAssetsService` | `app_assets_service.dart` | Access to bundled assets in `assets/images/` |

---

### 5.2 Models

#### `PhotoModel` — `lib/core/models/photo_model.dart`

| Field | Type | Description |
| ----- | ---- | ----------- |
| `url` | `String` | Supabase Storage URL of the photo |
| `posingInstructions` | `String` | Text coaching for the pose |
| `category` | `String` | Category name |

```dart
factory PhotoModel.fromJson(Map<String, dynamic> json) {
  return PhotoModel(
    url: json['url'] as String,
    posingInstructions: json['posing_instructions'] as String? ??
        'Stand naturally and smile! Ensure good lighting falls on your face.',
    category: json['category'] as String? ?? 'General',
  );
}
```

---

### 5.3 Theme System

| File | Description |
| ---- | ----------- |
| `core/theme/app_theme.dart` | Defines `AppTheme.lightTheme` and `AppTheme.darkTheme` — complete `ThemeData` with colors, Google Fonts typography, card shapes, and button styles |
| `core/theme/theme_provider.dart` | `ChangeNotifier` holding `ThemeMode`; exposes `toggleTheme()` |

Consumed in `SnapIdeasApp`:
```dart
final themeProvider = Provider.of<ThemeProvider>(context);
return MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeProvider.themeMode,
  home: const SplashScreen(),
);
```

---

### 5.4 Shared Widgets

| Widget | File | Description |
| ------ | ---- | ----------- |
| `ScaleButton` | `core/widgets/scale_button.dart` | Pressable button with a subtle scale-down animation on tap |
| `ShimmerPlaceholder` | `core/widgets/shimmer_placeholder.dart` | Shimmer skeleton shown while network images or data are loading |

---

## 6. Database Schema

All tables reside in Supabase (PostgreSQL) with Row-Level Security (RLS) enabled.

### `categories`

| Column | Type | Notes |
| ------ | ---- | ----- |
| `id` | `bigint` | Primary key (auto-increment) |
| `name` | `text` | Category label |

### `sub_categories`

| Column | Type | Notes |
| ------ | ---- | ----- |
| `id` | `bigint` | Primary key |
| `category_id` | `bigint` | FK → `categories.id` |
| `name` | `text` | Sub-category label |

### `images`

| Column | Type | Notes |
| ------ | ---- | ----- |
| `id` | `bigint` | Primary key |
| `url` | `text` | Supabase Storage public URL |
| `category` | `text` | Category name string |
| `posing_instructions` | `text` | Optional coaching text |

### `likes`

| Column | Type | Notes |
| ------ | ---- | ----- |
| `id` | `bigint` | Primary key |
| `user_id` | `uuid` | FK → `auth.users` |
| `image_url` | `text` | URL of the liked image |
| `created_at` | `timestamptz` | Auto-set to UTC now |

**Constraints:** `UNIQUE(user_id, image_url)` — prevents duplicate likes.

**RLS Policies:**
- `SELECT` — public (anyone can read like counts)
- `INSERT` — `auth.uid() = user_id`
- `DELETE` — `auth.uid() = user_id`

### `quotes`

| Column | Type | Notes |
| ------ | ---- | ----- |
| `id` | `bigint` | Primary key |
| `text` | `text` | Quote body |
| `author` | `text` | Optional author name |
| `category` | `text` | Quote category |
| `created_at` | `timestamptz` | Auto-set |

**RLS:** SELECT public; INSERT admin-managed.

### `quote_likes`

| Column | Type | Notes |
| ------ | ---- | ----- |
| `id` | `bigint` | Primary key |
| `user_id` | `uuid` | FK → `auth.users` |
| `quote_id` | `bigint` | FK → `quotes.id` |
| `created_at` | `timestamptz` | Auto-set |

**Constraints:** `UNIQUE(user_id, quote_id)`

**RLS Policies:** Same pattern as `likes`.

### `face_filters`

| Column | Type | Default | Notes |
| ------ | ---- | ------- | ----- |
| `id` | `uuid` | `uuid_generate_v4()` | Primary key |
| `name` | `text` | — | Display name |
| `type` | `text` | — | `'asset'`, `'procedural'`, or `'none'` |
| `icon_url` | `text` | — | Thumbnail icon URL |
| `asset_url` | `text` | — | Overlay image URL |
| `anchor` | `text` | — | Face region (`'eyes'`, `'forehead'`, etc.) |
| `scale` | `float` | `1.0` | Scale factor |
| `offset_x` | `float` | `0.0` | Horizontal pixel offset |
| `offset_y` | `float` | `0.0` | Vertical pixel offset |
| `params` | `jsonb` | `{}` | Extra configuration |
| `created_at` | `timestamptz` | UTC now | Auto-set |

**RLS:** SELECT public; INSERT authenticated users only.

### SQL Setup Scripts (run in order)

| Script | Purpose |
| ------ | ------- |
| `supabase_setup.sql` | Initial project setup |
| `supabase_schema.sql` | `likes`, `quotes`, `quote_likes` tables + RLS |
| `face_filters_schema.sql` | `face_filters` table + default filter entries |
| `quotes_schema.sql` | Quotes-specific schema additions |
| `quotes_data.sql` | Seed data for quotes |
| `update_schema.sql` | Schema migrations / updates |
| `fix_profiles_bucket.sql` | Profile image storage bucket policy |
| `fix_storage_and_schema.sql` | Storage permissions fix |
| `setup_face_filters_bucket.sql` | Face filter storage bucket setup |

---

## 7. State Management

| Provider | Scope | Responsibility |
| -------- | ----- | -------------- |
| `ThemeProvider` | Global (app root) | Holds `ThemeMode`; exposes `toggleTheme()` |

All other screens use `StatefulWidget` + `setState()` for local UI state, or consume `SupabaseService` static methods directly inside `FutureBuilder` / `StreamBuilder` widgets. There are no additional global providers.

---

## 8. AI / ML Pipeline

The Magic Camera screen orchestrates a three-model ML pipeline running in parallel on each camera frame:

```
┌─────────────────────────────────────────────────┐
│                  Camera Frame                    │
└────────────┬──────────────┬──────────────────────┘
             │              │               │
             ▼              ▼               ▼
    ┌─────────────┐  ┌────────────┐  ┌───────────────────┐
    │    Pose     │  │   Face     │  │    Selfie          │
    │  Detection  │  │ Detection  │  │  Segmentation      │
    └──────┬──────┘  └─────┬──────┘  └────────┬──────────┘
           │               │                   │
           ▼               ▼                   ▼
    Similarity         Face Filter        Background
    Score (0-100)      Overlay            Mask
           │
           ▼
    Voice Coaching
    (flutter_tts)
```

### Pose Similarity Algorithm

The algorithm compares 4 key joint-angle triplets between the reference pose (from the selected photo) and the user's live pose:

| # | Triplet | Body Area |
|---|---------|-----------|
| 1 | Left Shoulder → Left Elbow → Left Wrist | Left arm bend |
| 2 | Left Hip → Left Shoulder → Left Elbow | Left arm raise |
| 3 | Right Shoulder → Right Elbow → Right Wrist | Right arm bend |
| 4 | Right Hip → Right Shoulder → Right Elbow | Right arm raise |

**Steps:**
1. Compute angle at the middle joint using dot-product of two edge vectors
2. Require landmark likelihood ≥ 0.5 for a valid reading
3. Calculate absolute degree difference between reference and user angles
4. Average differences across all valid joints
5. Map to a 0–100 score: `score = clamp(1 − avgDiff / 90, 0, 1) × 100`

**Feedback trigger:** Any joint with a difference > 25° produces a directional message (e.g., "Raise Left Arm", "Bend Right Arm", "Straighten Left Arm").

---

## 9. Getting Started

### Prerequisites

- Flutter SDK **≥ 3.9.0** — [flutter.dev/get-started](https://flutter.dev/get-started)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with the Flutter & Dart plugins
- A Supabase project — [supabase.com](https://supabase.com)

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd photo_ideas_app

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate launcher icons
flutter pub run flutter_launcher_icons

# 4. Run in debug mode (connected device or emulator)
flutter run

# Target a specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## 10. Configuration

### Supabase Credentials

Open `lib/main.dart` and replace the placeholder values:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

> **Security note:** The `anonKey` is the public anon key — safe for client inclusion.
> Never use or commit your Supabase **service-role key** in the client app.

### Asset Structure

```
assets/
└── images/
    ├── icon.png        # App launcher icon (required by flutter_launcher_icons)
    └── ...             # Additional bundled images
```

### Android Permissions

The following permissions are needed in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Permissions

The following keys must be added to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>SnapIdeas needs camera access for the Magic Camera feature.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SnapIdeas needs photo library access to save and upload images.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>SnapIdeas needs permission to save photos to your library.</string>
```

---

## 11. Platform Support

| Platform | Status | Notes |
| -------- | ------ | ----- |
| Android | ✅ Full | Min SDK 21; all features including camera & ML Kit supported |
| iOS | ✅ Full | Permission keys in `Info.plist` required; all features supported |
| Web | ⚠️ Partial | Camera limited to browser APIs; ML Kit not fully supported on web |
| Windows | ✅ Scaffold | Launcher icon generated; camera / ML Kit availability varies |
| macOS | ✅ Scaffold | Same caveats as Windows |
| Linux | ✅ Scaffold | Same caveats as Windows |

---

*Developed with ❤️ for photographers everywhere — SnapIdeas v3.1.1+5*
