// PreferencesScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch, TouchableOpacity } from 'react-native';
import { AppColors, AppLayout } from './theme';
import { hapticManager } from '../HapticManager';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Ionicons } from '@expo/vector-icons';

export default function PreferencesScreen({ navigation }) {
    const [isVegetarian, setIsVegetarian] = useState(false);
    const [isHalal, setIsHalal] = useState(false);
    const [accommodationIndex, setAccommodationIndex] = useState(1); // 0: Maliyet, 1: Dengeli, 2: Konfor
    const [transportIndex, setTransportIndex] = useState(0); // 0: Toplu Taşıma, 1: Taksi, 2: Yürüyüş

    useEffect(() => {
        loadPreferences();
    }, []);

    const loadPreferences = async () => {
        try {
            const veg = await AsyncStorage.getItem('pref_vegetarian');
            const hal = await AsyncStorage.getItem('pref_halal');
            const acc = await AsyncStorage.getItem('pref_accommodation');
            const trans = await AsyncStorage.getItem('pref_transport');

            if(veg !== null) setIsVegetarian(veg === 'true');
            if(hal !== null) setIsHalal(hal === 'true');
            if(acc !== null) setAccommodationIndex(parseInt(acc));
            if(trans !== null) setTransportIndex(parseInt(trans));
        } catch (e) {
            console.error("Tercihler yüklenemedi", e);
        }
    };

    const togglePref = async (key, value, setter) => {
        hapticManager.lightImpact();
        setter(value);
        try {
            await AsyncStorage.setItem(key, value.toString());
        } catch (e) {}
    };

    const setSegment = async (key, index, setter) => {
        hapticManager.selectionChanged();
        setter(index);
        try {
            await AsyncStorage.setItem(key, index.toString());
        } catch (e) {}
    };

    const renderSegmentedControl = (options, selectedIndex, onChange) => (
        <View style={styles.segmentedControl}>
            {options.map((opt, idx) => (
                <TouchableOpacity
                    key={idx}
                    style={[
                        styles.segmentButton,
                        selectedIndex === idx && styles.segmentButtonActive
                    ]}
                    onPress={() => onChange(idx)}
                    activeOpacity={0.8}
                >
                    <Text style={[
                        styles.segmentText,
                        selectedIndex === idx && styles.segmentTextActive
                    ]}>{opt}</Text>
                </TouchableOpacity>
            ))}
        </View>
    );

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                    <Ionicons name="chevron-back" size={24} color={AppColors.textPrimary} />
                </TouchableOpacity>
                <Text style={styles.headerTitle}>Tercihlerim</Text>
            </View>

            {/* Yemek Tercihleri */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>YEMEK TERCİHLERİ</Text>
                <View style={styles.card}>
                    <View style={styles.row}>
                        <Text style={styles.rowLabel}>Vejetaryen / Vegan</Text>
                        <Switch 
                            value={isVegetarian} 
                            onValueChange={(val) => togglePref('pref_vegetarian', val, setIsVegetarian)} 
                            trackColor={{ true: AppColors.success, false: 'rgba(255,255,255,0.2)' }}
                        />
                    </View>
                    <View style={styles.separator} />
                    <View style={styles.row}>
                        <Text style={styles.rowLabel}>Sadece Helal Kesim</Text>
                        <Switch 
                            value={isHalal} 
                            onValueChange={(val) => togglePref('pref_halal', val, setIsHalal)} 
                            trackColor={{ true: AppColors.success, false: 'rgba(255,255,255,0.2)' }}
                        />
                    </View>
                </View>
            </View>

            {/* Otel & Konaklama */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>OTEL & KONAKLAMA</Text>
                <View style={styles.card}>
                    <Text style={styles.rowLabel}>Öncelik</Text>
                    {renderSegmentedControl(
                        ["Maliyet", "Dengeli", "Konfor"],
                        accommodationIndex,
                        (idx) => setSegment('pref_accommodation', idx, setAccommodationIndex)
                    )}
                </View>
            </View>

            {/* Ulaşım */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>ŞEHİR İÇİ ULAŞIM</Text>
                <View style={styles.card}>
                    <Text style={styles.rowLabel}>Öncelik</Text>
                    {renderSegmentedControl(
                        ["Toplu Taşıma", "Taksi / Araç", "Yürüyüş"],
                        transportIndex,
                        (idx) => setSegment('pref_transport', idx, setTransportIndex)
                    )}
                </View>
            </View>

            <Text style={styles.infoText}>
                Tercihleriniz otomatik olarak kaydedilir ve AI Motorumuz bir sonraki planlamanızda bu ayarları dikkate alır.
            </Text>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
    },
    content: {
        paddingTop: 60,
        paddingHorizontal: AppLayout.defaultPadding,
        paddingBottom: 40,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 30,
    },
    backButton: {
        paddingRight: 16,
    },
    headerTitle: {
        fontSize: 28,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
    },
    section: {
        marginBottom: 32,
    },
    sectionTitle: {
        fontSize: 13,
        fontWeight: '600',
        color: AppColors.textSecondary,
        marginBottom: 8,
        marginLeft: 16,
    },
    card: {
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.cornerRadius,
        padding: 16,
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        minHeight: 40,
    },
    rowLabel: {
        fontSize: 16,
        color: AppColors.textPrimary,
        fontWeight: '500',
        marginBottom: 12,
    },
    separator: {
        height: 1,
        backgroundColor: 'rgba(255,255,255,0.1)',
        marginVertical: 8,
    },
    segmentedControl: {
        flexDirection: 'row',
        backgroundColor: 'rgba(0,0,0,0.3)',
        borderRadius: 8,
        padding: 4,
    },
    segmentButton: {
        flex: 1,
        paddingVertical: 8,
        alignItems: 'center',
        borderRadius: 6,
    },
    segmentButtonActive: {
        backgroundColor: 'rgba(255,255,255,0.2)',
    },
    segmentText: {
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: '500',
    },
    segmentTextActive: {
        color: AppColors.textPrimary,
        fontWeight: 'bold',
    },
    infoText: {
        fontSize: 13,
        color: AppColors.textSecondary,
        textAlign: 'center',
        paddingHorizontal: 20,
        marginTop: 20,
        lineHeight: 20,
    }
});
