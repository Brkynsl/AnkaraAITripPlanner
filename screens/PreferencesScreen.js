// PreferencesScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Switch, TouchableOpacity } from 'react-native';
import { useTheme } from '../ThemeContext';
import { AppLayout, scale, verticalScale, moderateScale } from './theme';
import { hapticManager } from '../HapticManager';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Ionicons } from '@expo/vector-icons';

export default function PreferencesScreen({ navigation }) {
    const [isVegetarian, setIsVegetarian] = useState(false);
    const [isHalal, setIsHalal] = useState(false);
    const [accommodationIndex, setAccommodationIndex] = useState(1);
    const [transportIndex, setTransportIndex] = useState(0);
    const { colors } = useTheme();

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
        try { await AsyncStorage.setItem(key, value.toString()); } catch (e) {}
    };

    const setSegment = async (key, index, setter) => {
        hapticManager.selectionChanged();
        setter(index);
        try { await AsyncStorage.setItem(key, index.toString()); } catch (e) {}
    };

    const renderSegmentedControl = (options, selectedIndex, onChange) => (
        <View style={[styles.segmentedControl, { backgroundColor: colors.segmentBackground }]}>
            {options.map((opt, idx) => (
                <TouchableOpacity
                    key={idx}
                    style={[
                        styles.segmentButton,
                        selectedIndex === idx && { backgroundColor: colors.segmentActiveBackground }
                    ]}
                    onPress={() => onChange(idx)}
                    activeOpacity={0.8}
                >
                    <Text style={[
                        styles.segmentText,
                        { color: colors.textSecondary },
                        selectedIndex === idx && { color: colors.textPrimary, fontWeight: 'bold' }
                    ]}>{opt}</Text>
                </TouchableOpacity>
            ))}
        </View>
    );

    return (
        <ScrollView style={[styles.container, { backgroundColor: colors.background }]} contentContainerStyle={styles.content}>
            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
                    <Ionicons name="chevron-back" size={24} color={colors.textPrimary} />
                </TouchableOpacity>
                <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>Tercihlerim</Text>
            </View>

            {/* Yemek Tercihleri */}
            <View style={styles.section}>
                <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>YEMEK TERCİHLERİ</Text>
                <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                    <View style={styles.row}>
                        <Text style={[styles.rowLabel, { color: colors.textPrimary }]}>Vejetaryen / Vegan</Text>
                        <Switch 
                            value={isVegetarian} 
                            onValueChange={(val) => togglePref('pref_vegetarian', val, setIsVegetarian)} 
                            trackColor={{ true: colors.success, false: colors.switchTrackFalse }}
                        />
                    </View>
                    <View style={[styles.separator, { backgroundColor: colors.separatorColor }]} />
                    <View style={styles.row}>
                        <Text style={[styles.rowLabel, { color: colors.textPrimary }]}>Sadece Helal Kesim</Text>
                        <Switch 
                            value={isHalal} 
                            onValueChange={(val) => togglePref('pref_halal', val, setIsHalal)} 
                            trackColor={{ true: colors.success, false: colors.switchTrackFalse }}
                        />
                    </View>
                </View>
            </View>

            {/* Otel & Konaklama */}
            <View style={styles.section}>
                <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>OTEL & KONAKLAMA</Text>
                <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                    <Text style={[styles.rowLabel, { color: colors.textPrimary }]}>Öncelik</Text>
                    {renderSegmentedControl(
                        ["Maliyet", "Dengeli", "Konfor"],
                        accommodationIndex,
                        (idx) => setSegment('pref_accommodation', idx, setAccommodationIndex)
                    )}
                </View>
            </View>

            {/* Ulaşım */}
            <View style={styles.section}>
                <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>ŞEHİR İÇİ ULAŞIM</Text>
                <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                    <Text style={[styles.rowLabel, { color: colors.textPrimary }]}>Öncelik</Text>
                    {renderSegmentedControl(
                        ["Toplu Taşıma", "Taksi / Araç", "Yürüyüş"],
                        transportIndex,
                        (idx) => setSegment('pref_transport', idx, setTransportIndex)
                    )}
                </View>
            </View>

            <Text style={[styles.infoText, { color: colors.textSecondary }]}>
                Tercihleriniz otomatik olarak kaydedilir ve AI Motorumuz bir sonraki planlamanızda bu ayarları dikkate alır.
            </Text>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    content: { paddingTop: AppLayout.headerPaddingTop, paddingHorizontal: AppLayout.defaultPadding, paddingBottom: verticalScale(40) },
    header: { flexDirection: 'row', alignItems: 'center', marginBottom: verticalScale(30) },
    backButton: { paddingRight: scale(16) },
    headerTitle: { fontSize: moderateScale(28), fontWeight: 'bold' },
    section: { marginBottom: verticalScale(32) },
    sectionTitle: { fontSize: moderateScale(13), fontWeight: '600', marginBottom: verticalScale(8), marginLeft: scale(16) },
    card: { borderRadius: AppLayout.cornerRadius, padding: scale(16) },
    row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', minHeight: verticalScale(40) },
    rowLabel: { fontSize: moderateScale(16), fontWeight: '500', marginBottom: verticalScale(12) },
    separator: { height: 1, marginVertical: verticalScale(8) },
    segmentedControl: { flexDirection: 'row', borderRadius: scale(8), padding: scale(4) },
    segmentButton: { flex: 1, paddingVertical: verticalScale(8), alignItems: 'center', borderRadius: scale(6) },
    segmentText: { fontSize: moderateScale(14), fontWeight: '500' },
    infoText: { fontSize: moderateScale(13), textAlign: 'center', paddingHorizontal: scale(20), marginTop: verticalScale(20), lineHeight: moderateScale(20) }
});
