// TripBuilderScreen.js
import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import { hapticManager } from '../HapticManager';

const CITIES = ["Ankara", "İstanbul", "İzmir", "Antalya", "Nevşehir (Kapadokya)", "Muğla (Bodrum)"];

export default function TripBuilderScreen({ navigation }) {
    const [selectedCity, setSelectedCity] = useState(CITIES[0]);
    const [days, setDays] = useState(3);
    const [budget, setBudget] = useState(15000);
    const [showCityDropdown, setShowCityDropdown] = useState(false);

    // Bütçe formatlama
    const formattedBudget = new Intl.NumberFormat('tr-TR', { 
        style: 'currency', 
        currency: 'TRY',
        maximumFractionDigits: 0
    }).format(budget);

    const handleCreate = () => {
        hapticManager.success();
        // GeneratingTripScreen'e parametrelerle geç
        navigation.navigate('GeneratingTrip', {
            city: selectedCity,
            days: days,
            budget: budget
        });
    };

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            <Text style={styles.headerTitle}>Seyahat Planla</Text>

            {/* 1. Şehir Seçimi */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Nereye gitmek istersin?</Text>
                <TouchableOpacity 
                    style={styles.pickerButton} 
                    onPress={() => setShowCityDropdown(!showCityDropdown)}
                    activeOpacity={0.8}
                >
                    <Text style={styles.pickerButtonText}>{selectedCity}</Text>
                    <Ionicons name={showCityDropdown ? "chevron-up" : "chevron-down"} size={20} color={AppColors.primary} />
                </TouchableOpacity>

                {showCityDropdown && (
                    <View style={styles.dropdown}>
                        {CITIES.map((city, idx) => (
                            <TouchableOpacity 
                                key={idx}
                                style={styles.dropdownItem}
                                onPress={() => {
                                    setSelectedCity(city);
                                    setShowCityDropdown(false);
                                    hapticManager.selection();
                                }}
                            >
                                <Text style={styles.dropdownItemText}>{city}</Text>
                            </TouchableOpacity>
                        ))}
                    </View>
                )}
            </View>

            {/* 2. Gün Sayısı */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Kaç gün kalacaksın?</Text>
                <Text style={styles.valueText}>{days} Gün</Text>
                
                <View style={styles.stepperContainer}>
                    <TouchableOpacity 
                        style={styles.stepperButton}
                        onPress={() => {
                            if(days > 1) {
                                setDays(days - 1);
                                hapticManager.lightImpact();
                            }
                        }}
                    >
                        <Ionicons name="remove" size={24} color={AppColors.primary} />
                    </TouchableOpacity>
                    
                    <TouchableOpacity 
                        style={styles.stepperButton}
                        onPress={() => {
                            if(days < 14) {
                                setDays(days + 1);
                                hapticManager.lightImpact();
                            }
                        }}
                    >
                        <Ionicons name="add" size={24} color={AppColors.primary} />
                    </TouchableOpacity>
                </View>
            </View>

            {/* 3. Bütçe (Basit Plus/Minus ile) */}
            <View style={styles.section}>
                <Text style={styles.sectionTitle}>Toplam Bütçen Ne Kadar?</Text>
                <Text style={[styles.valueText, { color: '#34C759' }]}>{formattedBudget}</Text>

                <View style={styles.stepperContainer}>
                    <TouchableOpacity 
                        style={[styles.stepperButton, { width: 60 }]}
                        onPress={() => {
                            if(budget > 5000) {
                                setBudget(budget - 500);
                                hapticManager.selectionChanged();
                            }
                        }}
                    >
                        <Ionicons name="remove" size={24} color={AppColors.primary} />
                    </TouchableOpacity>
                    
                    <TouchableOpacity 
                        style={[styles.stepperButton, { width: 60 }]}
                        onPress={() => {
                            if(budget < 100000) {
                                setBudget(budget + 500);
                                hapticManager.selectionChanged();
                            }
                        }}
                    >
                        <Ionicons name="add" size={24} color={AppColors.primary} />
                    </TouchableOpacity>
                </View>
            </View>

            {/* Oluştur Butonu */}
            <TouchableOpacity style={styles.createButton} onPress={handleCreate} activeOpacity={0.8}>
                <Ionicons name="color-wand" size={24} color="#FFF" style={{ marginRight: 12 }} />
                <Text style={styles.createButtonText}>AI Planımı Oluştur</Text>
            </TouchableOpacity>

        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
    },
    content: {
        padding: AppLayout.largePadding,
        paddingBottom: 60,
    },
    headerTitle: {
        fontSize: 32,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 30,
    },
    section: {
        marginBottom: 32,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: '600',
        color: AppColors.textPrimary,
        marginBottom: 12,
    },
    pickerButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        backgroundColor: AppColors.textSecondary, // Açık gri/beyazımsı
        borderRadius: AppLayout.cornerRadius,
        paddingHorizontal: 16,
        height: 50,
    },
    pickerButtonText: {
        fontSize: 16,
        color: AppColors.primary,
        fontWeight: '500',
    },
    dropdown: {
        backgroundColor: 'rgba(255,255,255,0.1)',
        borderRadius: AppLayout.cornerRadius,
        marginTop: 8,
        overflow: 'hidden',
    },
    dropdownItem: {
        padding: 16,
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(255,255,255,0.05)',
    },
    dropdownItemText: {
        color: AppColors.textPrimary,
        fontSize: 16,
    },
    valueText: {
        fontSize: 28,
        fontWeight: 'bold',
        color: AppColors.secondary,
        textAlign: 'center',
        marginVertical: 16,
    },
    stepperContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 20,
    },
    stepperButton: {
        width: 50,
        height: 50,
        borderRadius: 25,
        backgroundColor: AppColors.textSecondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
    createButton: {
        flexDirection: 'row',
        backgroundColor: AppColors.secondary,
        height: 60,
        borderRadius: AppLayout.largeCornerRadius,
        alignItems: 'center',
        justifyContent: 'center',
        marginTop: 20,
        shadowColor: AppColors.secondary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
        elevation: 5,
    },
    createButtonText: {
        color: '#FFF',
        fontSize: 18,
        fontWeight: 'bold',
    }
});
