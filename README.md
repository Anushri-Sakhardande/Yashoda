# 🤰 Yashoda

A comprehensive and empathetic mobile application built with Flutter and Firebase to support expecting mothers, new mothers, and women who have experienced miscarriage. This app offers health reminders, emotional support, community engagement, fitness tracking, medical data monitoring, appointment booking, announcements from health administrators, and an integrated chatbot for instant assistance.

---

## ✨ Features

- **User Roles**: Register as Pregnant, New Mother, or Miscarried for a tailored experience.
- **Profile Management**: View and update personal health data and life stage.
- **Health Reminders**: Receive notifications for doctor visits, vaccinations, hydration, and medications.
- **Health Monitoring**: Record and visualize changes in haemoglobin, weight, sugar, and blood pressure.
- **Chatbot Support**: Built-in chatbot answers user queries instantly (uses OpenAI API).
- **Community Support**: Connect with other mothers and share experiences or concerns.
- **Appointment Booking**: Schedule and manage appointments with health administrators.
- **Announcements**: Receive updates on local health camps and vaccine drives.
- **Gamification**: Boost engagement with light-hearted, interactive content.

---

## 🛠 Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Push Notifications**: Local Notifications + FCM
- **Chatbot**: OpenAI API

---

## 🔐 OpenAI API Setup

The chatbot feature in `services/chat-service` requires an OpenAI API key.

> **Please add your API key to the following file:**

```
lib/services/chat_service.dart
```

```dart
final openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
```

Make sure **not to expose your key in public repositories.**

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Firebase Project
- OpenRouter API Key (for chatbot)

### Installation

```bash
git clone https://github.com/Anushri-Sakhardande/Yashoda.git
cd yashoda
flutter pub get
```

### Firebase Setup

- Add your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS).
- Enable **Authentication**, **Firestore**, and **Cloud Messaging** in your Firebase console.

### Run the App

```bash
flutter run
```

---

## 🤝 Contributions

@cygnus06
@sindhu964
@Anushri-Sakhardande


<a href="https://github.com/Anushri-Sakhardande/Yashoda/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Anushri-Sakhardande/Yashoda" />
</a>


---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ❤️ Acknowledgements

- OpenAI for the powerful GPT API
- Firebase for the free-tier backend
- Flutter Devs for community packages and design inspiration
- Authors' mother's for the advice and guidance

---
