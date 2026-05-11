// FirebaseAuthService.js
import { 
    initializeAuth, 
    getAuth,
    getReactNativePersistence,
    signInWithEmailAndPassword, 
    createUserWithEmailAndPassword, 
    updateProfile, 
    sendPasswordResetEmail, 
    signOut, 
    GoogleAuthProvider, 
    OAuthProvider,
    signInWithCredential
} from 'firebase/auth';
import AsyncStorage from '@react-native-async-storage/async-storage';
import app from './firebaseConfig'; 
import { firestoreService } from './FirestoreService';
import { createAppUser, AuthProvider } from './AppUser';

// Fast Refresh (Canlı yenileme) sırasında tekrar başlatmayı engellemek için dışarıda tutuyoruz
let authInstance;

class FirebaseAuthService {
    constructor() {
        if (!authInstance) {
            try {
                authInstance = initializeAuth(app, {
                    persistence: getReactNativePersistence(AsyncStorage)
                });
            } catch (error) {
                // Eğer daha önce başlatıldıysa (already-initialized hatası), var olanı al
                authInstance = getAuth(app);
            }
        }
        this.auth = authInstance;
    }

    get currentUserId() {
        return this.auth.currentUser ? this.auth.currentUser.uid : null;
    }

    get isLoggedIn() {
        return this.auth.currentUser !== null;
    }

    get currentFirebaseUser() {
        return this.auth.currentUser;
    }

    // ==========================================
    // E-POSTA İLE GİRİŞ
    // ==========================================
    async signInWithEmail(email, password) {
        try {
            const result = await signInWithEmailAndPassword(this.auth, email, password);
            return await this.fetchOrCreateUser(result.user, AuthProvider.EMAIL);
        } catch (error) {
            console.error("FirebaseAuthService signInWithEmail hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // E-POSTA İLE KAYIT OL
    // ==========================================
    async signUpWithEmail(email, password, displayName) {
        try {
            const result = await createUserWithEmailAndPassword(this.auth, email, password);
            const firebaseUser = result.user;

            const appUser = createAppUser({
                uid: firebaseUser.uid,
                displayName: displayName,
                email: email,
                authProvider: AuthProvider.EMAIL,
                hasCompletedOnboarding: false
            });

            // 1. Önce Firestore'a kaydet
            await firestoreService.saveUser(appUser);

            // 2. Profil ismini güncelle (hata alınsa bile işlemi durdurmaz)
            try {
                await updateProfile(firebaseUser, { displayName: displayName });
            } catch (profileError) {
                console.warn("Profil ismi güncellenirken hata (önemsiz):", profileError);
            }

            return appUser;
        } catch (error) {
            console.error("FirebaseAuthService signUpWithEmail hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // GOOGLE İLE GİRİŞ (Expo Go için GoogleSignin gibi kütüphanelerden dönen idToken kullanılır)
    // ==========================================
    async signInWithGoogle(idToken) {
        try {
            const credential = GoogleAuthProvider.credential(idToken);
            const result = await signInWithCredential(this.auth, credential);
            return await this.fetchOrCreateUser(result.user, AuthProvider.GOOGLE);
        } catch (error) {
            console.error("FirebaseAuthService signInWithGoogle hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // APPLE İLE GİRİŞ
    // ==========================================
    async signInWithApple(idToken, rawNonce) {
        try {
            const provider = new OAuthProvider('apple.com');
            const credential = provider.credential({
                idToken: idToken,
                rawNonce: rawNonce
            });
            const result = await signInWithCredential(this.auth, credential);
            return await this.fetchOrCreateUser(result.user, AuthProvider.APPLE);
        } catch (error) {
            console.error("FirebaseAuthService signInWithApple hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // ŞİFREMİ UNUTTUM
    // ==========================================
    async resetPassword(email) {
        try {
            await sendPasswordResetEmail(this.auth, email);
        } catch (error) {
            console.error("FirebaseAuthService resetPassword hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // ÇIKIŞ YAP
    // ==========================================
    async signOut() {
        try {
            await signOut(this.auth);
        } catch (error) {
            console.error("FirebaseAuthService signOut hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // YARDIMCI METOTLAR
    // ==========================================
    async fetchOrCreateUser(firebaseUser, authProvider) {
        try {
            // Kullanıcı profilini çekmeye çalış
            const existingUser = await firestoreService.getUser(firebaseUser.uid);
            return existingUser;
        } catch (error) {
            // İlk giriş: Yeni profil oluştur
            const newUser = createAppUser({
                uid: firebaseUser.uid,
                displayName: firebaseUser.displayName || "Kullanıcı",
                email: firebaseUser.email || "",
                photoURL: firebaseUser.photoURL,
                authProvider: authProvider,
                hasCompletedOnboarding: false
            });

            await firestoreService.saveUser(newUser);
            return newUser;
        }
    }
}

export const firebaseAuthService = new FirebaseAuthService();
