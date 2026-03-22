# Magic English – All-in-One English Learning App

A comprehensive mobile application for learning English with AI-powered vocabulary enrichment and grammar checking.

## 📱 Project Overview

**Magic English** is a full-stack learning application that combines mobile innovation with backend intelligence to help users master English language skills.

### Core Modules
1. **Smart Vocabulary Notebook** - Add, organize, and learn English words with AI-enriched data
2. **Grammar & Style Checker** - Real-time grammar and spelling analysis
3. **Learning Progress Dashboard** - Track streaks, visualize learning patterns with charts

---

## 🏗️ System Architecture

```
┌─────────────────────────────┐
│   Flutter Mobile App        │
│  (iOS/Android/Web)          │
└──────────────┬──────────────┘
               │ HTTP REST API
               ▼
┌─────────────────────────────┐
│  .NET 8 Web API Backend     │
│  (C# Entity Framework Core)  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   SQL Server Database       │
└─────────────────────────────┘

External AI Service:
┌─────────────────────────────┐
│   Ollama Cloud API          │
│  (Vocabulary & Grammar AI)   │
└─────────────────────────────┘
```

---

## 🛠️ Tech Stack

### Backend
- **Language**: C#
- **Framework**: .NET 8 Web API
- **ORM**: Entity Framework Core
- **Database**: SQL Server
- **Architecture**: REST API

### Mobile
- **Framework**: Flutter
- **Language**: Dart
- **HTTP Client**: http package
- **State Management**: Provider/Riverpod
- **Charts**: fl_chart

### AI Integration
- **Service**: Ollama Cloud API
- **Use Cases**: Vocabulary enrichment, Grammar checking

### Development
- **IDE**: Visual Studio Code
- **Version Control**: Git

---

## 📁 Project Structure

```
Magic_English/
├── Backend/                          # .NET 8 Web API
│   ├── MagicEnglishAPI/
│   │   ├── Controllers/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Data/
│   │   ├── Migrations/
│   │   └── appsettings.json
│   └── MagicEnglishAPI.sln
│
├── Mobile/                           # Flutter App
│   └── magic_english/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── screens/
│       │   ├── widgets/
│       │   ├── services/
│       │   └── models/
│       └── pubspec.yaml
│
├── Database/                         # SQL Server Scripts
│   ├── schema.sql
│   └── seed_data.sql
│
├── Documentation/                    # Project Documentation
│   ├── API_DOCUMENTATION.md
│   ├── DATABASE_DESIGN.md
│   ├── SETUP_GUIDE.md
│   └── AI_PROMPTS.md
│
└── README.md                         # This file
```

---

## 📋 Quick Start

### Prerequisites
- .NET 8 SDK
- SQL Server 2019 or higher
- Flutter SDK (latest stable)
- Visual Studio Code
- Ollama Cloud API key

### Step-by-Step Setup

1. **Backend Setup** (See Backend folder)
   - Create .NET 8 project
   - Configure SQL Server connection
   - Run Entity Framework migrations
   - Configure Ollama API integration
   - Start API server on http://localhost:5000

2. **Database Setup** (See Database folder)
   - Run SQL Server scripts to create schema
   - Tables: Users, Vocabulary, GrammarChecks, StudyActivities, Streaks

3. **Mobile Setup** (See Mobile folder)
   - Create Flutter project
   - Install dependencies
   - Configure API endpoint
   - Run on emulator or device

---

## 🎯 Feature Roadmap

### Phase 1: Core Features
- [x] Project structure
- [ ] User authentication (Login/Register)
- [ ] Vocabulary management (CRUD)
- [ ] Grammar checker
- [ ] Basic dashboard
- [ ] Study tracking

### Phase 2: Advanced Features
- [ ] Streak system with badges
- [ ] Advanced charts and analytics
- [ ] Offline vocabulary mode
- [ ] Word pronunciation (Text-to-Speech)
- [ ] Spaced repetition algorithm

### Phase 3: Polish
- [ ] UI/UX refinement
- [ ] Performance optimization
- [ ] Testing (Unit, Integration)
- [ ] Documentation polish
- [ ] App store preparation

---

## 📚 Documentation

Detailed documentation is available in the `Documentation/` folder:

- **API_DOCUMENTATION.md** - Complete API endpoint reference
- **DATABASE_DESIGN.md** - Database schema and relationships
- **SETUP_GUIDE.md** - Step-by-step setup instructions
- **AI_PROMPTS.md** - Ollama API prompt engineering

---

## 👨‍💻 Development Guidelines

- Follow C# coding standards (PascalCase for public members)
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Comment complex logic
- Write clean, university-grade code
- Use proper error handling
- Implement logging

---

## 📞 Support

For questions or issues, refer to the Documentation folder for detailed guides.

---

## 📄 License

This project is for educational purposes.

---

**Last Updated**: March 11, 2026
