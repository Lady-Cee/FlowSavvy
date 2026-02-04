# PeriodReal (former FlowSavvy) 🩸💡

**PeriodReal (former FlowSavvy)** is a smart menstrual hygiene assistant app built with Flutter. It empowers users—especially women and girls—to ask health-related questions around menstrual hygiene and get reliable answers powered by Google's **Gemini AI**.

---

## 🚀 Features

- 🤖 **AI-Powered Q&A** using Gemini
- 💬 Ask any menstrual hygiene–related question
- 🔄 View and manage recent queries and responses
- ♻️ Clear history with one tap
- 🧠 Smart, fast, and user-friendly interface
- 🎯 Built with Flutter + Provider for state management

---

## 🧱 Tech Stack

- **Flutter**
- **Dart**
- **Provider** (state management)
- **Flutter_Gemini** (Gemini API integration)
- **flutter_dotenv** (environment variable management)

---

## 📲 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/yourusername/flowsavvy.git
cd flowsavvy
2. Install Dependencies
bash
Copy
Edit
flutter pub get
3. Setup .env File
Create a .env file in the root directory with the following content:

env
Copy
Edit
GEMINI_API_KEY=your_gemini_api_key_here
⚠️ Important: Never share your API key publicly.

4. Run the App
bash
Copy
Edit
flutter run
📁 Project Structure
bash
Copy
Edit
lib/
├── models/
│   └── gemini_response_model.dart         # Model for storing Gemini responses
├── providers/
│   └── gemini_provider.dart               # Provider for managing API and state
├── screens/
│   └── gemini_search_screen.dart          # Main UI screen for the app
├── main.dart                              # App entry point
📸 Screenshots
Add screenshots of your app here (e.g. question input, AI responses, loading state).

📦 Build for Release
Android
bash
Copy
Edit
flutter build apk --release
iOS
bash
Copy
Edit
flutter build ios --release
For iOS, make sure you have Xcode setup and a valid provisioning profile.

👩💻 Author
Cynthia Enweonwu-Arinze
Mobile App Developer | Women Techmakers Ambassador
🌐 LinkedIn
🐦 Twitter

🛡 License


💡 Inspiration
FlowSavvy was developed to empower women and girls to access accurate, stigma-free information about menstrual hygiene. By leveraging AI, we aim to provide a safe, inclusive, and smart way to stay informed.
