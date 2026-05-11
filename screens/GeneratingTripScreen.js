// GeneratingTripScreen.js
import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors } from './theme';
import { aiTripPlannerService } from '../AITripPlannerService';

export default function GeneratingTripScreen({ route, navigation }) {
    const { city, days, budget } = route.params;
    const scaleAnim = useRef(new Animated.Value(1)).current;

    useEffect(() => {
        // Atan/büyüyen animasyon efekti
        Animated.loop(
            Animated.sequence([
                Animated.timing(scaleAnim, {
                    toValue: 1.15,
                    duration: 1000,
                    useNativeDriver: true,
                }),
                Animated.timing(scaleAnim, {
                    toValue: 1,
                    duration: 1000,
                    useNativeDriver: true,
                })
            ])
        ).start();

        // AI Servisini Çağır (Asenkron)
        generatePlans();
    }, []);

    const generatePlans = async () => {
        try {
            // Biraz bekleme hissi ver (Min 2 saniye animasyon görünsün)
            const [plans] = await Promise.all([
                aiTripPlannerService.generateTripPlans(city, days, budget),
                new Promise(resolve => setTimeout(resolve, 2000))
            ]);

            // Sonuç sayfasına git
            navigation.replace('TripAlternatives', {
                city, days, budget, plans
            });

        } catch (error) {
            console.error("Plan oluşturulurken hata:", error);
            alert("Üzgünüz, bir hata oluştu.");
            navigation.goBack();
        }
    };

    return (
        <View style={styles.container}>
            <Animated.View style={[styles.iconContainer, { transform: [{ scale: scaleAnim }] }]}>
                <Ionicons name="sparkles" size={60} color="#FFF" />
            </Animated.View>

            <Text style={styles.title}>AI Planınız Hazırlanıyor...</Text>
            <Text style={styles.subtitle}>
                {days} günlük {city} seyahatiniz için en uygun rotalar,
                ulaşım ve otel seçenekleri hesaplanıyor.
            </Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
        alignItems: 'center',
        justifyContent: 'center',
        paddingHorizontal: 30,
    },
    iconContainer: {
        width: 120,
        height: 120,
        borderRadius: 60,
        backgroundColor: AppColors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 40,
        shadowColor: AppColors.secondary,
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.6,
        shadowRadius: 30,
        elevation: 10,
    },
    title: {
        fontSize: 22,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        textAlign: 'center',
        marginBottom: 12,
    },
    subtitle: {
        fontSize: 15,
        color: AppColors.textSecondary,
        textAlign: 'center',
        lineHeight: 22,
    }
});
