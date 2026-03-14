# Ankara AI Trip Planner - Kurulum ve Storyboard Rehberi

Bu rehber, koda dökülen dosyaları Storyboard üzerinde nasıl bağlayacağınızı ve Firebase entegrasyonunu nasıl tamamlayacağınızı adım adım açıklamaktadır. Tüm kodlar hazır, sadece bu son adımlarla projeyi Build edilebilir hale getireceğiz.

## 1. Firebase Kurulumu

1. **Firebase Console'da Proje Oluşturun:**
   - [Firebase Console](https://console.firebase.google.com)'a gidin ve yeni bir proje oluşturun.
   - Projenize iOS uygulaması ekleyin. Bundle ID olarak projenizin Bundle Identifier'ını (örneğin: `com.sizinadiniz.AnkaraAITripPlanner`) girin.

2. **GoogleService-Info.plist Dosyasını Ekleyin:**
   - Firebase'in size verdiği `GoogleService-Info.plist` dosyasını indirin.
   - Xcode'u açın ve bu dosyayı projenizin ana dizinine (AppDelegate'in olduğu dizin) sürükleyip bırakın. `Copy items if needed` seçeneğinin işaretli olduğundan emin olun.

3. **SPM (Swift Package Manager) ile Firebase SDK'larını Ekleyin:**
   - Xcode'da `File > Add Packages...` seçeneğine tıklayın.
   - Arama çubuğuna `https://github.com/firebase/firebase-ios-sdk` yapıştırın.
   - Paketi ekleyin ve projenizde kullanacağımız şu modülleri seçin:
     - `FirebaseAuth`
     - `FirebaseFirestore`
     - `FirebaseFirestoreSwift`

4. **Authentication ve Firestore'u Aktifleştirin:**
   - Firebase Console'da sol menüden **Authentication**'a girip "Get Started" deyin. Sign-in method olarak "Email/Password", "Google" ve "Apple" seçeneklerini aktifleştirin.
   - **Firestore Database** sekmesine girip veritabanını test modunda oluşturun.

---

## 2. Storyboard Bağlantıları (Main.storyboard)

Kodlarını oluşturduğumuz View Controller'ları Storyboard'da görsel olarak tasarlayıp ilgili class'lara atamamız gerekiyor.

### OnboardingContainerViewController
- Storyboard'a bir `UIViewController` ekleyin.
- Identity Inspector'dan (Sağ paneldeki 4. sekme) Class kısmına `OnboardingContainerViewController` yazın.
- Storyboard ID kısmına `OnboardingContainerViewController` yazın. (SceneDelegate bu ID ile ekranı bulup açacak)

### LoginViewController
- Storyboard'a yeni bir `UIViewController` ekleyin.
- Class ve Storyboard ID'yi `LoginViewController` yapın.
- İlgili butonları ve text field'ları arayüze eklediğinizde IBOutlet ve IBAction bağlantılarını yapabilirsiniz.
- Kayıt Ol ekranı (`RegisterViewController`) ve Şifremi Unuttum ekranı (`ForgotPasswordViewController`) için iki ayrı VC daha ekleyip Class'larını verin.
- Login ekranındaki "Kayıt Ol" butonundan, `RegisterViewController`'a **Show** segue'si çekin. Aynı şekilde "Şifremi Unuttum" için de yapın.

### MainTabBarController
- Storyboard'a bir `UITabBarController` ekleyin.
- Class ve Storyboard ID'yi `MainTabBarController` yapın.
- Ana ekrana ait olan 3 adet View Controller'ı (Ana Sayfa, Tatilim, Profilim) bu Tab Bar'a bağlayın (Tab Bar'dan bu ekranlara Sağ tık > sürükle > `view controllers`).
- Bu 3 ekranın class'larını sırasıyla şu şekilde atayın: 
  - Sekme 1: `HomeViewController`
  - Sekme 2: `MyTripViewController`
  - Sekme 3: `ProfileViewController`

### Yönlendirme Hakkında Not
Ok işareti ("Is Initial View Controller") artık storyboard üzerinde nerede olursa olsun, uygulama açılışında `SceneDelegate` dosyasında yazdığımız kod devreye girecektir. `SceneDelegate` Firebase oturum durumunu kontrol edip kullanıcıyı doğru ekrana otomatik yönlendirecektir. Bu yüzden yukarıdaki 3 ana ekranın (OnboardingContainer, Login, MainTabBar) **Storyboard ID** verilerinin birebir eşleştiğinden emin olun.
