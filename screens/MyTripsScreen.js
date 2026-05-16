// MyTripsScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, Image, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import { firestoreService } from '../FirestoreService';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';
import { useIsFocused } from '@react-navigation/native'; // Eğer React Navigation kullanıyorsanız

export default function MyTripsScreen({ navigation }) {
    const [trips, setTrips] = useState([]);
    const [isSelectionMode, setIsSelectionMode] = useState(false);
    const [selectedTripIds, setSelectedTripIds] = useState([]);
    const isFocused = useIsFocused(); // Sekmeye her girildiğinde yenilemek için

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
            // Tarihe göre sırala (en yeni en üstte)
            fetchedTrips.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
            setTrips(fetchedTrips);
        } catch (error) {
            console.error("Seyahatler yüklenirken hata:", error);
        }
    };

    const renderEmptyState = () => (
        <View style={styles.emptyState}>
            <Ionicons name="briefcase-outline" size={100} color="rgba(255,255,255,0.2)" />
            <Text style={styles.emptyTitle}>Henüz bir tatil planınız yok</Text>
            <Text style={styles.emptyDesc}>
                Ana sayfadan yeni bir seyahat planı oluşturduğunuzda planlarınız burada görünecek.
            </Text>
            <TouchableOpacity 
                style={styles.createButton}
                onPress={() => {
                    hapticManager.buttonTap();
                    navigation.navigate('Home');
                }}
            >
                <Text style={styles.createButtonText}>İlk Planımı Oluştur</Text>
            </TouchableOpacity>
        </View>
    );

    const toggleSelectionMode = () => {
        hapticManager.lightImpact();
        setIsSelectionMode(!isSelectionMode);
        setSelectedTripIds([]); // Moddan çıkarken/girerken seçimleri sıfırla
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
                    text: "Sil", 
                    style: "destructive",
                    onPress: async () => {
                        try {
                            // Tüm seçili planları Firestore'dan sil
                            await Promise.all(selectedTripIds.map(id => firestoreService.deleteTrip(id)));
                            
                            // Ekranda listeyi güncelle
                            setTrips(prevTrips => prevTrips.filter(t => !selectedTripIds.includes(t.id)));
                            setIsSelectionMode(false);
                            setSelectedTripIds([]);
                            hapticManager.lightImpact();
                        } catch (error) {
                            Alert.alert("Hata", "Seyahatler silinirken bir sorun oluştu.");
                        }
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
                    <TouchableOpacity 
                        style={styles.checkCircle} 
                        onPress={() => toggleTripSelection(item.id)}
                    >
                        {isSelected ? (
                            <Ionicons name="checkmark-circle" size={24} color="#FF3B30" />
                        ) : (
                            <Ionicons name="ellipse-outline" size={24} color={AppColors.textSecondary} />
                        )}
                    </TouchableOpacity>
                )}

                <TouchableOpacity 
                    style={[
                        styles.tripCard, 
                        isSelectionMode && isSelected && { borderColor: '#FF3B30', backgroundColor: 'rgba(255, 59, 48, 0.05)' }
                    ]}
                    activeOpacity={0.8}
                    onPress={() => {
                        if (isSelectionMode) {
                            toggleTripSelection(item.id);
                        } else {
                            navigation.navigate('TripDetail', { trip: item });
                        }
                    }}
                >
                    <Text style={styles.tripTitle}>{item.title || `${item.city} Seyahati`}</Text>
                    <Text style={styles.tripSubtitle}>
                        {item.days} Gün • {plan?.title || "Plan"}
                    </Text>
                </TouchableOpacity>
            </View>
        );
    };

    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Tatil Planlarım</Text>
                {trips.length > 0 && (
                    <TouchableOpacity onPress={toggleSelectionMode} style={styles.selectHeaderButton}>
                        <Text style={styles.selectHeaderButtonText}>
                            {isSelectionMode ? "İptal" : "Seç"}
                        </Text>
                    </TouchableOpacity>
                )}
            </View>

            {trips.length === 0 ? (
                renderEmptyState()
            ) : (
                <FlatList
                    data={trips}
                    keyExtractor={(item) => item.id}
                    contentContainerStyle={styles.listContent}
                    showsVerticalScrollIndicator={false}
                    renderItem={renderTripItem}
                />
            )}

            {/* Toplu Silme Butonu (Sadece Seçim Modunda Görünür) */}
            {isSelectionMode && selectedTripIds.length > 0 && (
                <View style={styles.bulkDeleteContainer}>
                    <TouchableOpacity style={styles.bulkDeleteButton} onPress={handleDeleteSelected}>
                        <Ionicons name="trash" size={20} color="#FFF" style={{ marginRight: 8 }} />
                        <Text style={styles.bulkDeleteText}>Seçilenleri Sil ({selectedTripIds.length})</Text>
                    </TouchableOpacity>
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
        paddingBottom: 20,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    headerTitle: {
        fontSize: 34,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
    },
    selectHeaderButton: {
        paddingVertical: 6,
        paddingHorizontal: 12,
        backgroundColor: 'rgba(255,255,255,0.1)',
        borderRadius: 16,
    },
    selectHeaderButtonText: {
        color: '#FFFFFF', // Siyah arka planda net görünmesi için beyaz yapıldı
        fontSize: 16,
        fontWeight: 'bold',
    },
    listContent: {
        paddingHorizontal: AppLayout.defaultPadding,
        paddingBottom: 40,
    },
    tripCardContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 16,
    },
    tripCard: {
        flex: 1,
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.cornerRadius,
        padding: 16,
        borderWidth: 1,
        borderColor: AppColors.border,
    },
    checkCircle: {
        marginRight: 12,
        justifyContent: 'center',
        alignItems: 'center',
    },
    tripTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 4,
    },
    tripSubtitle: {
        fontSize: 14,
        color: AppColors.textSecondary,
    },
    bulkDeleteContainer: {
        position: 'absolute',
        bottom: 30,
        left: 20,
        right: 20,
    },
    bulkDeleteButton: {
        backgroundColor: '#FF3B30',
        flexDirection: 'row',
        paddingVertical: 16,
        borderRadius: AppLayout.cornerRadius,
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#FF3B30',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.4,
        shadowRadius: 8,
        elevation: 6,
    },
    bulkDeleteText: {
        color: '#FFF',
        fontSize: 16,
        fontWeight: 'bold',
    },
    emptyState: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        paddingHorizontal: 40,
        marginTop: -60,
    },
    emptyTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginTop: 24,
        textAlign: 'center',
    },
    emptyDesc: {
        fontSize: 15,
        color: AppColors.textSecondary,
        textAlign: 'center',
        marginTop: 8,
        lineHeight: 22,
        marginBottom: 32,
    },
    createButton: {
        backgroundColor: AppColors.secondary,
        paddingVertical: 14,
        paddingHorizontal: 24,
        borderRadius: AppLayout.cornerRadius,
    },
    createButtonText: {
        color: '#FFF',
        fontSize: 16,
        fontWeight: 'bold',
    }
});
