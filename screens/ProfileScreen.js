// ProfileScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppColors, AppLayout } from './theme';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function ProfileScreen({ navigation }) {
    const [user, setUser] = useState(null);

    useEffect(() => {
        setUser(firebaseAuthService.currentFirebaseUser);
    }, []);

    const handleLogout = () => {
        hapticManager.buttonTap();
        Alert.alert(
            "Çıkış Yap",
            "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
            [
                { text: "İptal", style: "cancel" },
                { 
                    text: "Çıkış Yap", 
                    style: "destructive",
                    onPress: async () => {
                        try {
                            await firebaseAuthService.signOut();
                            await AsyncStorage.setItem('hasCompletedOnboarding', 'false');
                            // Navigate to Auth stack (Login)
                            // navigation.replace('Login'); 
                            console.log("Logged out successfully");
                        } catch (error) {
                            Alert.alert("Hata", error.message);
                        }
                    } 
                }
            ]
        );
    };

    const handleMenuTap = (title) => {
        hapticManager.lightImpact();
        if (title.includes("Tercihler") || title.includes("Bütçe") || title.includes("İlgi")) {
            navigation.navigate('Preferences');
        } else {
            Alert.alert("Bilgi", `${title} özelliği yakında eklenecek.`);
        }
    };

    const renderMenuRow = (icon, title, color, action, isSwitch = false) => (
        <TouchableOpacity 
            style={styles.menuRow} 
            onPress={isSwitch ? null : action}
            activeOpacity={isSwitch ? 1 : 0.7}
        >
            <View style={[styles.iconBg, { backgroundColor: color + '20' }]}>
                <Ionicons name={icon} size={16} color={color} />
            </View>
            <Text style={styles.menuTitle}>{title}</Text>
            {isSwitch ? (
                <Switch 
                    trackColor={{ true: AppColors.secondary, false: '#3e3e3e' }}
                />
            ) : (
                <Ionicons name="chevron-forward" size={16} color="rgba(255,255,255,0.4)" />
            )}
        </TouchableOpacity>
    );

    const renderMenuSection = (title, items) => (
        <View style={styles.sectionContainer}>
            <Text style={styles.sectionTitle}>{title}</Text>
            <View style={styles.card}>
                {items.map((item, idx) => (
                    <React.Fragment key={idx}>
                        {renderMenuRow(item.icon, item.title, item.color, () => handleMenuTap(item.title), item.isSwitch)}
                        {idx < items.length - 1 && <View style={styles.separator} />}
                    </React.Fragment>
                ))}
            </View>
        </View>
    );

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.content}>
            <Text style={styles.headerTitle}>Profilim</Text>

            {/* Profil Kartı */}
            <View style={styles.profileCard}>
                <View style={styles.avatarContainer}>
                    <Ionicons name="person" size={40} color={AppColors.secondary} />
                </View>
                <View style={styles.userInfo}>
                    <Text style={styles.userName}>{user?.displayName || "Kullanıcı"}</Text>
                    <Text style={styles.userEmail}>{user?.email || ""}</Text>
                </View>
            </View>

            {/* Tercihler */}
            {renderMenuSection("Tercihler", [
                { icon: "airplane", title: "Ulaşım Tercihleri", color: AppColors.secondary },
                { icon: "restaurant", title: "Yemek Tercihleri", color: AppColors.accent },
                { icon: "star", title: "İlgi Alanları", color: "#AF52DE" },
                { icon: "wallet", title: "Bütçe Davranışı", color: AppColors.success }
            ])}

            {/* Ayarlar */}
            {renderMenuSection("Ayarlar", [
                { icon: "globe", title: "Dil", color: AppColors.textSecondary },
                { icon: "notifications", title: "Bildirimler", color: "#FF9500" },
                { icon: "shield-checkmark", title: "Gizlilik", color: "#34C759" }
            ])}

            {/* Hakkında */}
            {renderMenuSection("Hakkında", [
                { icon: "information-circle", title: "Uygulama Hakkında", color: AppColors.secondary },
                { icon: "mail", title: "Destek", color: AppColors.accent },
                { icon: "star", title: "Değerlendir", color: "#FF2D55" }
            ])}

            {/* Çıkış Yap */}
            <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
                <Ionicons name="log-out-outline" size={20} color={AppColors.error} style={{ marginRight: 8 }} />
                <Text style={styles.logoutText}>Çıkış Yap</Text>
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
        paddingTop: 60,
        paddingHorizontal: AppLayout.defaultPadding,
        paddingBottom: 40,
    },
    headerTitle: {
        fontSize: 34,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 20,
    },
    profileCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.largeCornerRadius,
        padding: 20,
        marginBottom: 24,
        borderWidth: 1,
        borderColor: AppColors.border,
    },
    avatarContainer: {
        width: 70,
        height: 70,
        borderRadius: 35,
        backgroundColor: 'rgba(0, 180, 216, 0.1)',
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 16,
    },
    userInfo: {
        flex: 1,
    },
    userName: {
        fontSize: 20,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginBottom: 4,
    },
    userEmail: {
        fontSize: 14,
        color: AppColors.textSecondary,
    },
    sectionContainer: {
        marginBottom: 24,
    },
    sectionTitle: {
        fontSize: 13,
        fontWeight: '600',
        color: AppColors.textSecondary,
        marginBottom: 8,
        marginLeft: 16,
        textTransform: 'uppercase',
    },
    card: {
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: AppLayout.cornerRadius,
        overflow: 'hidden',
    },
    menuRow: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 12,
        paddingHorizontal: 16,
        minHeight: 50,
    },
    iconBg: {
        width: 30,
        height: 30,
        borderRadius: 8,
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 12,
    },
    menuTitle: {
        flex: 1,
        fontSize: 16,
        color: AppColors.textPrimary,
    },
    separator: {
        height: 1,
        backgroundColor: 'rgba(255,255,255,0.05)',
        marginLeft: 58, // Icon width + margins
    },
    logoutButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: 'rgba(255, 59, 48, 0.1)',
        borderRadius: AppLayout.cornerRadius,
        height: AppLayout.buttonHeight,
        marginTop: 10,
    },
    logoutText: {
        color: AppColors.error,
        fontSize: 16,
        fontWeight: 'bold',
    }
});
