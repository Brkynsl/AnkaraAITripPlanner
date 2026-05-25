// TripBuilderScreen.js
import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout } from './theme';
import { hapticManager } from '../HapticManager';

const CITIES = ["Ankara", "İstanbul", "İzmir", "Antalya", "Nevşehir (Kapadokya)", "Muğla (Bodrum)"];

export default function TripBuilderScreen({ navigation }) {
    const [selectedCity, setSelectedCity] = useState(CITIES[0]);
    const [days, setDays] = useState(3);
    const [budget, setBudget] = useState(15000);
    const [showCityDropdown, setShowCityDropdown] = useState(false);
    const { colors } = useTheme();

    const formattedBudget = new Intl.NumberFormat('tr-TR', { 
        style: 'currency', currency: 'TRY', maximumFractionDigits: 0
    }).format(budget);

    const handleCreate = () => {
        hapticManager.success();
        navigation.navigate('GeneratingTrip', { city: selectedCity, days, budget });
    };

    return (
        <ScrollView style={[styles.container, { backgroundColor: colors.background }]} contentContainerStyle={styles.content}>
            <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>Seyahat Planla</Text>

            {/* 1. Şehir Seçimi */}
            <View style={styles.section}>
                <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Nereye gitmek istersin?</Text>
                <TouchableOpacity 
                    style={[styles.pickerButton, { backgroundColor: colors.isDark ? colors.textSecondary : '#E8EDF2' }]} 
                    onPress={() => setShowCityDropdown(!showCityDropdown)}
                    activeOpacity={0.8}
                >
                    <Text style={[styles.pickerButtonText, { color: colors.isDark ? colors.primary : '#1C1C1E' }]}>{selectedCity}</Text>
                    <Ionicons name={showCityDropdown ? "chevron-up" : "chevron-down"} size={20} color={colors.isDark ? colors.primary : '#1C1C1E'} />
                </TouchableOpacity>

                {showCityDropdown && (
                    <View style={[styles.dropdown, { backgroundColor: colors.cardBackgroundRGBA }]}>
                        {CITIES.map((city, idx) => (
                            <TouchableOpacity 
                                key={idx}
                                style={[styles.dropdownItem, { borderBottomColor: colors.separatorColor }]}
                                onPress={() => {
                                    setSelectedCity(city);
                                    setShowCityDropdown(false);
                                    hapticManager.selection();
                                }}
                            >
                                <Text style={[styles.dropdownItemText, { color: colors.textPrimary }]}>{city}</Text>
                            </TouchableOpacity>
                        ))}
                    </View>
                )}
            </View>

            {/* 2. Gün Sayısı */}
            <View style={styles.section}>
                <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Kaç gün kalacaksın?</Text>
                <Text style={[styles.valueText, { color: colors.secondary }]}>{days} Gün</Text>
                
                <View style={styles.stepperContainer}>
                    <TouchableOpacity 
                        style={[styles.stepperButton, { backgroundColor: colors.isDark ? colors.textSecondary : '#E8EDF2' }]}
                        onPress={() => { if(days > 1) { setDays(days - 1); hapticManager.lightImpact(); } }}
                    >
                        <Ionicons name="remove" size={24} color={colors.isDark ? colors.primary : '#1C1C1E'} />
                    </TouchableOpacity>
                    
                    <TouchableOpacity 
                        style={[styles.stepperButton, { backgroundColor: colors.isDark ? colors.textSecondary : '#E8EDF2' }]}
                        onPress={() => { if(days < 14) { setDays(days + 1); hapticManager.lightImpact(); } }}
                    >
                        <Ionicons name="add" size={24} color={colors.isDark ? colors.primary : '#1C1C1E'} />
                    </TouchableOpacity>
                </View>
            </View>

            {/* 3. Bütçe */}
            <View style={styles.section}>
                <Text style={[styles.sectionTitle, { color: colors.textPrimary }]}>Toplam Bütçen Ne Kadar?</Text>
                <Text style={[styles.valueText, { color: '#34C759' }]}>{formattedBudget}</Text>

                <View style={styles.stepperContainer}>
                    <TouchableOpacity 
                        style={[styles.stepperButton, styles.budgetStepper, { backgroundColor: colors.isDark ? colors.textSecondary : '#E8EDF2' }]}
                        onPress={() => { if(budget > 5000) { setBudget(budget - 500); hapticManager.selectionChanged(); } }}
                    >
                        <Ionicons name="remove" size={24} color={colors.isDark ? colors.primary : '#1C1C1E'} />
                    </TouchableOpacity>
                    
                    <TouchableOpacity 
                        style={[styles.stepperButton, styles.budgetStepper, { backgroundColor: colors.isDark ? colors.textSecondary : '#E8EDF2' }]}
                        onPress={() => { if(budget < 100000) { setBudget(budget + 500); hapticManager.selectionChanged(); } }}
                    >
                        <Ionicons name="add" size={24} color={colors.isDark ? colors.primary : '#1C1C1E'} />
                    </TouchableOpacity>
                </View>
            </View>

            {/* Oluştur Butonu */}
            <TouchableOpacity style={[styles.createButton, { backgroundColor: colors.secondary }]} onPress={handleCreate} activeOpacity={0.8}>
                <Ionicons name="color-wand" size={24} color="#FFF" style={{ marginRight: 12 }} />
                <Text style={styles.createButtonText}>AI Planımı Oluştur</Text>
            </TouchableOpacity>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    content: { padding: AppLayout.largePadding, paddingBottom: 60 },
    headerTitle: { fontSize: 32, fontWeight: 'bold', marginBottom: 30 },
    section: { marginBottom: 32 },
    sectionTitle: { fontSize: 18, fontWeight: '600', marginBottom: 12 },
    pickerButton: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', borderRadius: AppLayout.cornerRadius, paddingHorizontal: 16, height: 50 },
    pickerButtonText: { fontSize: 16, fontWeight: '500' },
    dropdown: { borderRadius: AppLayout.cornerRadius, marginTop: 8, overflow: 'hidden' },
    dropdownItem: { padding: 16, borderBottomWidth: 1 },
    dropdownItemText: { fontSize: 16 },
    valueText: { fontSize: 28, fontWeight: 'bold', textAlign: 'center', marginVertical: 16 },
    stepperContainer: { flexDirection: 'row', justifyContent: 'center', gap: 20 },
    stepperButton: { width: 50, height: 50, borderRadius: 25, alignItems: 'center', justifyContent: 'center' },
    budgetStepper: { width: 60 },
    createButton: { flexDirection: 'row', height: 60, borderRadius: AppLayout.largeCornerRadius, alignItems: 'center', justifyContent: 'center', marginTop: 20, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 5 },
    createButtonText: { color: '#FFF', fontSize: 18, fontWeight: 'bold' }
});
