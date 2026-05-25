// TripPlanCard.js
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import MapView, { Marker, Polyline, PROVIDER_DEFAULT } from 'react-native-maps';
import { AppLayout } from './theme';
import { hapticManager } from '../HapticManager';
import { useTheme } from '../ThemeContext';

// Props olarak plan objesi ve onSelect fonksiyonu alır
export default function TripPlanCard({ plan, onSelect }) {
    const navigation = useNavigation();
    const { colors } = useTheme();
    
    const handleSelect = () => {
        hapticManager.lightImpact();
        if(onSelect) onSelect(plan);
    };

    const handleOpenMap = () => {
        hapticManager.lightImpact();
        navigation.navigate('TripMap', { plan: plan });
    };

    // Fiyat formatlama
    const formattedPrice = new Intl.NumberFormat('tr-TR', { 
        style: 'currency', 
        currency: 'TRY',
        maximumFractionDigits: 0
    }).format(plan.totalEstimatedCost);

    // Plan türüne göre ikon ve renk
    const getTypeIcon = (type) => {
        switch(type) {
            case 'economic': return 'leaf';
            case 'balanced': return 'scale';
            case 'comfort': return 'diamond';
            default: return 'map';
        }
    };

    // Harita önizleme için tüm noktaları topla
    const routeCoordinates = [{ latitude: plan.hotel.latitude, longitude: plan.hotel.longitude }];
    let minX = plan.hotel.latitude, maxX = plan.hotel.latitude;
    let minY = plan.hotel.longitude, maxY = plan.hotel.longitude;

    plan.dailyPlans.forEach(day => {
        day.activities.forEach(act => {
            routeCoordinates.push({ latitude: act.latitude, longitude: act.longitude });
            minX = Math.min(minX, act.latitude);
            maxX = Math.max(maxX, act.latitude);
            minY = Math.min(minY, act.longitude);
            maxY = Math.max(maxY, act.longitude);
        });
    });

    const region = {
        latitude: (minX + maxX) / 2,
        longitude: (minY + maxY) / 2,
        latitudeDelta: Math.max((maxX - minX) * 1.5, 0.05),
        longitudeDelta: Math.max((maxY - minY) * 1.5, 0.05)
    };

    return (
        <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA, borderColor: colors.border }]}>
            {/* Header */}
            <View style={styles.header}>
                <View style={[styles.iconContainer, { backgroundColor: colors.isDark ? 'rgba(255,255,255,0.8)' : 'rgba(0,199,191,0.2)' }]}>
                    <Ionicons name={getTypeIcon(plan.planType)} size={20} color={colors.primary} />
                </View>
                <Text style={[styles.title, { color: colors.textPrimary }]} numberOfLines={1}>{plan.title}</Text>
                <Text style={[styles.scoreText, { color: colors.success }]}>%{plan.fitScore} Eşleşme</Text>
            </View>

            {/* Description */}
            <Text style={[styles.description, { color: colors.textSecondary }]} numberOfLines={2}>
                {plan.description}
            </Text>

            {/* Map Preview (Tıklanabilir) */}
            <TouchableOpacity style={[styles.mapContainer, { borderColor: colors.border }]} activeOpacity={0.8} onPress={handleOpenMap}>
                <MapView
                    style={styles.map}
                    provider={PROVIDER_DEFAULT}
                    region={region}
                    scrollEnabled={false}
                    zoomEnabled={false}
                    pitchEnabled={false}
                    rotateEnabled={false}
                    liteMode={Platform.OS === 'android'}
                >
                    {/* Sadece Rotayı Göster */}
                    <Polyline 
                        coordinates={routeCoordinates} 
                        strokeColor={colors.primary} 
                        strokeWidth={3} 
                    />
                    <Marker coordinate={{ latitude: plan.hotel.latitude, longitude: plan.hotel.longitude }} pinColor={colors.accent} />
                </MapView>
                <View style={styles.mapOverlay} pointerEvents="none">
                    <Ionicons name="expand" size={12} color="#FFF" style={{ marginRight: 4 }} />
                    <Text style={styles.mapOverlayText}>Tam Ekranda İncele</Text>
                </View>
            </TouchableOpacity>

            {/* Info Stack (Otel & Ulaşım) */}
            <View style={[styles.infoStack, { backgroundColor: colors.iconBackground }]}>
                <View style={styles.infoItem}>
                    <Ionicons name="bed" size={14} color={colors.textSecondary} />
                    <Text style={[styles.infoText, { color: colors.textPrimary }]} numberOfLines={1}>{plan.hotel.name}</Text>
                </View>
                <View style={styles.infoItem}>
                    <Ionicons name="airplane" size={14} color={colors.textSecondary} />
                    <Text style={[styles.infoText, { color: colors.textPrimary }]} numberOfLines={1}>{plan.transportation.provider}</Text>
                </View>
            </View>

            {/* Bottom Stack (Fiyat & Seç Butonu) */}
            <View style={styles.bottomStack}>
                <Text style={[styles.price, { color: colors.textPrimary }]}>{formattedPrice}</Text>
                <TouchableOpacity style={[styles.selectButton, { backgroundColor: colors.secondary }]} onPress={handleSelect}>
                    <Text style={styles.selectButtonText}>Bu Planı Seç</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    card: {
        borderRadius: AppLayout.largeCornerRadius,
        padding: AppLayout.defaultPadding,
        marginHorizontal: AppLayout.defaultPadding,
        marginBottom: 16,
        borderWidth: 1,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 12,
    },
    iconContainer: {
        width: 40,
        height: 40,
        borderRadius: 20,
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 12,
    },
    title: {
        flex: 1,
        fontSize: 18,
        fontWeight: 'bold',
        marginRight: 8,
    },
    scoreText: {
        fontSize: 14,
        fontWeight: 'bold',
    },
    description: {
        fontSize: 14,
        lineHeight: 20,
        marginBottom: 12,
    },
    mapContainer: {
        height: 120,
        borderRadius: 12,
        overflow: 'hidden',
        marginBottom: 16,
        borderWidth: 1,
    },
    map: {
        ...StyleSheet.absoluteFillObject,
    },
    mapOverlay: {
        position: 'absolute',
        bottom: 8,
        right: 8,
        backgroundColor: 'rgba(0,0,0,0.7)',
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 10,
        paddingVertical: 6,
        borderRadius: 12,
    },
    mapOverlayText: {
        color: '#FFF',
        fontSize: 11,
        fontWeight: 'bold',
    },
    infoStack: {
        flexDirection: 'row',
        borderRadius: 12,
        paddingVertical: 8,
        paddingHorizontal: 12,
        marginBottom: 20,
    },
    infoItem: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
    },
    infoText: {
        fontSize: 13,
        marginLeft: 6,
    },
    bottomStack: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    price: {
        fontSize: 20,
        fontWeight: 'bold',
    },
    selectButton: {
        paddingVertical: 10,
        paddingHorizontal: 16,
        borderRadius: AppLayout.cornerRadius,
    },
    selectButtonText: {
        color: '#FFF',
        fontSize: 14,
        fontWeight: 'bold',
    }
});
