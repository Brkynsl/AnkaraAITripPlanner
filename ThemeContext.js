// ThemeContext.js
// Uygulama genelinde Light/Dark tema yönetimi
import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

// ==========================================
// LIGHT TEMA (DEFAULT)
// ==========================================
const LightTheme = {
    primary: '#1C1C1E',
    secondary: '#00C7BF',
    accent: '#FF9500',
    background: '#F2F2F7',
    success: '#34C759',
    error: '#FF3B30',

    gradientStart: '#D6DCE5',
    gradientEnd: '#F2F2F7',

    cardBackground: '#FFFFFF',
    cardBackgroundRGBA: 'rgba(0, 0, 0, 0.04)',
    textPrimary: '#000000',
    textSecondary: 'rgba(0, 0, 0, 0.55)',
    textTertiary: 'rgba(0, 0, 0, 0.3)',
    border: 'rgba(0, 0, 0, 0.1)',

    inputBackground: 'rgba(0, 0, 0, 0.05)',
    separatorColor: 'rgba(0, 0, 0, 0.08)',
    overlayBackground: 'rgba(0, 0, 0, 0.5)',
    iconBackground: 'rgba(0, 0, 0, 0.06)',
    segmentBackground: 'rgba(0, 0, 0, 0.06)',
    segmentActiveBackground: 'rgba(0, 0, 0, 0.12)',
    switchTrackFalse: '#E5E5EA',
    tabBarInactive: 'rgba(0, 0, 0, 0.3)',
    blurTint: 'light',
    isDark: false,
};

// ==========================================
// DARK TEMA (MEVCUT)
// ==========================================
const DarkTheme = {
    primary: '#1C1C1E',
    secondary: '#00C7BF',
    accent: '#FF9500',
    background: '#000000',
    success: '#34C759',
    error: '#FF3B30',

    gradientStart: '#2C3E50',
    gradientEnd: '#000000',

    cardBackground: 'rgba(255, 255, 255, 0.1)',
    cardBackgroundRGBA: 'rgba(255, 255, 255, 0.08)',
    textPrimary: '#FFFFFF',
    textSecondary: 'rgba(255, 255, 255, 0.7)',
    textTertiary: 'rgba(255, 255, 255, 0.4)',
    border: 'rgba(255, 255, 255, 0.2)',

    inputBackground: 'rgba(255, 255, 255, 0.1)',
    separatorColor: 'rgba(255, 255, 255, 0.08)',
    overlayBackground: 'rgba(0, 0, 0, 0.6)',
    iconBackground: 'rgba(255, 255, 255, 0.05)',
    segmentBackground: 'rgba(0, 0, 0, 0.3)',
    segmentActiveBackground: 'rgba(255, 255, 255, 0.2)',
    switchTrackFalse: '#3e3e3e',
    tabBarInactive: 'rgba(255, 255, 255, 0.4)',
    blurTint: 'dark',
    isDark: true,
};

// ==========================================
// CONTEXT
// ==========================================
const ThemeContext = createContext();

export function ThemeProvider({ children }) {
    const [isDark, setIsDark] = useState(false); // Default: Light

    useEffect(() => {
        loadThemePreference();
    }, []);

    const loadThemePreference = async () => {
        try {
            const saved = await AsyncStorage.getItem('app_theme');
            if (saved === 'dark') {
                setIsDark(true);
            }
        } catch (e) {
            // Sessizce devam et
        }
    };

    const toggleTheme = async () => {
        const newValue = !isDark;
        setIsDark(newValue);
        try {
            await AsyncStorage.setItem('app_theme', newValue ? 'dark' : 'light');
        } catch (e) {
            // Sessizce devam et
        }
    };

    const colors = useMemo(() => isDark ? DarkTheme : LightTheme, [isDark]);

    const value = useMemo(() => ({
        colors,
        isDark,
        toggleTheme,
    }), [colors, isDark]);

    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
}

export function useTheme() {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
}
