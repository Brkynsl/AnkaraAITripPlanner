// TripAlternativesScreen.js
import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, ActivityIndicator, Alert, Modal, TextInput } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout, scale, verticalScale, moderateScale } from './theme';
import TripPlanCard from './TripPlanCard';
import { firestoreService } from '../FirestoreService';
import { firebaseAuthService } from '../FirebaseAuthService';

export default function TripAlternativesScreen({ route, navigation }) {
    const { city, days, budget, plans } = route.params;
    const [isSaving, setIsSaving] = useState(false);
    const [modalVisible, setModalVisible] = useState(false);
    const [tripName, setTripName] = useState(`${city} Seyahati`);
    const [pendingPlan, setPendingPlan] = useState(null);
    const { colors } = useTheme();

    const handleSelectPlan = (selectedPlan, index) => {
        const user = firebaseAuthService.currentFirebaseUser;
        if (!user) { Alert.alert("Hata", "Lütfen önce giriş yapın."); return; }
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
                userId: user.uid, title: tripName || `${city} Seyahati`,
                city, days, totalBudget: budget, plans,
                selectedPlanIndex: pendingPlan.index, status: 'planned',
                createdAt: new Date().toISOString()
            };
            await firestoreService.saveTrip(newTrip);
            setIsSaving(false);
            Alert.alert("Başarılı", "Seyahatiniz başarıyla kaydedildi!", [
                { text: "Tamam", onPress: () => navigation.navigate('MainTab', { screen: 'MyTrips' }) }
            ]);
        } catch (error) {
            setIsSaving(false);
            Alert.alert("Hata", "Plan kaydedilemedi: " + error.message);
        }
    };

    return (
        <View style={[styles.container, { backgroundColor: colors.background }]}>
            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity style={[styles.backButton, { backgroundColor: colors.iconBackground }]} onPress={() => navigation.goBack()}>
                    <Ionicons name="close" size={28} color={colors.textPrimary} />
                </TouchableOpacity>
                <Text style={[styles.title, { color: colors.textPrimary }]}>Sizin İçin 3 Plan Çıkardık</Text>
                <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
                    {city} rotanız için belirlediğiniz bütçeye özel optimize edilmiş alternatifler.
                </Text>
            </View>

            <FlatList
                data={plans}
                keyExtractor={(item, index) => index.toString()}
                contentContainerStyle={{ paddingBottom: 40 }}
                showsVerticalScrollIndicator={false}
                renderItem={({ item, index }) => (
                    <TripPlanCard plan={item} onSelect={() => handleSelectPlan(item, index)} />
                )}
            />

            {/* İsim Sorma Modalı */}
            <Modal transparent={true} visible={modalVisible} animationType="fade" onRequestClose={() => setModalVisible(false)}>
                <View style={[styles.modalOverlay, { backgroundColor: colors.overlayBackground }]}>
                    <View style={[styles.modalContent, { backgroundColor: colors.isDark ? '#1C1C1E' : '#FFFFFF' }]}>
                        <Text style={[styles.modalTitle, { color: colors.textPrimary }]}>Seyahatine İsim Ver</Text>
                        <Text style={[styles.modalSubtitle, { color: colors.textSecondary }]}>Kayıtlı planların arasında kolayca bulabilmek için bir isim belirleyin.</Text>
                        <TextInput
                            style={[styles.modalInput, { backgroundColor: colors.inputBackground, borderColor: colors.border, color: colors.textPrimary }]}
                            value={tripName}
                            onChangeText={setTripName}
                            placeholder="Örn: Hafta Sonu Kaçamağı"
                            placeholderTextColor={colors.textSecondary}
                            autoFocus={true}
                        />
                        <View style={styles.modalButtons}>
                            <TouchableOpacity style={styles.modalCancelButton} onPress={() => setModalVisible(false)}>
                                <Text style={[styles.modalCancelText, { color: colors.textSecondary }]}>İptal</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={[styles.modalSaveButton, { backgroundColor: colors.secondary }]} onPress={confirmSaveTrip}>
                                <Text style={styles.modalSaveText}>Kaydet</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                </View>
            </Modal>

            {isSaving && (
                <View style={styles.loadingOverlay}>
                    <ActivityIndicator size="large" color={colors.secondary} />
                    <Text style={styles.loadingText}>Planınız kaydediliyor...</Text>
                </View>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: { paddingTop: AppLayout.headerPaddingTop, paddingHorizontal: AppLayout.largePadding, paddingBottom: verticalScale(16) },
    backButton: { width: scale(40), height: scale(40), borderRadius: scale(20), justifyContent: 'center', alignItems: 'center', marginBottom: verticalScale(12) },
    title: { fontSize: moderateScale(26), fontWeight: 'bold', marginBottom: verticalScale(8) },
    subtitle: { fontSize: moderateScale(15), lineHeight: moderateScale(22) },
    loadingOverlay: { ...StyleSheet.absoluteFillObject, backgroundColor: 'rgba(0,0,0,0.8)', justifyContent: 'center', alignItems: 'center', zIndex: 1000 },
    loadingText: { color: '#FFF', marginTop: verticalScale(16), fontSize: moderateScale(16), fontWeight: 'bold' },
    modalOverlay: { ...StyleSheet.absoluteFillObject, justifyContent: 'center', alignItems: 'center', padding: scale(20), zIndex: 999 },
    modalContent: { width: '100%', borderRadius: AppLayout.largeCornerRadius, padding: scale(24), shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 10, elevation: 8 },
    modalTitle: { fontSize: moderateScale(20), fontWeight: 'bold', marginBottom: verticalScale(8) },
    modalSubtitle: { fontSize: moderateScale(14), marginBottom: verticalScale(20), lineHeight: moderateScale(20) },
    modalInput: { borderWidth: 1, borderRadius: AppLayout.cornerRadius, fontSize: moderateScale(16), paddingHorizontal: scale(16), paddingVertical: verticalScale(14), marginBottom: verticalScale(24) },
    modalButtons: { flexDirection: 'row', justifyContent: 'flex-end', gap: scale(12) },
    modalCancelButton: { paddingVertical: verticalScale(12), paddingHorizontal: scale(20), borderRadius: AppLayout.cornerRadius },
    modalCancelText: { fontSize: moderateScale(16), fontWeight: 'bold' },
    modalSaveButton: { paddingVertical: verticalScale(12), paddingHorizontal: scale(24), borderRadius: AppLayout.cornerRadius },
    modalSaveText: { color: '#FFF', fontSize: moderateScale(16), fontWeight: 'bold' }
});
