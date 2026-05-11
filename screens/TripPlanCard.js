// TripPlanCard.js
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import { hapticManager } from '../HapticManager';

// Props olarak plan objesi ve onSelect fonksiyonu alır
export default function TripPlanCard({ plan, onSelect }) {
    
    const handleSelect = () => {
        hapticManager.lightImpact();
        if(onSelect) onSelect(plan);
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

    return (
        <View style={styles.card}>
            {/* Header */}
            <View style={styles.header}>
                <View style={styles.iconContainer}>
                    <Ionicons name={getTypeIcon(plan.planType)} size={20} color={AppColors.primary} />
                </View>
                <Text style={styles.title} numberOfLines={1}>{plan.title}</Text>
                <Text style={styles.scoreText}>%{plan.fitScore} Eşleşme</Text>
            </View>

            {/* Description */}
            <Text style={styles.description} numberOfLines={2}>
                {plan.description}
            </Text>

            {/* Info Stack (Otel & Ulaşım) */}
            <View style={styles.infoStack}>
                <View style={styles.infoItem}>
                    <Ionicons name="bed" size={14} color={AppColors.textSecondary} />
                    <Text style={styles.infoText} numberOfLines={1}>{plan.hotel.name}</Text>
                </View>
                <View style={styles.infoItem}>
                    <Ionicons name="airplane" size={14} color={AppColors.textSecondary} />
                    <Text style={styles.infoText} numberOfLines={1}>{plan.transportation.provider}</Text>
                </View>
            </View>

            {/* Bottom Stack (Fiyat & Seç Butonu) */}
            <View style={styles.bottomStack}>
                <Text style={styles.price}>{formattedPrice}</Text>
                <TouchableOpacity style={styles.selectButton} onPress={handleSelect}>
                    <Text style={styles.selectButtonText}>Bu Planı Seç</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    card: {
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.largeCornerRadius,
        padding: AppLayout.defaultPadding,
        marginHorizontal: AppLayout.defaultPadding,
        marginBottom: 16,
        borderWidth: 1,
        borderColor: AppColors.border,
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
        backgroundColor: 'rgba(255,255,255,0.8)', // Koyu temada açık renk ikon tabanı
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 12,
    },
    title: {
        flex: 1,
        fontSize: 18,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginRight: 8,
    },
    scoreText: {
        fontSize: 14,
        fontWeight: 'bold',
        color: '#34C759', // Başarı/Yeşil renk
    },
    description: {
        fontSize: 14,
        color: AppColors.textSecondary,
        lineHeight: 20,
        marginBottom: 16,
    },
    infoStack: {
        flexDirection: 'row',
        backgroundColor: 'rgba(0,0,0,0.3)',
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
        color: AppColors.textPrimary,
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
        color: AppColors.textPrimary,
    },
    selectButton: {
        backgroundColor: AppColors.secondary,
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
