// TripMapScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions } from 'react-native';
import MapView, { Marker, Polyline, PROVIDER_DEFAULT } from 'react-native-maps'; // expo install react-native-maps
import { Ionicons } from '@expo/vector-icons';
import { AppColors } from './theme';
import { hapticManager } from '../HapticManager';

const { width, height } = Dimensions.get('window');

export default function TripMapScreen({ route, navigation }) {
    const { plan } = route.params;
    const [selectedActivity, setSelectedActivity] = useState(null);

    // Tüm koordinatları topla
    const allCoordinates = [];
    allCoordinates.push({
        latitude: plan.hotel.coordinate.latitude,
        longitude: plan.hotel.coordinate.longitude
    });

    plan.dailyPlans.forEach(day => {
        day.activities.forEach(act => {
            allCoordinates.push({
                latitude: act.coordinate.latitude,
                longitude: act.coordinate.longitude
            });
        });
    });

    // Harita merkezini hesapla
    const getRegionForCoordinates = (points) => {
        if (!points || points.length === 0) return null;
        let minX, maxX, minY, maxY;
        (point => {
            minX = point.latitude;
            maxX = point.latitude;
            minY = point.longitude;
            maxY = point.longitude;
        })(points[0]);

        points.map(point => {
            minX = Math.min(minX, point.latitude);
            maxX = Math.max(maxX, point.latitude);
            minY = Math.min(minY, point.longitude);
            maxY = Math.max(maxY, point.longitude);
        });

        const midX = (minX + maxX) / 2;
        const midY = (minY + maxY) / 2;
        const deltaX = (maxX - minX) * 1.5 || 0.05;
        const deltaY = (maxY - minY) * 1.5 || 0.05;

        return {
            latitude: midX,
            longitude: midY,
            latitudeDelta: deltaX,
            longitudeDelta: deltaY
        };
    };

    const initialRegion = getRegionForCoordinates(allCoordinates);

    const handleClose = () => {
        hapticManager.lightImpact();
        navigation.goBack();
    };

    return (
        <View style={styles.container}>
            {/* Harita */}
            <MapView 
                style={styles.map}
                provider={PROVIDER_DEFAULT}
                initialRegion={initialRegion}
            >
                {/* Otel Marker */}
                <Marker 
                    coordinate={{ latitude: plan.hotel.coordinate.latitude, longitude: plan.hotel.coordinate.longitude }}
                    title={plan.hotel.name}
                    pinColor={AppColors.accent}
                    onPress={() => setSelectedActivity({ name: plan.hotel.name, desc: plan.hotel.address, badge: "Konaklama" })}
                />

                {/* Aktivite Marker'ları ve Polyline (Günlere göre) */}
                {plan.dailyPlans.map((day, dayIndex) => {
                    const dayCoords = day.activities.map(a => ({ latitude: a.coordinate.latitude, longitude: a.coordinate.longitude }));
                    
                    // Önceki günden bu güne bağlantı veya otelden bu güne bağlantı eklenebilir. 
                    // Basitlik için sadece o günün aktivitelerini bağlayalım.
                    
                    return (
                        <React.Fragment key={`day-${dayIndex}`}>
                            <Polyline 
                                coordinates={dayCoords} 
                                strokeColor={AppColors.primary} 
                                strokeWidth={3} 
                                lineDashPattern={[8, 4]} 
                            />
                            {day.activities.map((act, actIndex) => (
                                <Marker 
                                    key={`act-${dayIndex}-${actIndex}`}
                                    coordinate={{ latitude: act.coordinate.latitude, longitude: act.coordinate.longitude }}
                                    title={`${actIndex+1}. ${act.name}`}
                                    pinColor={AppColors.secondary}
                                    onPress={() => setSelectedActivity({ 
                                        name: `${actIndex+1}. ${act.name}`, 
                                        desc: act.address, 
                                        badge: act.category 
                                    })}
                                />
                            ))}
                        </React.Fragment>
                    );
                })}
            </MapView>

            {/* Kapat Butonu */}
            <TouchableOpacity style={styles.closeButton} onPress={handleClose}>
                <Ionicons name="close-circle" size={40} color="rgba(255,255,255,0.9)" />
            </TouchableOpacity>

            {/* Alt Bilgi Kartı */}
            <View style={styles.infoCard}>
                <Text style={styles.infoTitle}>{selectedActivity?.name || "Rota Detayı"}</Text>
                <Text style={styles.infoSubtitle} numberOfLines={3}>
                    {selectedActivity?.desc || `${allCoordinates.length} Durak gösteriliyor`}
                </Text>
                {selectedActivity && (
                    <View style={styles.badge}>
                        <Text style={styles.badgeText}>{selectedActivity.badge.toUpperCase()}</Text>
                    </View>
                )}
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    map: {
        width: width,
        height: height,
    },
    closeButton: {
        position: 'absolute',
        top: 50,
        right: 20,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.5,
        shadowRadius: 4,
    },
    infoCard: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        backgroundColor: AppColors.cardBackground,
        borderTopLeftRadius: 20,
        borderTopRightRadius: 20,
        padding: 20,
        height: 140,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -4 },
        shadowOpacity: 0.2,
        shadowRadius: 10,
        elevation: 10,
    },
    infoTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 8,
    },
    infoSubtitle: {
        fontSize: 14,
        color: AppColors.textSecondary,
        marginBottom: 8,
    },
    badge: {
        alignSelf: 'flex-start',
        backgroundColor: AppColors.secondary,
        paddingHorizontal: 12,
        paddingVertical: 4,
        borderRadius: 12,
    },
    badgeText: {
        color: '#FFF',
        fontSize: 12,
        fontWeight: 'bold',
    }
});
