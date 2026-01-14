# 🚑 ResQ-Net: Real-time Emergency Response Grid

> **Bridging the gap between First Responders and Hospitals using Multimodal AI.**

![Project Status](https://img.shields.io/badge/Status-Prototype-orange)
![Hackathon](https://img.shields.io/badge/Hackathon-TechSprint_2024-blue)
![Tech Stack](https://img.shields.io/badge/Powered_by-Google_Cloud-green)

## 📄 Problem Statement
In critical medical emergencies, the "Golden Hour" is often lost due to information asymmetry. Paramedics lack real-time data on hospital bed availability, while hospitals are "blind" to the patient's condition until arrival. This disconnect leads to delayed treatment and inefficient resource allocation.

## 💡 The Solution
**ResQ-Net** is a hybrid platform that synchronizes data between ambulances and hospitals in real-time.
1.  **For Paramedics:** A mobile-first interface to find the nearest *ready* hospital and use AI to dictate patient vitals.
2.  **For Hospitals:** A live dashboard that alerts staff of incoming critical patients with an AI-generated triage report before the ambulance arrives.

## ✨ Key Features

### 🚑 Paramedic App (Mobile)
* **One-Tap Bed Finder:** Filters hospitals by specific emergency requirements (e.g., "Need Ventilator") and suggests ETA using **Google Maps Routes API**.
* **AI Visual Triage:** Uses **Google Gemma** to analyze video/images of injuries and estimate severity/blood loss instantly.
* **Voice-to-Data:** Paramedics speak patient details; the app converts it into a structured medical report.
* **Offline Mode:** Works in low-network zones and syncs data via **Firestore Offline Persistence** when connectivity returns.

## 🛠️ Technology Stack

We leveraged the **Google Cloud Ecosystem** to build a scalable and intelligent solution:

| Component | Technology Used | Purpose |
| :--- | :--- | :--- |
| **Generative AI** | **Google Gemma(MedSigLip)** | Multimodal analysis (Video/Audio) for automated triage reports. |
| **Geolocation** | **Google Maps Platform** | Routes API for "Green Corridor" navigation & Distance Matrix for ETA. |
| **Backend/DB** | **Firebase (Firestore)** | Real-time database for sub-second syncing between Ambulance & Hospital. |
| **Logic** | **Google Cloud Functions** | Serverless triggers for "Code Blue" alerts based on severity. |
| **Frontend** | **Flutter / React** | Cross-platform UI for Paramedic App and Admin Dashboard. |

## 🏗️ Architecture


* **Input:** Paramedic captures Audio/Video.
* **Processing:** Gemini API processes media -> Extracts Vitals -> Assigns Triage Score.
* **Routing:** Google Maps API calculates the fastest route to a hospital with `status: available`.
* **Sync:** Firebase pushes the "Incoming Patient" alert to the specific Hospital ID.

## 🚀 Getting Started

### Prerequisites
* Node.js (v18+) or Flutter SDK
* Firebase Project

### Installation
1.  Clone the repo:
    ```bash
    git clone https://github.com/omkarkarale/ResQ-Net-Hackathon.git
    ```
2.  Install dependencies:
    ```bash
    npm install
    # or
    flutter pub get
    ```
4.  Run the App:
    ```bash
    npm start
    # or
    flutter run
    ```

## 🔮 Future Scope
* **Smart Traffic Integration:** API integration with city traffic lights to automate Green Corridors.
* **Wearable Sync:** Auto-fetch patient heart rate from smartwatches.
  
## 👥 Team
* **Member 1:** Omkar Karale - Full Stack Dev
* **Member 2:** Pratik Devang - Back End Dev
* **Member 3:** Surabhi Chopadekar - UI/UX Design
* **Member 4:** Kunal Soni - FireBase/FireStore & Cloud Storage

---
*Built for TechSprint 2025 (VESIT).*
