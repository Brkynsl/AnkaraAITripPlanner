// RegisterScreen.js
import React, { useState, useEffect } from 'react';
import { 
    View, Text, TextInput, TouchableOpacity, StyleSheet, 
    KeyboardAvoidingView, Platform, ScrollView, Alert, ActivityIndicator 
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { BlurView } from 'expo-blur';
import { Ionicons } from '@expo/vector-icons';
import { useAuthViewModel, AuthState } from '../useAuthViewModel';
import { hapticManager } from '../HapticManager';
import { useTheme } from '../ThemeContext';
import { AppLayout } from './theme';

export default function RegisterScreen({ navigation }) {
    const { state, errorMsg, signUpWithEmail } = useAuthViewModel();
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const { colors } = useTheme();

    const isLoading = state === AuthState.LOADING;

    useEffect(() => {
        if (state === AuthState.ERROR && errorMsg) {
            hapticManager.error();
            Alert.alert("Hata", errorMsg);
        } else if (state === AuthState.SUCCESS) {
            hapticManager.success();
            console.log("Kayıt Başarılı!");
            navigation.replace('MainTab');
        }
    }, [state]);

    const handleRegister = () => {
        hapticManager.buttonTap();
        signUpWithEmail(name, email, password, confirmPassword);
    };

    return (
        <KeyboardAvoidingView 
            style={[styles.container, { backgroundColor: colors.background }]} 
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
            <LinearGradient
                colors={[colors.gradientStart, colors.gradientEnd]}
                style={StyleSheet.absoluteFillObject}
            />
            
            <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
                
                {/* Header Alanı */}
                <View style={styles.headerContainer}>
                    <Text style={[styles.title, { color: colors.textPrimary }]}>Hesap Oluştur</Text>
                    <Text style={[styles.subtitle, { color: colors.textSecondary }]}>Seyahat planlarınızı oluşturmaya başlayın</Text>
                </View>

                {/* Form Kartı */}
                <BlurView intensity={30} tint={colors.blurTint} style={[styles.formCard, { borderColor: colors.border, backgroundColor: colors.cardBackgroundRGBA }]}>
                    
                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="person" size={20} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="Ad Soyad"
                            placeholderTextColor={colors.textTertiary}
                            autoCapitalize="words"
                            value={name}
                            onChangeText={setName}
                        />
                    </View>

                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="mail" size={20} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="E-posta adresiniz"
                            placeholderTextColor={colors.textTertiary}
                            keyboardType="email-address"
                            autoCapitalize="none"
                            value={email}
                            onChangeText={setEmail}
                        />
                    </View>

                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="lock-closed" size={20} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="Şifre (en az 6 karakter)"
                            placeholderTextColor={colors.textTertiary}
                            secureTextEntry
                            value={password}
                            onChangeText={setPassword}
                        />
                    </View>

                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="lock-closed" size={20} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="Şifre tekrar"
                            placeholderTextColor={colors.textTertiary}
                            secureTextEntry
                            value={confirmPassword}
                            onChangeText={setConfirmPassword}
                        />
                    </View>

                    <TouchableOpacity 
                        style={[styles.registerButton, { backgroundColor: colors.secondary }]} 
                        onPress={handleRegister}
                        disabled={isLoading}
                        activeOpacity={0.8}
                    >
                        {isLoading ? (
                            <ActivityIndicator color="#FFF" />
                        ) : (
                            <Text style={styles.registerButtonText}>Kayıt Ol</Text>
                        )}
                    </TouchableOpacity>
                </BlurView>

                <TouchableOpacity 
                    style={styles.loginContainer}
                    onPress={() => {
                        hapticManager.buttonTap();
                        navigation?.goBack();
                    }}
                >
                    <Text style={[styles.loginText, { color: colors.textSecondary }]}>
                        Zaten hesabınız var mı? <Text style={[styles.loginHighlight, { color: colors.accent }]}>Giriş Yap</Text>
                    </Text>
                </TouchableOpacity>

            </ScrollView>
        </KeyboardAvoidingView>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1 },
    scrollContent: { flexGrow: 1, justifyContent: 'center', paddingHorizontal: AppLayout.largePadding },
    headerContainer: { alignItems: 'center', marginBottom: 40, marginTop: 40 },
    title: { fontSize: 28, fontWeight: 'bold', textAlign: 'center' },
    subtitle: { fontSize: 15, marginTop: 12, textAlign: 'center' },
    formCard: { borderRadius: AppLayout.largeCornerRadius, padding: AppLayout.largePadding, overflow: 'hidden', borderWidth: 1 },
    inputContainer: { flexDirection: 'row', alignItems: 'center', borderRadius: AppLayout.cornerRadius, height: AppLayout.buttonHeight, marginBottom: 14, paddingHorizontal: 16 },
    inputIcon: { marginRight: 12 },
    input: { flex: 1, fontSize: 16 },
    registerButton: { height: AppLayout.buttonHeight, borderRadius: AppLayout.cornerRadius, justifyContent: 'center', alignItems: 'center', marginTop: 12 },
    registerButtonText: { color: '#FFF', fontSize: 17, fontWeight: 'bold' },
    loginContainer: { marginTop: 32, marginBottom: 40, alignItems: 'center' },
    loginText: { fontSize: 15 },
    loginHighlight: { fontWeight: 'bold' }
});
