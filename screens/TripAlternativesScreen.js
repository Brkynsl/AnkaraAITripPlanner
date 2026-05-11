// TripAlternativesScreen.js
import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { AppColors, AppLayout } from './theme';
import TripPlanCard from './TripPlanCard';
import { firestoreService } from '../FirestoreService';
import { firebaseAuthService } from '../FirebaseAuthService';

export default function TripAlternativesScreen({ route, navigation }) {
    const { city, days, budget, plans } = route.params;
    const [isSaving, setIsSaving] = useState(false);

    const handleSelectPlan = async (selectedPlan, index) => {
        const user = firebaseAuthService.currentFirebaseUser;
        if (!user) {
            Alert.alert("Hata", "Lütfen önce giriş yapın.");
            return;
        }

        setIsSaving(true);
        
        try {
            // Firestore için Trip objesi
            const newTrip = {
                userId: user.uid,
                city: city,
                days: days,
                totalBudget: budget,
                plans: plans,
                selectedPlanIndex: index,
                status: 'planned',
                createdAt: new Date().toISOString()
            };

            await firestoreService.saveTrip(newTrip);
            
            setIsSaving(false);
            Alert.alert("Başarılı", "Plan başarıyla kaydedildi!", [
                { 
                    text: "Tamam", 
                    onPress: () => {
                        // Tatilim sekmesine dön (navigation yapısına göre değişebilir)
                        navigation.navigate('MainTab', { screen: 'MyTrips' });
                    }
                }
            ]);

        } catch (error) {
            setIsSaving(false);
            Alert.alert("Hata", "Plan kaydedilemedi: " + error.message);
        }
    };

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.title}>Sizin İçin 3 Plan Çıkardık</Text>
                <Text style={styles.subtitle}>
                    {city} rotanız için belirlediğiniz bütçeye özel optimize edilmiş alternatifler.
                </Text>
            </View>

            {/* List */}
            <FlatList
                data={plans}
                keyExtractor={(item, index) => index.toString()}
                contentContainerStyle={{ paddingBottom: 40 }}
                showsVerticalScrollIndicator={false}
                renderItem={({ item, index }) => (
                    <TripPlanCard 
                        plan={item} 
                        onSelect={() => handleSelectPlan(item, index)} 
                    />
                )}
            />

            {/* Yükleniyor Overlay */}
            {isSaving && (
                <View style={styles.loadingOverlay}>
                    <ActivityIndicator size="large" color={AppColors.secondary} />
                    <Text style={styles.loadingText}>Planınız kaydediliyor...</Text>
                </View>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
    },
    header: {
        paddingTop: 60,
        paddingHorizontal: AppLayout.largePadding,
        paddingBottom: 16,
    },
    title: {
        fontSize: 26,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 15,
        color: AppColors.textSecondary,
        lineHeight: 22,
    },
    loadingOverlay: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: 'rgba(0,0,0,0.8)',
        justifyContent: 'center',
        alignItems: 'center',
        zIndex: 1000,
    },
    loadingText: {
        color: '#FFF',
        marginTop: 16,
        fontSize: 16,
        fontWeight: 'bold',
    }
});
