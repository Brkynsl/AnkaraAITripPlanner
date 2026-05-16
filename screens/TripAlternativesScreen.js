// TripAlternativesScreen.js
import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, ActivityIndicator, Alert, Modal, TextInput } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import TripPlanCard from './TripPlanCard';
import { firestoreService } from '../FirestoreService';
import { firebaseAuthService } from '../FirebaseAuthService';

export default function TripAlternativesScreen({ route, navigation }) {
    const { city, days, budget, plans } = route.params;
    const [isSaving, setIsSaving] = useState(false);
    
    // İsim sorma modalı için stateler
    const [modalVisible, setModalVisible] = useState(false);
    const [tripName, setTripName] = useState(`${city} Seyahati`);
    const [pendingPlan, setPendingPlan] = useState(null);

    const handleSelectPlan = (selectedPlan, index) => {
        const user = firebaseAuthService.currentFirebaseUser;
        if (!user) {
            Alert.alert("Hata", "Lütfen önce giriş yapın.");
            return;
        }
        // Seçilen planı hafızaya alıp modalı aç
        setPendingPlan({ selectedPlan, index });
        setTripName(`${city} Seyahati`);
        setModalVisible(true);
    };

    const confirmSaveTrip = async () => {
        if (!pendingPlan) return;
        
        setModalVisible(false);
        setIsSaving(true);
        
        try {
            const user = firebaseAuthService.currentFirebaseUser;
            const newTrip = {
                userId: user.uid,
                title: tripName || `${city} Seyahati`, // Özel isim veya varsayılan
                city: city,
                days: days,
                totalBudget: budget,
                plans: plans,
                selectedPlanIndex: pendingPlan.index,
                status: 'planned',
                createdAt: new Date().toISOString()
            };

            await firestoreService.saveTrip(newTrip);
            
            setIsSaving(false);
            Alert.alert("Başarılı", "Seyahatiniz başarıyla kaydedildi!", [
                { 
                    text: "Tamam", 
                    onPress: () => {
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

            {/* İsim Sorma Modalı */}
            <Modal
                transparent={true}
                visible={modalVisible}
                animationType="fade"
                onRequestClose={() => setModalVisible(false)}
            >
                <View style={styles.modalOverlay}>
                    <View style={styles.modalContent}>
                        <Text style={styles.modalTitle}>Seyahatine İsim Ver</Text>
                        <Text style={styles.modalSubtitle}>Kayıtlı planların arasında kolayca bulabilmek için bir isim belirleyin.</Text>
                        
                        <TextInput
                            style={styles.modalInput}
                            value={tripName}
                            onChangeText={setTripName}
                            placeholder="Örn: Hafta Sonu Kaçamağı"
                            placeholderTextColor={AppColors.textSecondary}
                            autoFocus={true}
                        />

                        <View style={styles.modalButtons}>
                            <TouchableOpacity style={styles.modalCancelButton} onPress={() => setModalVisible(false)}>
                                <Text style={styles.modalCancelText}>İptal</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.modalSaveButton} onPress={confirmSaveTrip}>
                                <Text style={styles.modalSaveText}>Kaydet</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                </View>
            </Modal>

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
    },
    modalOverlay: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: 'rgba(0,0,0,0.6)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 20,
        zIndex: 999,
    },
    modalContent: {
        backgroundColor: AppColors.cardBackground,
        width: '100%',
        borderRadius: AppLayout.largeCornerRadius,
        padding: 24,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 10,
        elevation: 8,
    },
    modalTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 8,
    },
    modalSubtitle: {
        fontSize: 14,
        color: AppColors.textSecondary,
        marginBottom: 20,
        lineHeight: 20,
    },
    modalInput: {
        backgroundColor: 'rgba(255,255,255,0.05)',
        borderWidth: 1,
        borderColor: AppColors.border,
        borderRadius: AppLayout.cornerRadius,
        color: AppColors.textPrimary,
        fontSize: 16,
        paddingHorizontal: 16,
        paddingVertical: 14,
        marginBottom: 24,
    },
    modalButtons: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        gap: 12,
    },
    modalCancelButton: {
        paddingVertical: 12,
        paddingHorizontal: 20,
        borderRadius: AppLayout.cornerRadius,
    },
    modalCancelText: {
        color: AppColors.textSecondary,
        fontSize: 16,
        fontWeight: 'bold',
    },
    modalSaveButton: {
        backgroundColor: AppColors.secondary,
        paddingVertical: 12,
        paddingHorizontal: 24,
        borderRadius: AppLayout.cornerRadius,
    },
    modalSaveText: {
        color: '#FFF',
        fontSize: 16,
        fontWeight: 'bold',
    }
});
