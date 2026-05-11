// LocationManager.js
// Expo Location kullanılarak yazılmış konum yöneticisi (React Native uyumlu)

import * as Location from 'expo-location';

// İki nokta arasındaki mesafeyi metre cinsinden hesaplar (Haversine Formula)
export function distanceBetween(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // metres
    const φ1 = lat1 * Math.PI/180;
    const φ2 = lat2 * Math.PI/180;
    const Δφ = (lat2-lat1) * Math.PI/180;
    const Δλ = (lon2-lon1) * Math.PI/180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c; // in metres
}

class LocationManager {
    constructor() {
        this.lastKnownLocation = null;
    }

    // Konum İzni İsteme ve Mevcut Konumu Alma
    async getCurrentLocation() {
        try {
            // 1. İzin iste
            let { status } = await Location.requestForegroundPermissionsAsync();
            if (status !== 'granted') {
                throw new Error("Konum izni verilmemiş. Lütfen Ayarlar'dan konum iznini açın.");
            }

            // 2. Konumu al
            let location = await Location.getCurrentPositionAsync({
                accuracy: Location.Accuracy.Balanced // Yüz metre hassasiyeti için Balanced yeterli
            });

            this.lastKnownLocation = {
                latitude: location.coords.latitude,
                longitude: location.coords.longitude
            };

            return this.lastKnownLocation;
        } catch (error) {
            console.error("LocationManager hatası:", error);
            throw error;
        }
    }

    // Mesafeyi Okunabilir Formata Çevirme
    formatDistance(meters) {
        if (meters >= 1000) {
            return `${(meters / 1000).toFixed(1)} km`;
        } else {
            return `${Math.round(meters)} m`;
        }
    }
}

export const locationManager = new LocationManager();
