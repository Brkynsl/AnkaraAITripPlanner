// HomeScreen.js
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout } from './theme';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';

export default function HomeScreen({ navigation }) {
    const [userName, setUserName] = useState('');
    const { colors } = useTheme();

    useEffect(() => {
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
        <ScrollView style={[styles.container, { backgroundColor: colors.background }]} contentContainerStyle={styles.content}>
            <Text style={[styles.greeting, { color: colors.textSecondary }]}>Merhaba,</Text>
            <Text style={[styles.userName, { color: colors.textPrimary }]}>{userName || 'Gezgin'} 👋</Text>

            {/* Welcome Card */}
            <View style={[styles.welcomeCard, { backgroundColor: colors.isDark ? 'rgba(0, 199, 191, 0.15)' : 'rgba(0, 199, 191, 0.08)', borderColor: colors.isDark ? 'rgba(0, 199, 191, 0.3)' : 'rgba(0, 199, 191, 0.2)' }]}>
                <Ionicons name="sparkles" size={32} color={colors.secondary} style={{ marginBottom: 12 }} />
                <Text style={[styles.welcomeTitle, { color: colors.textPrimary }]}>AI ile Seyahat Planla</Text>
                <Text style={[styles.welcomeDesc, { color: colors.textSecondary }]}>
                    Bütçene, gün sayısına ve tercihlerine göre yapay zeka senin için en uygun tatil planını oluştursun.
                </Text>
                <TouchableOpacity 
                    style={[styles.createButton, { backgroundColor: colors.secondary }]} 
                    onPress={handleCreateTrip}
                    activeOpacity={0.8}
                >
                    <Ionicons name="add" size={22} color="#FFF" style={{ marginRight: 8 }} />
                    <Text style={styles.createButtonText}>Yeni Plan Oluştur</Text>
                </TouchableOpacity>
            </View>

            {/* Feature Icons */}
            <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Neler Planlıyoruz?</Text>
            <View style={styles.featuresRow}>
                {features.map((item, index) => (
                    <View key={index} style={styles.featureItem}>
                        <View style={[styles.featureIcon, { backgroundColor: item.color + '15' }]}>
                            <Ionicons name={item.icon} size={24} color={item.color} />
                        </View>
                        <Text style={[styles.featureText, { color: colors.textSecondary }]}>{item.title}</Text>
                    </View>
                ))}
            </View>

            {/* Info Card */}
            <View style={[styles.infoCard, { backgroundColor: colors.cardBackgroundRGBA, borderColor: colors.border }]}>
                <Ionicons name="information-circle" size={20} color={colors.secondary} style={{ marginRight: 10 }} />
                <Text style={[styles.infoText, { color: colors.textSecondary }]}>
                    Şu an Ankara ve İstanbul şehirleri için gerçek veri ile plan üretiyoruz.
                </Text>
            </View>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    content: { paddingTop: 60, paddingHorizontal: AppLayout.largePadding, paddingBottom: 40 },
    greeting: { fontSize: 16, fontWeight: '500' },
    userName: { fontSize: 32, fontWeight: 'bold', marginBottom: 24 },
    welcomeCard: { borderRadius: AppLayout.largeCornerRadius, padding: 24, marginBottom: 32, borderWidth: 1 },
    welcomeTitle: { fontSize: 22, fontWeight: 'bold', marginBottom: 8 },
    welcomeDesc: { fontSize: 14, lineHeight: 22, marginBottom: 20 },
    createButton: { flexDirection: 'row', height: AppLayout.buttonHeight, borderRadius: AppLayout.cornerRadius, alignItems: 'center', justifyContent: 'center' },
    createButtonText: { color: '#FFF', fontSize: 16, fontWeight: 'bold' },
    sectionTitle: { fontSize: 20, fontWeight: 'bold', marginBottom: 16 },
    featuresRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 32 },
    featureItem: { alignItems: 'center', flex: 1 },
    featureIcon: { width: 50, height: 50, borderRadius: 25, alignItems: 'center', justifyContent: 'center', marginBottom: 8 },
    featureText: { fontSize: 12, fontWeight: '500' },
    infoCard: { flexDirection: 'row', alignItems: 'center', borderRadius: AppLayout.cornerRadius, padding: 16, borderWidth: 1 },
    infoText: { flex: 1, fontSize: 13, lineHeight: 20 },
});
