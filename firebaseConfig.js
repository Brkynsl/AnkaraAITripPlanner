// firebaseConfig.js
import { initializeApp, getApps, getApp } from 'firebase/app';

// TODO: Lütfen Firebase Console'dan (Project Settings -> General -> Web App)
// aldığınız kendi "firebaseConfig" bilgilerinizi buraya yapıştırın.
const firebaseConfig = {
  apiKey: "AIzaSyCFflTun6sYbBa8jNWj4mkFg_nmT3IDdJ8",
  authDomain: "aitripplanner-6f963.firebaseapp.com",
  projectId: "aitripplanner-6f963",
  storageBucket: "aitripplanner-6f963.firebasestorage.app",
  messagingSenderId: "917386762127",
  appId: "app-1-917386762127-ios-97dd225c6706dfeeb91dfa"
};

// Uygulama daha önce başlatılmadıysa başlat
let app;
if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApp();
}

export default app;
