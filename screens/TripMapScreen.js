// TripMapScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions, ScrollView, Linking, Platform } from 'react-native';
import MapView, { Marker, Polyline, PROVIDER_DEFAULT } from 'react-native-maps'; // expo install react-native-maps
import { Ionicons } from '@expo/vector-icons';
import { AppColors } from './theme';
import { hapticManager } from '../HapticManager';

const { width, height } = Dimensions.get('window');

export default function TripMapScreen({ route, navigation }) {
    const { plan } = route.params;
    const [selectedActivity, setSelectedActivity] = useState(null);
    const [selectedDayIndex, setSelectedDayIndex] = useState(-1); // -1: Tümü, 0: Gün 1, vb.

    // Seçilen günleri belirle
    const daysToShow = selectedDayIndex === -1 ? plan.dailyPlans : [plan.dailyPlans[selectedDayIndex]];

    // Sadece gösterilecek günlerin koordinatlarını toplayıp harita merkezini bulalım
    const visibleCoordinates = [{
        latitude: plan.hotel.latitude,
        longitude: plan.hotel.longitude
    }];

    daysToShow.forEach(day => {
        day.activities.forEach(act => {
            visibleCoordinates.push({
                latitude: act.latitude,
                longitude: act.longitude
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

    const initialRegion = getRegionForCoordinates(visibleCoordinates);

    const handleClose = () => {
        hapticManager.lightImpact();
        navigation.goBack();
    };

    const handleDirections = () => {
        if (!selectedActivity) return;
        hapticManager.buttonTap();
        
        let lat, lng, name;
        if (selectedActivity.isHotel) {
            lat = plan.hotel.latitude;
            lng = plan.hotel.longitude;
            name = plan.hotel.name;
        } else {
            lat = selectedActivity.lat;
            lng = selectedActivity.lng;
            name = selectedActivity.name.replace(/^\d+\.\s*/, ''); // Baştaki rakamı temizle
        }

        const scheme = Platform.select({ ios: 'maps:0,0?q=', android: 'geo:0,0?q=' });
        const latLng = `${lat},${lng}`;
        const url = Platform.select({
            ios: `${scheme}${name}@${latLng}`,
            android: `${scheme}${latLng}(${name})`
        });
        
        Linking.openURL(url).catch(err => console.error('An error occurred', err));
    };

    // Tüm rotayı kronolojik olarak birleştir (Swift'teki gibi tek çizgi)
    const routeCoordinates = [{ latitude: plan.hotel.latitude, longitude: plan.hotel.longitude }];
    daysToShow.forEach(day => {
        day.activities.forEach(act => {
            routeCoordinates.push({ latitude: act.latitude, longitude: act.longitude });
        });
    });

    return (
        <View style={styles.container}>
            {/* Harita */}
            <MapView 
                style={styles.map}
                provider={PROVIDER_DEFAULT}
                region={initialRegion} // initialRegion yerine region kullanarak dinamik zoom yapıyoruz
            >
                <Marker 
                    coordinate={{ latitude: plan.hotel.latitude, longitude: plan.hotel.longitude }}
                    title={plan.hotel.name}
                    onPress={() => setSelectedActivity({ name: plan.hotel.name, desc: plan.hotel.address, badge: "Konaklama", isHotel: true })}
                >
                    <View style={[styles.customPin, { backgroundColor: AppColors.accent, width: 36, height: 36, borderRadius: 18 }]}>
                        <Ionicons name="bed" size={20} color="#FFF" />
                    </View>
                </Marker>

                {/* Tek ve Sürekli Rota Çizgisi */}
                <Polyline 
                    coordinates={routeCoordinates} 
                    strokeColor={AppColors.primary} 
                    strokeWidth={4} 
                    lineDashPattern={[8, 4]}
                />

                {/* Aktivite Marker'ları */}
                {daysToShow.map((day) => {
                    const routeColors = [AppColors.primary, AppColors.secondary, '#4CAF50', '#9C27B0', '#FF9800'];
                    const color = routeColors[(day.dayNumber - 1) % routeColors.length];

                    return (
                        <React.Fragment key={`day-markers-${day.dayNumber}`}>
                            {day.activities.map((act, actIndex) => (
                                <Marker 
                                    key={`act-${day.dayNumber}-${actIndex}`}
                                    coordinate={{ latitude: act.latitude, longitude: act.longitude }}
                                    title={`${actIndex+1}. ${act.name}`}
                                    onPress={() => setSelectedActivity({ 
                                        name: `${actIndex+1}. ${act.name}`, 
                                        desc: act.address, 
                                        badge: `Gün ${day.dayNumber} - ${act.category}`,
                                        lat: act.latitude,
                                        lng: act.longitude,
                                        isHotel: false
                                    })}
                                >
                                    <View style={[styles.customPin, { backgroundColor: color }]}>
                                        <Text style={styles.customPinText}>{actIndex + 1}</Text>
                                    </View>
                                </Marker>
                            ))}
                        </React.Fragment>
                    );
                })}
            </MapView>

            {/* Gün Filtresi (Segmented Control) */}
            <View style={styles.segmentContainer}>
                <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.segmentScroll}>
                    <TouchableOpacity 
                        style={[styles.segmentButton, selectedDayIndex === -1 && styles.segmentButtonActive]}
                        onPress={() => { hapticManager.lightImpact(); setSelectedDayIndex(-1); }}
                    >
                        <Text style={[styles.segmentText, selectedDayIndex === -1 && styles.segmentTextActive]}>Tümü</Text>
                    </TouchableOpacity>
                    
                    {plan.dailyPlans.map((day, idx) => (
                        <TouchableOpacity 
                            key={`seg-${idx}`}
                            style={[styles.segmentButton, selectedDayIndex === idx && styles.segmentButtonActive]}
                            onPress={() => { hapticManager.lightImpact(); setSelectedDayIndex(idx); }}
                        >
                            <Text style={[styles.segmentText, selectedDayIndex === idx && styles.segmentTextActive]}>Gün {day.dayNumber}</Text>
                        </TouchableOpacity>
                    ))}
                </ScrollView>
            </View>

            {/* Kapat Butonu */}
            <TouchableOpacity style={styles.closeButton} onPress={handleClose}>
                <Ionicons name="close-circle" size={40} color="rgba(0,0,0,0.6)" />
            </TouchableOpacity>

            {/* Alt Bilgi Kartı */}
            <View style={styles.infoCard}>
                <View style={styles.infoContent}>
                    <View style={{ flex: 1 }}>
                        <Text style={styles.infoTitle}>{selectedActivity?.name || "Rota Detayı"}</Text>
                        <Text style={styles.infoSubtitle} numberOfLines={2}>
                            {selectedActivity?.desc || `${daysToShow.reduce((acc, d) => acc + d.activities.length, 0)} Durak gösteriliyor`}
                        </Text>
                        {selectedActivity && (
                            <View style={styles.badge}>
                                <Text style={styles.badgeText}>{selectedActivity.badge.toUpperCase()}</Text>
                            </View>
                        )}
                    </View>
                    
                    {/* Yol Tarifi Butonu */}
                    {selectedActivity && (
                        <TouchableOpacity style={styles.directionsButton} onPress={handleDirections}>
                            <Ionicons name="navigate" size={24} color="#FFF" />
                            <Text style={styles.directionsText}>Yol Tarifi</Text>
                        </TouchableOpacity>
                    )}
                </View>
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
        paddingBottom: 30, // iPhone alt çentiği için ekstra boşluk
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -4 },
        shadowOpacity: 0.2,
        shadowRadius: 10,
        elevation: 10,
    },
    infoContent: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
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
        fontSize: 11,
        fontWeight: 'bold',
    },
    directionsButton: {
        backgroundColor: '#4285F4', // Apple Maps/Google Maps mavi rengi
        width: 80,
        height: 80,
        borderRadius: 40,
        alignItems: 'center',
        justifyContent: 'center',
        marginLeft: 10,
        shadowColor: '#4285F4',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.4,
        shadowRadius: 8,
        elevation: 6,
    },
    directionsText: {
        color: '#FFF',
        fontSize: 12,
        fontWeight: 'bold',
        marginTop: 4,
    },
    segmentContainer: {
        position: 'absolute',
        top: 50,
        left: 20,
        right: 70, // kapat butonuna yer bırak
        height: 40,
    },
    segmentScroll: {
        alignItems: 'center',
    },
    segmentButton: {
        backgroundColor: 'rgba(255,255,255,0.9)',
        paddingHorizontal: 16,
        paddingVertical: 8,
        borderRadius: 20,
        marginRight: 8,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.2,
        shadowRadius: 4,
        elevation: 4,
    },
    segmentButtonActive: {
        backgroundColor: AppColors.primary,
    },
    segmentText: {
        color: AppColors.textPrimary,
        fontWeight: '600',
    },
    segmentTextActive: {
        color: '#FFF',
    },
    customPin: {
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: AppColors.primary,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 2,
        borderColor: '#FFF',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.3,
        shadowRadius: 3,
        elevation: 4,
    },
    customPinText: {
        color: '#FFF',
        fontSize: 14,
        fontWeight: 'bold',
    }
});
