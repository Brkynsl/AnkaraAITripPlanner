// TripMapScreen.js
import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions, ScrollView, Linking, Platform } from 'react-native';
import MapView, { Marker, Polyline, PROVIDER_DEFAULT } from 'react-native-maps';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { hapticManager } from '../HapticManager';
import { AppLayout, scale, verticalScale, moderateScale } from './theme';

const { width, height } = Dimensions.get('window');

export default function TripMapScreen({ route, navigation }) {
    const { plan } = route.params;
    const [selectedActivity, setSelectedActivity] = useState(null);
    const [selectedDayIndex, setSelectedDayIndex] = useState(-1);
    const { colors } = useTheme();

    const daysToShow = selectedDayIndex === -1 ? plan.dailyPlans : [plan.dailyPlans[selectedDayIndex]];

    const visibleCoordinates = [{
        latitude: plan.hotel.latitude,
        longitude: plan.hotel.longitude
    }];

    daysToShow.forEach(day => {
        day.activities.forEach(act => {
            visibleCoordinates.push({ latitude: act.latitude, longitude: act.longitude });
        });
    });

    const getRegionForCoordinates = (points) => {
        if (!points || points.length === 0) return null;
        let minX, maxX, minY, maxY;
        (point => { minX = point.latitude; maxX = point.latitude; minY = point.longitude; maxY = point.longitude; })(points[0]);

        points.map(point => {
            minX = Math.min(minX, point.latitude);
            maxX = Math.max(maxX, point.latitude);
            minY = Math.min(minY, point.longitude);
            maxY = Math.max(maxY, point.longitude);
        });

        return {
            latitude: (minX + maxX) / 2,
            longitude: (minY + maxY) / 2,
            latitudeDelta: (maxX - minX) * 1.5 || 0.05,
            longitudeDelta: (maxY - minY) * 1.5 || 0.05
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
            lat = plan.hotel.latitude; lng = plan.hotel.longitude; name = plan.hotel.name;
        } else {
            lat = selectedActivity.lat; lng = selectedActivity.lng; name = selectedActivity.name.replace(/^\d+\.\s*/, '');
        }

        const scheme = Platform.select({ ios: 'maps:0,0?q=', android: 'geo:0,0?q=' });
        const latLng = `${lat},${lng}`;
        const url = Platform.select({ ios: `${scheme}${name}@${latLng}`, android: `${scheme}${latLng}(${name})` });
        
        Linking.openURL(url).catch(err => console.error('An error occurred', err));
    };

    const routeCoordinates = [{ latitude: plan.hotel.latitude, longitude: plan.hotel.longitude }];
    daysToShow.forEach(day => {
        day.activities.forEach(act => {
            routeCoordinates.push({ latitude: act.latitude, longitude: act.longitude });
        });
    });

    return (
        <View style={styles.container}>
            <MapView 
                style={styles.map}
                provider={PROVIDER_DEFAULT}
                region={initialRegion}
                userInterfaceStyle={colors.isDark ? 'dark' : 'light'}
            >
                <Marker 
                    coordinate={{ latitude: plan.hotel.latitude, longitude: plan.hotel.longitude }}
                    title={plan.hotel.name}
                    onPress={() => setSelectedActivity({ name: plan.hotel.name, desc: plan.hotel.address, badge: "Konaklama", isHotel: true })}
                >
                    <View style={[styles.customPin, { backgroundColor: colors.accent }]}>
                        <Ionicons name="bed" size={20} color="#FFF" />
                    </View>
                </Marker>

                <Polyline coordinates={routeCoordinates} strokeColor={colors.secondary} strokeWidth={4} lineDashPattern={[8, 4]} />

                {daysToShow.map((day) => {
                    const routeColors = ['#E91E63', '#2196F3', '#4CAF50', '#9C27B0', '#FF9800'];
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
                                        lat: act.latitude, lng: act.longitude, isHotel: false
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

            <View style={styles.segmentContainer}>
                <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.segmentScroll}>
                    <TouchableOpacity 
                        style={[styles.segmentButton, { backgroundColor: colors.cardBackground }, selectedDayIndex === -1 && { backgroundColor: colors.isDark ? '#FFFFFF' : '#1C1C1E' }]}
                        onPress={() => { hapticManager.lightImpact(); setSelectedDayIndex(-1); }}
                    >
                        <Text style={[styles.segmentText, { color: colors.textPrimary }, selectedDayIndex === -1 && { color: colors.isDark ? '#000000' : '#FFFFFF' }]}>Tümü</Text>
                    </TouchableOpacity>
                    
                    {plan.dailyPlans.map((day, idx) => (
                        <TouchableOpacity 
                            key={`seg-${idx}`}
                            style={[styles.segmentButton, { backgroundColor: colors.cardBackground }, selectedDayIndex === idx && { backgroundColor: colors.isDark ? '#FFFFFF' : '#1C1C1E' }]}
                            onPress={() => { hapticManager.lightImpact(); setSelectedDayIndex(idx); }}
                        >
                            <Text style={[styles.segmentText, { color: colors.textPrimary }, selectedDayIndex === idx && { color: colors.isDark ? '#000000' : '#FFFFFF' }]}>Gün {day.dayNumber}</Text>
                        </TouchableOpacity>
                    ))}
                </ScrollView>
            </View>

            <TouchableOpacity style={styles.closeButton} onPress={handleClose}>
                <Ionicons name="close-circle" size={40} color={colors.isDark ? "rgba(0,0,0,0.6)" : "rgba(255,255,255,0.8)"} />
            </TouchableOpacity>

            <View style={[styles.infoCard, { backgroundColor: colors.cardBackground }]}>
                <View style={styles.infoContent}>
                    <View style={{ flex: 1 }}>
                        <Text style={[styles.infoTitle, { color: colors.textPrimary }]}>{selectedActivity?.name || "Rota Detayı"}</Text>
                        <Text style={[styles.infoSubtitle, { color: colors.textSecondary }]} numberOfLines={2}>
                            {selectedActivity?.desc || `${daysToShow.reduce((acc, d) => acc + d.activities.length, 0)} Durak gösteriliyor`}
                        </Text>
                        {selectedActivity && (
                            <View style={[styles.badge, { backgroundColor: colors.secondary }]}>
                                <Text style={styles.badgeText}>{selectedActivity.badge.toUpperCase()}</Text>
                            </View>
                        )}
                    </View>
                    
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
    container: { flex: 1 },
    map: { width, height },
    closeButton: { position: 'absolute', top: AppLayout.headerPaddingTop, right: scale(20), shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.5, shadowRadius: 4 },
    infoCard: { position: 'absolute', bottom: 0, left: 0, right: 0, borderTopLeftRadius: scale(20), borderTopRightRadius: scale(20), padding: scale(20), paddingBottom: verticalScale(30), shadowColor: '#000', shadowOffset: { width: 0, height: -4 }, shadowOpacity: 0.2, shadowRadius: 10, elevation: 10 },
    infoContent: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
    infoTitle: { fontSize: moderateScale(18), fontWeight: 'bold', marginBottom: verticalScale(8) },
    infoSubtitle: { fontSize: moderateScale(14), marginBottom: verticalScale(8) },
    badge: { alignSelf: 'flex-start', paddingHorizontal: scale(12), paddingVertical: verticalScale(4), borderRadius: scale(12) },
    badgeText: { color: '#FFF', fontSize: moderateScale(11), fontWeight: 'bold' },
    directionsButton: { backgroundColor: '#4285F4', width: scale(80), height: scale(80), borderRadius: scale(40), alignItems: 'center', justifyContent: 'center', marginLeft: scale(10), shadowColor: '#4285F4', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.4, shadowRadius: 8, elevation: 6 },
    directionsText: { color: '#FFF', fontSize: moderateScale(12), fontWeight: 'bold', marginTop: verticalScale(4) },
    segmentContainer: { position: 'absolute', top: AppLayout.headerPaddingTop, left: scale(20), right: scale(70), height: verticalScale(40) },
    segmentScroll: { alignItems: 'center' },
    segmentButton: { paddingHorizontal: scale(16), paddingVertical: verticalScale(8), borderRadius: scale(20), marginRight: scale(8), shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.2, shadowRadius: 4, elevation: 4 },
    segmentText: { fontWeight: '600', fontSize: moderateScale(14) },
    // segmentTextActive artık dinamik verildiği için kullanılmıyor
    customPin: { width: scale(30), height: scale(30), borderRadius: scale(15), justifyContent: 'center', alignItems: 'center', borderWidth: 2, borderColor: '#FFF', shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.3, shadowRadius: 3, elevation: 4 },
    customPinText: { color: '#FFF', fontSize: moderateScale(14), fontWeight: 'bold' }
});
