// HomeScreen.js
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BlurView } from 'expo-blur';
import { AppColors, AppLayout } from './theme';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';

export default function HomeScreen({ navigation }) {
    const [userName, setUserName] = useState('');

    useEffect(() => {
        // Kullanıcı adını al
        const user = firebaseAuthService.currentFirebaseUser;
        if (user && user.displayName) {
            setUserName(user.displayName);
        }
    }, []);

    const features = [
        { icon: "airplane", title: "Ulaşım", color: "#FF6B35" },
        { icon: "bed", title: "Konaklama", color: "#00B4D8" },
        { icon: "restaurant", title: "Yeme-İçme", color: "#2EC4B6" },
        { icon: "business", title: "Müzeler", color: "#9B5DE5" },
        { icon: "map", title: "Rotalar", color: "#F15BB5" }
    ];

    const handleCreateTrip = () => {
        hapticManager.cardSelect();
        navigation.navigate('TripBuilder');
    };

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            {/* Header / Navigation Bar Benzeri */}
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Ana Sayfa</Text>
            </View>

            {/* Hoşgeldin Kartı */}
            <BlurView intensity={20} tint="dark" style={styles.welcomeCard}>
                <Text style={styles.welcomeLabel}>
                    Merhaba{userName ? `, ${userName}` : ''}! 👋
                </Text>
                <Text style={styles.welcomeSubtitle}>
                    Yeni bir seyahat planlamaya ne dersin?
                </Text>
            </BlurView>

            {/* Ana Buton */}
            <TouchableOpacity 
                style={styles.createTripButton}
                activeOpacity={0.8}
                onPress={handleCreateTrip}
            >
                <Ionicons name="sparkles" size={24} color="#FFF" style={{ marginRight: 12 }} />
                <View>
                    <Text style={styles.createTripTitle}>Yeni Plan Oluştur</Text>
                    <Text style={styles.createTripSubtitle}>AI destekli seyahat planınızı oluşturun</Text>
                </View>
            </TouchableOpacity>

            {/* Özellikler Yatay Liste */}
            <ScrollView 
                horizontal 
                showsHorizontalScrollIndicator={false} 
                style={styles.featuresScroll}
                contentContainerStyle={styles.featuresContent}
            >
                {features.map((feature, index) => (
                    <View key={index} style={[styles.featureCard, { backgroundColor: `${feature.color}20` }]}>
                        <Ionicons name={feature.icon} size={32} color={feature.color} style={styles.featureIcon} />
                        <Text style={styles.featureTitle}>{feature.title}</Text>
                    </View>
                ))}
            </ScrollView>

            {/* Boş Durum İkonu */}
            <View style={styles.emptyStateContainer}>
                <Ionicons name="map-outline" size={120} color="rgba(255,255,255,0.1)" />
            </View>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
    },
    content: {
        paddingTop: 60, // Safe Area Top Offset
        paddingBottom: 40,
    },
    header: {
        paddingHorizontal: AppLayout.largePadding,
        marginBottom: 20,
    },
    headerTitle: {
        fontSize: 34,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
    },
    welcomeCard: {
        marginHorizontal: AppLayout.defaultPadding,
        padding: AppLayout.largePadding,
        borderRadius: AppLayout.largeCornerRadius,
        backgroundColor: AppColors.cardBackground,
        borderWidth: 1,
        borderColor: AppColors.border,
        overflow: 'hidden',
        marginBottom: 24,
    },
    welcomeLabel: {
        fontSize: 24,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 4,
    },
    welcomeSubtitle: {
        fontSize: 15,
        color: AppColors.textSecondary,
    },
    createTripButton: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: AppColors.secondary,
        marginHorizontal: AppLayout.defaultPadding,
        padding: 20,
        borderRadius: AppLayout.largeCornerRadius,
        marginBottom: 32,
    },
    createTripTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#FFF',
    },
    createTripSubtitle: {
        fontSize: 13,
        color: 'rgba(255,255,255,0.8)',
        marginTop: 4,
    },
    featuresScroll: {
        height: 120,
    },
    featuresContent: {
        paddingHorizontal: AppLayout.defaultPadding,
        gap: 12,
    },
    featureCard: {
        width: 100,
        borderRadius: AppLayout.cornerRadius,
        padding: 12,
        alignItems: 'center',
        justifyContent: 'center',
    },
    featureIcon: {
        marginBottom: 8,
    },
    featureTitle: {
        fontSize: 13,
        fontWeight: '500',
        color: AppColors.textPrimary,
    },
    emptyStateContainer: {
        alignItems: 'center',
        marginTop: 60,
    }
});
