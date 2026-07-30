# CorridorShare (Monorepo)

**CorridorShare** is a peer-to-peer crowd-shipping and highway corridor parcel delivery platform connecting travelers with senders across Bangladesh.

[![Vercel Deployment](https://img.shields.io/badge/Vercel-Deployed-success?style=flat-square&logo=vercel)](https://corridorshare.vercel.app) ![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=flat-square)

---

## 📁 Repository Structure

```
CorridorShare/
├── corridorshare-website/   # Next.js 16 Web Application (React 19, TailwindCSS, Supabase)
└── corridorshare-app/       # Flutter Mobile Application (iOS & Android)
```

---

## 🚀 Projects Overview

### 1. 🌐 CorridorShare Website (`/corridorshare-website`)
- **Framework**: Next.js 16 (App Router, React 19)
- **Styling**: TailwindCSS v4 with dynamic dark/light design system
- **Mapping**: Leaflet & OpenStreetMap with OSRM snapped highway route calculations
- **Backend**: Supabase Auth, PostgreSQL, and storage integration with LocalStorage mock fallbacks

### 2. 📱 CorridorShare App (`/corridorshare-app`)
- **Framework**: Flutter (Dart)
- **Platforms**: Android & iOS

---

## 🛠️ Development Setup

### Website:
```bash
cd corridorshare-website
npm install
npm run dev
```

### App:
```bash
cd corridorshare-app
flutter pub get
flutter run
```
