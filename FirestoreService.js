// FirestoreService.js
// Firebase Web SDK kullanılarak yazılmış Firestore servisi (Expo Go ile tam uyumlu)
import { getFirestore, doc, setDoc, getDoc, updateDoc, collection, query, where, getDocs, deleteDoc, serverTimestamp } from 'firebase/firestore';
import { createAppUser } from './AppUser';

class FirestoreService {
    constructor() {
        // App'in başlatılmış bir Firebase instance'ına sahip olduğunu varsayıyoruz
        this.db = getFirestore();
    }

    // ==========================================
    // KULLANICI İŞLEMLERİ
    // ==========================================

    async saveUser(user) {
        try {
            const userRef = doc(this.db, 'users', user.uid);
            await setDoc(userRef, user, { merge: true });
        } catch (error) {
            console.error("FirestoreService saveUser hatası:", error);
            throw error;
        }
    }

    async getUser(uid) {
        try {
            const userRef = doc(this.db, 'users', uid);
            const snapshot = await getDoc(userRef);
            
            if (snapshot.exists()) {
                const data = snapshot.data();
                // Firestore timestamp'i JS Date objesine çevirme
                const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date();
                const updatedAt = data.updatedAt?.toDate ? data.updatedAt.toDate() : null;

                return createAppUser({
                    ...data,
                    uid,
                    createdAt,
                    updatedAt
                });
            } else {
                throw new Error("Kullanıcı profili bulunamadı.");
            }
        } catch (error) {
            throw error;
        }
    }

    async updateUser(uid, data) {
        try {
            const userRef = doc(this.db, 'users', uid);
            await updateDoc(userRef, {
                ...data,
                updatedAt: serverTimestamp()
            });
        } catch (error) {
            console.error("FirestoreService updateUser hatası:", error);
            throw error;
        }
    }

    async updateOnboardingStatus(uid, completed) {
        return this.updateUser(uid, { hasCompletedOnboarding: completed });
    }

    // ==========================================
    // SEYAHAT PLANI İŞLEMLERİ
    // ==========================================

    async saveTrip(trip) {
        try {
            const newTripRef = doc(collection(this.db, 'trips'));
            const tripData = {
                ...trip,
                id: newTripRef.id,
                createdAt: serverTimestamp()
            };
            await setDoc(newTripRef, tripData);
            return newTripRef.id;
        } catch (error) {
            console.error("FirestoreService saveTrip hatası:", error);
            throw error;
        }
    }

    async getTrips(userId) {
        try {
            const tripsRef = collection(this.db, 'trips');
            const q = query(tripsRef, where('userId', '==', userId));
            const snapshot = await getDocs(q);
            
            return snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
        } catch (error) {
            console.error("FirestoreService getTrips hatası:", error);
            throw error;
        }
    }

    async updateTrip(tripId, data) {
        try {
            const tripRef = doc(this.db, 'trips', tripId);
            await updateDoc(tripRef, {
                ...data,
                updatedAt: serverTimestamp()
            });
        } catch (error) {
            console.error("FirestoreService updateTrip hatası:", error);
            throw error;
        }
    }

    async deleteTrip(tripId) {
        try {
            const tripRef = doc(this.db, 'trips', tripId);
            await deleteDoc(tripRef);
        } catch (error) {
            console.error("FirestoreService deleteTrip hatası:", error);
            throw error;
        }
    }

    // ==========================================
    // KULLANICI TERCİHLERİ
    // ==========================================

    async savePreferences(uid, preferences) {
        try {
            const prefRef = doc(this.db, `users/${uid}/preferences/userPreferences`);
            await setDoc(prefRef, preferences, { merge: true });
        } catch (error) {
            console.error("FirestoreService savePreferences hatası:", error);
            throw error;
        }
    }

    async getPreferences(uid) {
        try {
            const prefRef = doc(this.db, `users/${uid}/preferences/userPreferences`);
            const snapshot = await getDoc(prefRef);
            
            if (snapshot.exists()) {
                return snapshot.data();
            } else {
                return null; // Varsayılan değerler dönülebilir
            }
        } catch (error) {
            console.error("FirestoreService getPreferences hatası:", error);
            throw error;
        }
    }
}

export const firestoreService = new FirestoreService();
