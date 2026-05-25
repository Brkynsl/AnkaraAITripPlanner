// MyTripsScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout, scale, verticalScale, moderateScale } from './theme';
import { firestoreService } from '../FirestoreService';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';
import { useIsFocused } from '@react-navigation/native';

export default function MyTripsScreen({ navigation }) {
    const [trips, setTrips] = useState([]);
    const [isSelectionMode, setIsSelectionMode] = useState(false);
    const [selectedTripIds, setSelectedTripIds] = useState([]);
    const isFocused = useIsFocused();
    const { colors } = useTheme();

    useEffect(() => {
        if (isFocused) {
            fetchTrips();
            setIsSelectionMode(false);
            setSelectedTripIds([]);
        }
    }, [isFocused]);

    const fetchTrips = async () => {
        const user = firebaseAuthService.currentFirebaseUser;
        if (!user) return;
        try {
            const fetchedTrips = await firestoreService.getTrips(user.uid);
            fetchedTrips.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
            setTrips(fetchedTrips);
        } catch (error) {
            console.error("Seyahatler yüklenirken hata:", error);
        }
    };

    const renderEmptyState = () => (
        <View style={styles.emptyState}>
            <Ionicons name="briefcase-outline" size={moderateScale(80)} color={colors.border} />
            <Text style={[styles.emptyTitle, { color: colors.textPrimary }]}>Henüz bir tatil planınız yok</Text>
            <Text style={[styles.emptyDesc, { color: colors.textSecondary }]}>
                Ana sayfadan yeni bir seyahat planı oluşturduğunuzda planlarınız burada görünecek.
            </Text>
            <TouchableOpacity 
                style={[styles.createButton, { backgroundColor: colors.secondary }]}
                onPress={() => { hapticManager.buttonTap(); navigation.navigate('Home'); }}
            >
                <Text style={styles.createButtonText}>İlk Planımı Oluştur</Text>
            </TouchableOpacity>
        </View>
    );

    const toggleSelectionMode = () => {
        hapticManager.lightImpact();
        setIsSelectionMode(!isSelectionMode);
        setSelectedTripIds([]);
    };

    const toggleTripSelection = (tripId) => {
        hapticManager.buttonTap();
        if (selectedTripIds.includes(tripId)) {
            setSelectedTripIds(selectedTripIds.filter(id => id !== tripId));
        } else {
            setSelectedTripIds([...selectedTripIds, tripId]);
        }
    };

    const handleDeleteSelected = () => {
        if (selectedTripIds.length === 0) return;
        Alert.alert(
            "Planları Sil",
            `Seçili ${selectedTripIds.length} seyahati silmek istediğinize emin misiniz?`,
            [
                { text: "İptal", style: "cancel" },
                { 
                    text: "Sil", style: "destructive",
                    onPress: async () => {
                        try {
                            await Promise.all(selectedTripIds.map(id => firestoreService.deleteTrip(id)));
                            setTrips(prevTrips => prevTrips.filter(t => !selectedTripIds.includes(t.id)));
                            setIsSelectionMode(false);
                            setSelectedTripIds([]);
                            hapticManager.lightImpact();
                        } catch (error) { Alert.alert("Hata", "Seyahatler silinirken bir sorun oluştu."); }
                    }
                }
            ]
        );
    };

    const renderTripItem = ({ item }) => {
        const plan = item.plans[item.selectedPlanIndex];
        const isSelected = selectedTripIds.includes(item.id);

        return (
            <View style={styles.tripCardContainer}>
                {isSelectionMode && (
                    <TouchableOpacity style={styles.checkCircle} onPress={() => toggleTripSelection(item.id)}>
                        {isSelected ? (
                            <Ionicons name="checkmark-circle" size={24} color={colors.error} />
                        ) : (
                            <Ionicons name="ellipse-outline" size={24} color={colors.textSecondary} />
                        )}
                    </TouchableOpacity>
                )}

                <TouchableOpacity 
                    style={[
                        styles.tripCard, 
                        { backgroundColor: colors.cardBackgroundRGBA, borderColor: colors.border },
                        isSelectionMode && isSelected && { borderColor: colors.error, backgroundColor: colors.error + '1A' }
                    ]}
                    activeOpacity={0.8}
                    onPress={() => {
                        if (isSelectionMode) toggleTripSelection(item.id);
                        else navigation.navigate('TripDetail', { trip: item });
                    }}
                >
                    <Text style={[styles.tripTitle, { color: colors.textPrimary }]}>{item.title || `${item.city} Seyahati`}</Text>
                    <Text style={[styles.tripSubtitle, { color: colors.textSecondary }]}>{item.days} Gün • {plan?.title || "Plan"}</Text>
                </TouchableOpacity>
            </View>
        );
    };

    return (
        <View style={[styles.container, { backgroundColor: colors.background }]}>
            <View style={styles.header}>
                <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>Tatil Planlarım</Text>
                {trips.length > 0 && (
                    <TouchableOpacity onPress={toggleSelectionMode} style={[styles.selectHeaderButton, { backgroundColor: colors.iconBackground }]}>
                        <Text style={[styles.selectHeaderButtonText, { color: colors.textPrimary }]}>{isSelectionMode ? "İptal" : "Seç"}</Text>
                    </TouchableOpacity>
                )}
            </View>

            {trips.length === 0 ? renderEmptyState() : (
                <FlatList
                    data={trips}
                    keyExtractor={(item) => item.id}
                    contentContainerStyle={styles.listContent}
                    showsVerticalScrollIndicator={false}
                    renderItem={renderTripItem}
                />
            )}

            {isSelectionMode && selectedTripIds.length > 0 && (
                <View style={styles.bulkDeleteContainer}>
                    <TouchableOpacity style={[styles.bulkDeleteButton, { backgroundColor: colors.error, shadowColor: colors.error }]} onPress={handleDeleteSelected}>
                        <Ionicons name="trash" size={20} color="#FFF" style={{ marginRight: 8 }} />
                        <Text style={styles.bulkDeleteText}>Seçilenleri Sil ({selectedTripIds.length})</Text>
                    </TouchableOpacity>
                </View>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: { paddingTop: AppLayout.headerPaddingTop, paddingHorizontal: AppLayout.largePadding, paddingBottom: verticalScale(20), flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    headerTitle: { fontSize: moderateScale(32), fontWeight: 'bold' },
    selectHeaderButton: { paddingVertical: verticalScale(6), paddingHorizontal: scale(12), borderRadius: scale(16) },
    selectHeaderButtonText: { fontSize: moderateScale(15), fontWeight: 'bold' },
    listContent: { paddingHorizontal: AppLayout.defaultPadding, paddingBottom: verticalScale(40) },
    tripCardContainer: { flexDirection: 'row', alignItems: 'center', marginBottom: verticalScale(16) },
    tripCard: { flex: 1, borderRadius: AppLayout.cornerRadius, padding: scale(16), borderWidth: 1 },
    checkCircle: { marginRight: scale(12), justifyContent: 'center', alignItems: 'center' },
    tripTitle: { fontSize: moderateScale(18), fontWeight: 'bold', marginBottom: verticalScale(4) },
    tripSubtitle: { fontSize: moderateScale(14) },
    bulkDeleteContainer: { position: 'absolute', bottom: verticalScale(30), left: scale(20), right: scale(20) },
    bulkDeleteButton: { flexDirection: 'row', paddingVertical: verticalScale(16), borderRadius: AppLayout.cornerRadius, justifyContent: 'center', alignItems: 'center', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.4, shadowRadius: 8, elevation: 6 },
    bulkDeleteText: { color: '#FFF', fontSize: moderateScale(16), fontWeight: 'bold' },
    emptyState: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: scale(40), marginTop: verticalScale(-60) },
    emptyTitle: { fontSize: moderateScale(18), fontWeight: 'bold', marginTop: verticalScale(24), textAlign: 'center' },
    emptyDesc: { fontSize: moderateScale(14), textAlign: 'center', marginTop: verticalScale(8), lineHeight: moderateScale(22), marginBottom: verticalScale(32) },
    createButton: { paddingVertical: verticalScale(14), paddingHorizontal: scale(24), borderRadius: AppLayout.cornerRadius },
    createButtonText: { color: '#FFF', fontSize: moderateScale(15), fontWeight: 'bold' }
});
