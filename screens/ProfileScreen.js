// ProfileScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { AppLayout } from './theme';
import { firebaseAuthService } from '../FirebaseAuthService';
import { hapticManager } from '../HapticManager';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function ProfileScreen({ navigation }) {
    const [user, setUser] = useState(null);
    const { colors, isDark, toggleTheme } = useTheme();

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

    const handleThemeToggle = () => {
        hapticManager.lightImpact();
        toggleTheme();
    };

    const renderMenuRow = (icon, title, color, action, isSwitch = false, switchValue = false, onSwitchChange = null) => (
        <TouchableOpacity 
            style={styles.menuRow} 
            onPress={isSwitch ? null : action}
            activeOpacity={isSwitch ? 1 : 0.7}
        >
            <View style={[styles.iconBg, { backgroundColor: color + '20' }]}>
                <Ionicons name={icon} size={16} color={color} />
            </View>
            <Text style={[styles.menuTitle, { color: colors.textPrimary }]}>{title}</Text>
            {isSwitch ? (
                <Switch 
                    value={switchValue}
                    onValueChange={onSwitchChange}
                    trackColor={{ true: colors.secondary, false: colors.switchTrackFalse }}
                />
            ) : (
                <Ionicons name="chevron-forward" size={16} color={colors.textTertiary} />
            )}
        </TouchableOpacity>
    );

    const renderMenuSection = (title, items) => (
        <View style={styles.sectionContainer}>
            <Text style={[styles.sectionTitle, { color: colors.textSecondary }]}>{title}</Text>
            <View style={[styles.card, { backgroundColor: colors.cardBackgroundRGBA }]}>
                {items.map((item, idx) => (
                    <React.Fragment key={idx}>
                        {renderMenuRow(item.icon, item.title, item.color, () => handleMenuTap(item.title), item.isSwitch, item.switchValue, item.onSwitchChange)}
                        {idx < items.length - 1 && <View style={[styles.separator, { backgroundColor: colors.separatorColor }]} />}
                    </React.Fragment>
                ))}
            </View>
        </View>
    );

    return (
        <ScrollView style={[styles.container, { backgroundColor: colors.background }]} contentContainerStyle={styles.content}>
            <Text style={[styles.headerTitle, { color: colors.textPrimary }]}>Profilim</Text>

            {/* Profil Kartı */}
            <View style={[styles.profileCard, { backgroundColor: colors.cardBackgroundRGBA, borderColor: colors.border }]}>
                <View style={[styles.avatarContainer, { backgroundColor: 'rgba(0, 180, 216, 0.1)' }]}>
                    <Ionicons name="person" size={40} color={colors.secondary} />
                </View>
                <View style={styles.userInfo}>
                    <Text style={[styles.userName, { color: colors.textPrimary }]}>{user?.displayName || "Kullanıcı"}</Text>
                    <Text style={[styles.userEmail, { color: colors.textSecondary }]}>{user?.email || ""}</Text>
                </View>
            </View>

            {/* Tercihler */}
            {renderMenuSection("Tercihler", [
                { icon: "airplane", title: "Ulaşım Tercihleri", color: colors.secondary },
                { icon: "restaurant", title: "Yemek Tercihleri", color: colors.accent },
                { icon: "star", title: "İlgi Alanları", color: "#AF52DE" },
                { icon: "wallet", title: "Bütçe Davranışı", color: colors.success }
            ])}

            {/* Ayarlar */}
            {renderMenuSection("Ayarlar", [
                { icon: "moon", title: "Koyu Tema", color: "#5856D6", isSwitch: true, switchValue: isDark, onSwitchChange: handleThemeToggle },
                { icon: "globe", title: "Dil", color: colors.textSecondary },
                { icon: "notifications", title: "Bildirimler", color: "#FF9500" },
                { icon: "shield-checkmark", title: "Gizlilik", color: "#34C759" }
            ])}

            {/* Hakkında */}
            {renderMenuSection("Hakkında", [
                { icon: "information-circle", title: "Uygulama Hakkında", color: colors.secondary },
                { icon: "mail", title: "Destek", color: colors.accent },
                { icon: "star", title: "Değerlendir", color: "#FF2D55" }
            ])}

            {/* Çıkış Yap */}
            <TouchableOpacity style={[styles.logoutButton, { backgroundColor: 'rgba(255, 59, 48, 0.1)' }]} onPress={handleLogout}>
                <Ionicons name="log-out-outline" size={20} color={colors.error} style={{ marginRight: 8 }} />
                <Text style={[styles.logoutText, { color: colors.error }]}>Çıkış Yap</Text>
            </TouchableOpacity>

        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    content: { paddingTop: 60, paddingHorizontal: AppLayout.defaultPadding, paddingBottom: 40 },
    headerTitle: { fontSize: 34, fontWeight: 'bold', marginBottom: 20 },
    profileCard: { flexDirection: 'row', alignItems: 'center', borderRadius: AppLayout.largeCornerRadius, padding: 20, marginBottom: 24, borderWidth: 1 },
    avatarContainer: { width: 70, height: 70, borderRadius: 35, alignItems: 'center', justifyContent: 'center', marginRight: 16 },
    userInfo: { flex: 1 },
    userName: { fontSize: 20, fontWeight: 'bold', marginBottom: 4 },
    userEmail: { fontSize: 14 },
    sectionContainer: { marginBottom: 24 },
    sectionTitle: { fontSize: 13, fontWeight: '600', marginBottom: 8, marginLeft: 16, textTransform: 'uppercase' },
    card: { borderRadius: AppLayout.cornerRadius, overflow: 'hidden' },
    menuRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, paddingHorizontal: 16, minHeight: 50 },
    iconBg: { width: 30, height: 30, borderRadius: 8, alignItems: 'center', justifyContent: 'center', marginRight: 12 },
    menuTitle: { flex: 1, fontSize: 16 },
    separator: { height: 1, marginLeft: 58 },
    logoutButton: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderRadius: AppLayout.cornerRadius, height: AppLayout.buttonHeight, marginTop: 10 },
    logoutText: { fontSize: 16, fontWeight: 'bold' }
});
