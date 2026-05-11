// MyTripsScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import { firestoreService } from '../FirestoreService';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';
import { useIsFocused } from '@react-navigation/native'; // Eğer React Navigation kullanıyorsanız

export default function MyTripsScreen({ navigation }) {
    const [trips, setTrips] = useState([]);
    const isFocused = useIsFocused(); // Sekmeye her girildiğinde yenilemek için

    useEffect(() => {
        if (isFocused) {
            fetchTrips();
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

    const renderTripItem = ({ item }) => {
        const plan = item.plans[item.selectedPlanIndex];
        return (
            <TouchableOpacity 
                style={styles.tripCard}
                activeOpacity={0.8}
                onPress={() => navigation.navigate('TripDetail', { trip: item })}
            >
                <Text style={styles.tripTitle}>{item.city} Seyahati</Text>
                <Text style={styles.tripSubtitle}>
                    {item.days} Gün • {plan?.title || "Plan"}
                </Text>
            </TouchableOpacity>
        );
    };

    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Tatilim</Text>
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
    },
    headerTitle: {
        fontSize: 34,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
    },
    listContent: {
        paddingHorizontal: AppLayout.defaultPadding,
        paddingBottom: 40,
    },
    tripCard: {
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.cornerRadius,
        padding: 16,
        marginBottom: 16,
        borderWidth: 1,
        borderColor: AppColors.border,
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
