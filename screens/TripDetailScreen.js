// TripDetailScreen.js
import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import { hapticManager } from '../HapticManager';

export default function TripDetailScreen({ route, navigation }) {
    const { trip } = route.params;
    const plan = trip.plans[trip.selectedPlanIndex];

    const formatPrice = (val) => new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(val);

    const handleOpenMap = () => {
        hapticManager.lightImpact();
        navigation.navigate('TripMap', { plan });
    };

    return (
        <View style={styles.container}>
            <ScrollView style={styles.scroll} contentContainerStyle={styles.content}>
                
                {/* 1. Hero Header */}
                <View style={styles.heroCard}>
                    <Ionicons name="airplane" size={40} color={AppColors.primary} style={{ marginBottom: 12 }} />
                    <Text style={styles.heroTitle}>{trip.city} Seyahati</Text>
                    <Text style={styles.heroSubtitle}>{trip.days} Gün • {plan.title} • {formatPrice(plan.totalEstimatedCost)}</Text>
                    <Text style={styles.heroDesc}>{plan.description}</Text>
                </View>

                {/* 2. Ulaşım Kartı */}
                <View style={styles.card}>
                    <Text style={styles.cardTitle}>✈️ Ulaşım</Text>
                    <Text style={styles.cardText}>
                        {plan.transportation.type.displayName} • {plan.transportation.provider}{'\n'}
                        🛫 Kalkış: {plan.transportation.departureCity} → {plan.transportation.arrivalCity}{'\n'}
                        ⏰ {plan.transportation.departureTime} - {plan.transportation.arrivalTime} ({plan.transportation.duration}){'\n'}
                        💺 Sınıf: {plan.transportation.classType}{'\n'}
                        💰 Gidiş: ₺{plan.transportation.price} • Dönüş: ₺{plan.transportation.returnPrice || plan.transportation.price}
                    </Text>
                </View>

                {/* 3. Konaklama Kartı */}
                <View style={styles.card}>
                    <Text style={styles.cardTitle}>🏨 Konaklama</Text>
                    <Text style={styles.cardText}>
                        {plan.hotel.name} {"⭐".repeat(plan.hotel.starRating)}{'\n'}
                        📍 {plan.hotel.address} ({plan.hotel.distanceToCenter} merkeze){'\n'}
                        💰 Gecelik: ₺{plan.hotel.pricePerNight} • Toplam: ₺{plan.hotel.totalPrice}{'\n'}
                        🕐 Giriş: {plan.hotel.checkIn} • Çıkış: {plan.hotel.checkOut}{'\n'}
                        🏷️ {plan.hotel.amenities.join(" • ")}
                    </Text>
                </View>

                {/* 4. Günlük Program */}
                <Text style={styles.sectionTitle}>📋 Günlük Program</Text>
                {plan.dailyPlans.map((day, idx) => (
                    <View key={idx} style={styles.card}>
                        <View style={styles.dayHeader}>
                            <Text style={styles.dayTitle}>{day.title}</Text>
                            <Text style={styles.dayCost}>₺{day.estimatedCost}</Text>
                        </View>
                        
                        {day.activities.map((act, i) => (
                            <View key={i} style={styles.activityRow}>
                                <View style={styles.activityDot}><Text style={styles.dotText}>{i+1}</Text></View>
                                <View style={styles.activityContent}>
                                    <Text style={styles.actName}>{act.name}</Text>
                                    <Text style={styles.actTime}>🕐 {act.startTime} - {act.endTime}</Text>
                                    <Text style={styles.actDesc}>{act.description}</Text>
                                    {act.entryFee > 0 && <Text style={styles.actFee}>💰 ₺{act.entryFee}</Text>}
                                    {act.transportInfo && <Text style={styles.actTransport}>🚇 {act.transportInfo}</Text>}
                                </View>
                            </View>
                        ))}
                    </View>
                ))}

            </ScrollView>

            {/* Harita Butonu (Floating) */}
            <TouchableOpacity style={styles.floatingButton} onPress={handleOpenMap}>
                <Ionicons name="map" size={20} color="#FFF" style={{ marginRight: 8 }} />
                <Text style={styles.floatingButtonText}>Haritada Gör</Text>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
    },
    scroll: {
        flex: 1,
    },
    content: {
        padding: AppLayout.defaultPadding,
        paddingBottom: 100, // Butonun arkasında kalmaması için
    },
    heroCard: {
        backgroundColor: 'rgba(0, 180, 216, 0.15)', // AppColors.primary
        borderRadius: 20,
        padding: 20,
        marginBottom: 20,
    },
    heroTitle: {
        fontSize: 26,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 6,
    },
    heroSubtitle: {
        fontSize: 15,
        fontWeight: '500',
        color: AppColors.secondary,
        marginBottom: 8,
    },
    heroDesc: {
        fontSize: 14,
        color: AppColors.textSecondary,
        lineHeight: 20,
    },
    card: {
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.cornerRadius,
        padding: 16,
        marginBottom: 16,
    },
    cardTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 8,
    },
    cardText: {
        fontSize: 14,
        color: AppColors.textSecondary,
        lineHeight: 22,
    },
    sectionTitle: {
        fontSize: 22,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginTop: 10,
        marginBottom: 16,
    },
    dayHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(255,255,255,0.1)',
        paddingBottom: 12,
        marginBottom: 12,
    },
    dayTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: AppColors.primary,
    },
    dayCost: {
        fontSize: 16,
        fontWeight: 'bold',
        color: AppColors.secondary,
    },
    activityRow: {
        flexDirection: 'row',
        marginBottom: 16,
    },
    activityDot: {
        width: 24,
        height: 24,
        borderRadius: 12,
        backgroundColor: AppColors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 12,
        marginTop: 2,
    },
    dotText: {
        color: '#FFF',
        fontSize: 12,
        fontWeight: 'bold',
    },
    activityContent: {
        flex: 1,
    },
    actName: {
        fontSize: 16,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
    },
    actTime: {
        fontSize: 13,
        color: AppColors.secondary,
        marginBottom: 4,
    },
    actDesc: {
        fontSize: 14,
        color: AppColors.textSecondary,
        marginBottom: 4,
    },
    actFee: {
        fontSize: 12,
        color: AppColors.accent,
        backgroundColor: 'rgba(255,107,53,0.1)',
        alignSelf: 'flex-start',
        paddingHorizontal: 8,
        paddingVertical: 2,
        borderRadius: 8,
        marginBottom: 4,
    },
    actTransport: {
        fontSize: 13,
        color: AppColors.textSecondary,
    },
    floatingButton: {
        position: 'absolute',
        bottom: 30,
        alignSelf: 'center',
        flexDirection: 'row',
        backgroundColor: AppColors.primary,
        paddingVertical: 14,
        paddingHorizontal: 24,
        borderRadius: 30,
        elevation: 8,
        shadowColor: AppColors.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.4,
        shadowRadius: 8,
    },
    floatingButtonText: {
        color: '#FFF',
        fontSize: 16,
        fontWeight: 'bold',
    }
});
