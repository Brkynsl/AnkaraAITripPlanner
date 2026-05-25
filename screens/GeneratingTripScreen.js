// GeneratingTripScreen.js
import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { aiTripPlannerService } from '../AITripPlannerService';

export default function GeneratingTripScreen({ route, navigation }) {
    const { city, days, budget } = route.params;
    const scaleAnim = useRef(new Animated.Value(1)).current;
    const { colors } = useTheme();

    useEffect(() => {
        Animated.loop(
            Animated.sequence([
                Animated.timing(scaleAnim, { toValue: 1.15, duration: 1000, useNativeDriver: true }),
                Animated.timing(scaleAnim, { toValue: 1, duration: 1000, useNativeDriver: true })
            ])
        ).start();

        generatePlans();
    }, []);

    const generatePlans = async () => {
        try {
            const [plans] = await Promise.all([
                aiTripPlannerService.generateTripPlans(city, days, budget),
                new Promise(resolve => setTimeout(resolve, 2000))
            ]);

            navigation.replace('TripAlternatives', { city, days, budget, plans });
        } catch (error) {
            console.error("Plan oluşturulurken hata:", error);
            alert("Üzgünüz, bir hata oluştu.");
            navigation.goBack();
        }
    };

    return (
        <View style={[styles.container, { backgroundColor: colors.background }]}>
            <Animated.View style={[styles.iconContainer, { backgroundColor: colors.secondary, shadowColor: colors.secondary, transform: [{ scale: scaleAnim }] }]}>
                <Ionicons name="sparkles" size={60} color="#FFF" />
            </Animated.View>

            <Text style={[styles.title, { color: colors.textPrimary }]}>AI Planınız Hazırlanıyor...</Text>
            <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
                {days} günlük {city} seyahatiniz için en uygun rotalar,
                ulaşım ve otel seçenekleri hesaplanıyor.
            </Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 30 },
    iconContainer: { width: 120, height: 120, borderRadius: 60, alignItems: 'center', justifyContent: 'center', marginBottom: 40, shadowOffset: { width: 0, height: 0 }, shadowOpacity: 0.6, shadowRadius: 30, elevation: 10 },
    title: { fontSize: 22, fontWeight: 'bold', textAlign: 'center', marginBottom: 12 },
    subtitle: { fontSize: 15, textAlign: 'center', lineHeight: 22 }
});
