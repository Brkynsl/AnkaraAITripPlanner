// TripDetailScreen.js
import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout } from './theme';
import { hapticManager } from '../HapticManager';

export default function TripDetailScreen({ route, navigation }) {
    const { trip } = route.params;
    const { colors } = useTheme();
    
    // Eski veya hatalı veriler için güvenlik kontrolü
    const plan = trip?.plans ? trip.plans[trip.selectedPlanIndex || 0] : trip;

    if (!plan) {
        return (
            <View style={[styles.container, { backgroundColor: colors.background }]}>
                <Text style={{color: colors.textPrimary, textAlign: 'center', marginTop: 100}}>Plan verisi bulunamadı veya bozuk.</Text>
            </View>
        );
    }

    const formatPrice = (val) => new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY', maximumFractionDigits: 0 }).format(val);

    const handleOpenMap = () => {
        hapticManager.lightImpact();
        navigation.navigate('TripMap', { plan });
    };

    return (
        <View style={[styles.container, { backgroundColor: colors.background }]}>
            <View style={styles.header}>
                <TouchableOpacity style={[styles.backButton, { backgroundColor: colors.iconBackground }]} onPress={() => navigation.goBack()}>
                    <Ionicons name="chevron-back" size={24} color={colors.textPrimary} />
                </TouchableOpacity>
                <Text style={[styles.headerTitleText, { color: colors.textPrimary }]}>Plan Detayı</Text>
            </View>

            <ScrollView style={styles.scroll} contentContainerStyle={styles.content}>
                
                {/* 1. Hero Header */}
                <View style={[styles.heroCard, { backgroundColor: colors.isDark ? 'rgba(0, 180, 216, 0.15)' : 'rgba(0, 199, 191, 0.1)' }]}>
                    <Ionicons name="airplane" size={40} color={colors.isDark ? colors.primary : colors.secondary} style={{ marginBottom: 12 }} />
                    <Text style={[styles.heroTitle, { color: colors.textPrimary }]}>{trip.city} Seyahati</Text>
                    <Text style={[styles.heroSubtitle, { color: colors.secondary }]}>{trip.days} Gün • {plan.title} • {formatPrice(plan.totalEstimatedCost)}</Text>
                    <Text style={[styles.heroDesc, { color: colors.textSecondary }]}>{plan.description}</Text>
                </View>

                {/* 2. Ulaşım Kartı */}
                <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                    <Text style={[styles.cardTitle, { color: colors.textPrimary }]}>✈️ Ulaşım</Text>
                    <Text style={[styles.cardText, { color: colors.textSecondary }]}>
                        {plan.transportation?.type?.displayName || plan.transportation?.type || 'Bilinmiyor'} • {plan.transportation?.provider || 'Standart'}{'\n'}
                        🛫 Kalkış: {plan.transportation?.departureCity || 'İstanbul'} → {plan.transportation?.arrivalCity || trip.city}{'\n'}
                        ⏰ {plan.transportation?.departureTime || '08:00'} - {plan.transportation?.arrivalTime || '12:00'} ({plan.transportation?.duration || '-'}){'\n'}
                        💺 Sınıf: {plan.transportation?.classType || 'Standart'}{'\n'}
                        💰 Gidiş: ₺{plan.transportation?.price || 0} • Dönüş: ₺{plan.transportation?.returnPrice || plan.transportation?.price || 0}
                    </Text>
                </View>

                {/* 3. Konaklama Kartı */}
                <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                    <Text style={[styles.cardTitle, { color: colors.textPrimary }]}>🏨 Konaklama</Text>
                    <Text style={[styles.cardText, { color: colors.textSecondary }]}>
                        {plan.hotel?.name || 'Otel Bilgisi Yok'} {"⭐".repeat(plan.hotel?.starRating || 3)}{'\n'}
                        📍 {plan.hotel?.address || '-'} ({plan.hotel?.distanceToCenter || '-'} merkeze){'\n'}
                        💰 Gecelik: ₺{plan.hotel?.pricePerNight || 0} • Toplam: ₺{plan.hotel?.totalPrice || 0}{'\n'}
                        🕐 Giriş: {plan.hotel?.checkIn || '14:00'} • Çıkış: {plan.hotel?.checkOut || '12:00'}{'\n'}
                        🏷️ {plan.hotel?.amenities ? plan.hotel.amenities.join(" • ") : 'WiFi • Restoran • Klima'}
                    </Text>
                </View>

                {/* 4. Günlük Program */}
                <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>📋 Günlük Program</Text>
                {plan.dailyPlans.map((day, idx) => (
                    <View key={idx} style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                        <View style={[styles.dayHeader, { borderBottomColor: colors.border }]}>
                            <Text style={[styles.dayTitle, { color: colors.isDark ? colors.primary : colors.textPrimary }]}>{day.title}</Text>
                            <Text style={[styles.dayCost, { color: colors.secondary }]}>₺{day.estimatedCost}</Text>
                        </View>
                        
                        {day.activities.map((act, i) => (
                            <View key={i} style={styles.activityRow}>
                                <View style={[styles.activityDot, { backgroundColor: colors.secondary }]}><Text style={styles.dotText}>{i+1}</Text></View>
                                <View style={styles.activityContent}>
                                    <Text style={[styles.actName, { color: colors.textPrimary }]}>{act.name}</Text>
                                    <Text style={[styles.actTime, { color: colors.secondary }]}>🕐 {act.startTime} - {act.endTime}</Text>
                                    <Text style={[styles.actDesc, { color: colors.textSecondary }]}>{act.description}</Text>
                                    {act.entryFee > 0 && <Text style={[styles.actFee, { color: colors.accent, backgroundColor: colors.isDark ? 'rgba(255,107,53,0.1)' : 'rgba(255,149,0,0.1)' }]}>💰 ₺{act.entryFee}</Text>}
                                    {act.transportInfo && <Text style={[styles.actTransport, { color: colors.textSecondary }]}>🚇 {act.transportInfo}</Text>}
                                </View>
                            </View>
                        ))}
                    </View>
                ))}

            </ScrollView>

            {/* Harita Butonu (Floating) */}
            <TouchableOpacity style={[styles.floatingButton, { backgroundColor: colors.isDark ? colors.primary : '#1C1C1E', shadowColor: colors.isDark ? colors.primary : '#1C1C1E' }]} onPress={handleOpenMap}>
                <Ionicons name="map" size={20} color="#FFF" style={{ marginRight: 8 }} />
                <Text style={styles.floatingButtonText}>Haritada Gör</Text>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: { flexDirection: 'row', alignItems: 'center', paddingTop: 60, paddingHorizontal: AppLayout.defaultPadding, paddingBottom: 10 },
    backButton: { width: 40, height: 40, borderRadius: 20, justifyContent: 'center', alignItems: 'center', marginRight: 16 },
    headerTitleText: { fontSize: 24, fontWeight: 'bold' },
    scroll: { flex: 1 },
    content: { padding: AppLayout.defaultPadding, paddingBottom: 100 },
    heroCard: { borderRadius: 20, padding: 20, marginBottom: 20 },
    heroTitle: { fontSize: 26, fontWeight: 'bold', marginBottom: 6 },
    heroSubtitle: { fontSize: 15, fontWeight: '500', marginBottom: 8 },
    heroDesc: { fontSize: 14, lineHeight: 20 },
    card: { borderRadius: AppLayout.cornerRadius, padding: 16, marginBottom: 16 },
    cardTitle: { fontSize: 18, fontWeight: 'bold', marginBottom: 8 },
    cardText: { fontSize: 14, lineHeight: 22 },
    sectionTitle: { fontSize: 22, fontWeight: 'bold', marginTop: 10, marginBottom: 16 },
    dayHeader: { flexDirection: 'row', justifyContent: 'space-between', borderBottomWidth: 1, paddingBottom: 12, marginBottom: 12 },
    dayTitle: { fontSize: 18, fontWeight: 'bold' },
    dayCost: { fontSize: 16, fontWeight: 'bold' },
    activityRow: { flexDirection: 'row', marginBottom: 16 },
    activityDot: { width: 24, height: 24, borderRadius: 12, alignItems: 'center', justifyContent: 'center', marginRight: 12, marginTop: 2 },
    dotText: { color: '#FFF', fontSize: 12, fontWeight: 'bold' },
    activityContent: { flex: 1 },
    actName: { fontSize: 16, fontWeight: 'bold' },
    actTime: { fontSize: 13, marginBottom: 4 },
    actDesc: { fontSize: 14, marginBottom: 4 },
    actFee: { fontSize: 12, alignSelf: 'flex-start', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 8, marginBottom: 4 },
    actTransport: { fontSize: 13 },
    floatingButton: { position: 'absolute', bottom: 30, alignSelf: 'center', flexDirection: 'row', paddingVertical: 14, paddingHorizontal: 24, borderRadius: 30, elevation: 8, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.4, shadowRadius: 8 },
    floatingButtonText: { color: '#FFF', fontSize: 16, fontWeight: 'bold' }
});
