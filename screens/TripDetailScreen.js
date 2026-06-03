// TripDetailScreen.js
import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout, scale, verticalScale, moderateScale } from './theme';
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
                <Ionicons name="airplane" size={moderateScale(36)} color={colors.secondary} style={{ marginBottom: verticalScale(10) }} />
                    <Text style={[styles.heroTitle, { color: colors.textPrimary }]}>{trip.city} Seyahati</Text>
                    <Text style={[styles.heroSubtitle, { color: colors.secondary }]} numberOfLines={2}>{trip.days} Gün • {plan.title} • {formatPrice(plan.totalEstimatedCost)}</Text>
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
                            <Text style={[styles.dayTitle, { color: colors.textPrimary }]}>{day.title}</Text>
                            <Text style={[styles.dayCost, { color: colors.secondary }]}>₺{day.estimatedCost}</Text>
                        </View>
                        
                        {day.activities.map((act, i) => (
                            <View key={i} style={styles.activityRow}>
                                <View style={[styles.activityDot, { backgroundColor: colors.secondary }]}><Text style={styles.dotText}>{i+1}</Text></View>
                                <View style={styles.activityContent}>
                                    <Text style={[styles.actName, { color: colors.textPrimary }]} numberOfLines={2}>{act.name}</Text>
                                    <Text style={[styles.actTime, { color: colors.secondary }]}>🕐 {act.startTime} - {act.endTime}</Text>
                                    <Text style={[styles.actDesc, { color: colors.textSecondary }]}>{act.description}</Text>
                                    {act.entryFee > 0 && <Text style={[styles.actFee, { color: colors.accent, backgroundColor: colors.isDark ? 'rgba(255,107,53,0.1)' : 'rgba(255,149,0,0.1)' }]}>💰 ₺{act.entryFee}</Text>}
                                    {act.transportInfo && <Text style={[styles.actTransport, { color: colors.textSecondary }]}>🚇 {act.transportInfo}</Text>}
                                </View>
                            </View>
                        ))}
                    </View>
                ))}

                {/* 5. Bütçe Dağılımı */}
                <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>💰 Bütçe Dağılımı</Text>
                <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                    <Text style={[styles.cardText, { color: colors.textSecondary }]}>
                        ✈️ Ulaşım: {formatPrice(plan.budgetBreakdown?.transportation || 0)}{'\n'}
                        🏨 Konaklama: {formatPrice(plan.budgetBreakdown?.accommodation || 0)}{'\n'}
                        🍔 Yeme İçme: {formatPrice(plan.budgetBreakdown?.food || 0)}{'\n'}
                        🚇 Şehir İçi Ulaşım: {formatPrice(plan.budgetBreakdown?.localTransport || 0)}{'\n'}
                        🎉 Eğlence & Aktiviteler: {formatPrice(plan.budgetBreakdown?.activities || 0)}{'\n'}
                        🛍️ Diğer/Alışveriş: {formatPrice(plan.budgetBreakdown?.miscellaneous || 0)}{'\n'}
                        ──────────────{'\n'}
                        <Text style={{fontWeight: 'bold'}}>Toplam: {formatPrice(plan.budgetBreakdown?.total || plan.totalEstimatedCost)}</Text>
                    </Text>
                </View>

            </ScrollView>

            {/* Harita Butonu (Floating) */}
            <TouchableOpacity style={[styles.floatingButton, { backgroundColor: colors.isDark ? colors.secondary : '#1C1C1E', shadowColor: colors.isDark ? colors.secondary : '#1C1C1E' }]} onPress={handleOpenMap}>
                <Ionicons name="map" size={20} color="#FFF" style={{ marginRight: 8 }} />
                <Text style={styles.floatingButtonText}>Haritada Gör</Text>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    header: { flexDirection: 'row', alignItems: 'center', paddingTop: AppLayout.headerPaddingTop, paddingHorizontal: AppLayout.defaultPadding, paddingBottom: verticalScale(8) },
    backButton: { width: scale(40), height: scale(40), borderRadius: scale(20), justifyContent: 'center', alignItems: 'center', marginRight: scale(14) },
    headerTitleText: { fontSize: moderateScale(22), fontWeight: 'bold' },
    scroll: { flex: 1 },
    content: { padding: AppLayout.defaultPadding, paddingBottom: verticalScale(100) },
    heroCard: { borderRadius: scale(20), padding: scale(18), marginBottom: verticalScale(18) },
    heroTitle: { fontSize: moderateScale(24), fontWeight: 'bold', marginBottom: verticalScale(4) },
    heroSubtitle: { fontSize: moderateScale(14), fontWeight: '500', marginBottom: verticalScale(6) },
    heroDesc: { fontSize: moderateScale(13), lineHeight: moderateScale(19) },
    card: { borderRadius: AppLayout.cornerRadius, padding: scale(14), marginBottom: verticalScale(14) },
    cardTitle: { fontSize: moderateScale(16), fontWeight: 'bold', marginBottom: verticalScale(6) },
    cardText: { fontSize: moderateScale(13), lineHeight: moderateScale(20) },
    sectionTitle: { fontSize: moderateScale(20), fontWeight: 'bold', marginTop: verticalScale(8), marginBottom: verticalScale(14) },
    dayHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', borderBottomWidth: 1, paddingBottom: verticalScale(10), marginBottom: verticalScale(10) },
    dayTitle: { fontSize: moderateScale(16), fontWeight: 'bold', flex: 1, marginRight: scale(8) },
    dayCost: { fontSize: moderateScale(15), fontWeight: 'bold' },
    activityRow: { flexDirection: 'row', marginBottom: verticalScale(14) },
    activityDot: { width: scale(24), height: scale(24), borderRadius: scale(12), alignItems: 'center', justifyContent: 'center', marginRight: scale(10), marginTop: verticalScale(2) },
    dotText: { color: '#FFF', fontSize: moderateScale(11), fontWeight: 'bold' },
    activityContent: { flex: 1 },
    actName: { fontSize: moderateScale(15), fontWeight: 'bold', marginBottom: verticalScale(2) },
    actTime: { fontSize: moderateScale(12), marginBottom: verticalScale(3) },
    actDesc: { fontSize: moderateScale(13), marginBottom: verticalScale(3) },
    actFee: { fontSize: moderateScale(11), alignSelf: 'flex-start', paddingHorizontal: scale(8), paddingVertical: verticalScale(2), borderRadius: scale(8), marginBottom: verticalScale(3), overflow: 'hidden' },
    actTransport: { fontSize: moderateScale(12) },
    floatingButton: { position: 'absolute', bottom: verticalScale(30), alignSelf: 'center', flexDirection: 'row', paddingVertical: verticalScale(14), paddingHorizontal: scale(24), borderRadius: scale(30), elevation: 8, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.4, shadowRadius: 8 },
    floatingButtonText: { color: '#FFF', fontSize: moderateScale(15), fontWeight: 'bold' }
});
