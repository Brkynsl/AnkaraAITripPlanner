// useOnboardingViewModel.js
// React Native / React Hook formatında OnboardingViewModel

import { useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { firestoreService } from './FirestoreService';
import { firebaseAuthService } from './FirebaseAuthService';

export const OnboardingPages = [
    {
        title: "Bütçene Uygun Plan",
        description: "Toplam bütçeni gir, yapay zeka senin için en uygun tatil planını oluştursun. Ulaşım, konaklama ve aktivitelerin bütçene göre optimize edilir.",
        iconName: "wallet.pass.fill", // React Native Vector Icons vb. ile map edilebilir
        accentColor: "#00C7BF"
    },
    {
        title: "Ulaşım + Otel + Gezi",
        description: "Uçak, otobüs veya tren seçeneklerini karşılaştır. Bütçene uygun oteller bul. Müze, park ve restoran önerileri al — hepsi tek ekranda.",
        iconName: "airplane.departure",
        accentColor: "#FF9500"
    },
    {
        title: "Alternatif Rotalar",
        description: "Tek plan yerine 2-3 farklı alternatif sunulur: ekonomik, dengeli ve konforlu. Aynı bütçeyle farklı tatil deneyimlerini keşfet.",
        iconName: "arrow.triangle.branch",
        accentColor: "#AF52DE"
    },
    {
        title: "Haritada Tüm Tatilini Gör",
        description: "Otelden müzeye, restorana kadar tüm gezi noktalarını harita üzerinde gör. Mesafeleri, ulaşım seçeneklerini ve rotanı tek bakışta anla.",
        iconName: "map.fill",
        accentColor: "#34C759"
    }
];

export function useOnboardingViewModel() {
    const totalPages = OnboardingPages.length;

    const isLastPage = (index) => {
        return index === totalPages - 1;
    };

    // Onboarding tamamlandığında AsyncStorage ve Firestore'a kaydet
    const completeOnboarding = async () => {
        try {
            await AsyncStorage.setItem('hasCompletedOnboarding', 'true');
            
            const uid = firebaseAuthService.currentUserId;
            if (uid) {
                await firestoreService.updateOnboardingStatus(uid, true);
            }
            return true;
        } catch (error) {
            console.log("⚠️ Onboarding durumu kaydedilemedi:", error);
            // AsyncStorage hatası dahi olsa akışa devam et
            return true; 
        }
    };

    // Onboarding daha önce tamamlanmış mı?
    const checkHasCompletedOnboarding = async () => {
        try {
            // Önce yerel AsyncStorage'ı kontrol et
            const localStatus = await AsyncStorage.getItem('hasCompletedOnboarding');
            if (localStatus === 'true') {
                return true;
            }

            // Yoksa Firestore'dan kontrol et
            const uid = firebaseAuthService.currentUserId;
            if (!uid) return false;

            const user = await firestoreService.getUser(uid);
            if (user && user.hasCompletedOnboarding) {
                await AsyncStorage.setItem('hasCompletedOnboarding', 'true');
                return true;
            }

            return false;
        } catch (error) {
            return false;
        }
    };

    return {
        pages: OnboardingPages,
        totalPages,
        isLastPage,
        completeOnboarding,
        checkHasCompletedOnboarding
    };
}
