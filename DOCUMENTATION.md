# SnapIdeas: Your Professional Posing Guide

SnapIdeas is a cutting-edge Flutter application designed to help photographers and models achieve the perfect shot. Utilizing AI-powered pose detection and a vast library of creative ideas, SnapIdeas simplifies the art of posing.

## 🚀 Key Features

- **Pose Detection**: Real-time AI pose estimation using Google ML Kit to guide users into the perfect position.
- **Inspiration Library**: A curated collection of photo ideas categorized by style, location, and subject.
- **AI Guidance**: Dynamic feedback to help adjust posture and framing.
- **Favorites & Collections**: Save your favorite poses for quick access during shoots.
- **Admin Portal**: Specialized tools for content management and app configuration.
- **Quotes Feature**: Integrated motivational and instructional quotes to inspire your creativity.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI)
- **Backend**: [Supabase](https://supabase.com/) (Auth, Database, Storage)
- **AI/ML**: [Google ML Kit](https://developers.google.com/ml-kit) (Pose Detection, Selfie Segmentation)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Key Dependencies**:
  - `google_mlkit_pose_detection`
  - `supabase_flutter`
  - `camera`
  - `cached_network_image`

## 📂 Project Architecture

The project follows a **feature-first** organizational structure for scalability and maintainability:

- `lib/core`: Shared resources, models, and global utilities.
- `lib/features`: Core app functionality divided into domain-specific modules.
  - `auth`: User authentication and session management.
  - `home`: Main discovery and navigation hub.
  - `images`: AI-powered camera and image processing.
  - `admin`: Back-end management interface.
  - `profile`: User-specific settings and saved content.
- `lib/utils`: Helper functions and constants.

## 📥 Getting Started

### Prerequisites
- Flutter SDK (v3.9.0 or later)
- Dart SDK
- Supabase account (for backend services)

### Installation
1.  **Clone the repository**:
    ```bash
    git clone [repository-url]
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```

## 📝 Configuration

The app integrates with Supabase. Ensure your environment variables or configuration files are set up with your Supabase URL and Anon Key to enable Cloud features.

---
*Developed with ❤️ for photographers everywhere.*
