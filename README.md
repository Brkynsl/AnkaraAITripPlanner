# Ankara AI Trip Planner 🚀

Ankara AI Trip Planner, kullanıcılara bütçelerine ve tercihlerine göre optimize edilmiş, yapay zeka destekli seyahat planları sunan modern bir iOS uygulamasıdır.

## 📱 Uygulama Görselleri

| Giriş Ekranı | Ana Sayfa | Seyahat Planla | Bütçe ve Rota Dağılımı | Günlük Gezi Planı |
| :---: | :---: | :---: | :---: | :---: |
| ![Login](Screenshots/login.png) | ![Home](Screenshots/home.png) | ![Planla](Screenshots/plan_olustur.png) | ![Rota Detay](Screenshots/rotam_detay.png) | ![Günlük Plan](Screenshots/gunluk_program.png) |

## 🛠 Kullanılan Teknolojiler

- **Dil:** Swift 5.9+
- **Mimari:** MVVM (Model-View-ViewModel) + Coordinator-like Navigation
- **Arayüz:** UIKit (Tamamen Programatik UI - Auto Layout)
- **Backend:** Firebase
  - **Authentication:** E-posta/Şifre, Apple Sign-In, Google Sign-In
  - **Firestore:** Kullanıcı profilleri, seyahat planları ve senkronizasyon
- **Grafik & Animasyon:**
  - **CoreGraphics:** Özel çizimler (CityScapeView)
  - **UIKit Animations:** Yumuşak geçişler ve pulsing efektleri
- **Yardımcılar:**
  - **HapticManager:** Dokunsal geri bildirim (Taptic Engine)
  - **FormValidator:** Güvenli ve dinamik girdi kontrolü

## 🧠 Uygulama Mantığı ve AI Motoru

Uygulamanın kalbinde yer alan **AITripPlannerService**, kullanıcıdan alınan şehir, gün sayısı ve bütçe verilerini işleyerek üç farklı seyahat stratejisi oluşturur:

1.  **Ekonomik & Optimize Rota:** Ulaşım ve konaklamada maksimum tasarruf, halka açık gezi noktaları.
2.  **Dengeli Konfor:** Şehir merkezine yakın, 3-4 yıldızlı oteller ve optimize edilmiş ulaşım.
3.  **Premium Deneyim:** VIP ulaşım seçenekleri, 5 yıldızlı konaklama ve özel restaurant önerileri.

Sistem, gidilecek şehri analiz ederek o şehre özel (Ankara, İstanbul, İzmir vb.) landmark ve aktivite verilerini rotaya dinamik olarak enjekte eder.

## ✨ Öne Çıkan Özellikler

- ✅ **Anlık AI Yanıtları:** Optimize edilmiş asenkron veri işleme.
- ✅ **Karanlık Mod Desteği:** Tüm UI bileşenleri sistem temasına %100 uyumludur.
- ✅ **Responsive Tasarım:** Tüm iPhone modellerinde (SE'den Max'e) kusursuz görünüm.
- ✅ **Güvenli Bulut Kayıt:** Rotalarınız Firebase üzerinden tüm cihazlarınızda senkronize edilir.

## 🚀 Kurulum

1. Bu projeyi klonlayın: `git clone https://github.com/Brkynslye/AnkaraAITripPlanner.git`
2. `GoogleService-Info.plist` dosyanızı projeye ekleyin.
3. Firebase console üzerinden Firestore ve Authentication servislerini aktif edin.
4. Uygulamayı çalıştırın!

---
Developed by **Berkay Ünsal**
