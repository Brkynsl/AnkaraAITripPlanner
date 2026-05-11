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
import { AppColors, AppLayout } from './theme';

export default function RegisterScreen({ navigation }) {
    const { state, errorMsg, signUpWithEmail } = useAuthViewModel();
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');

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
            style={styles.container} 
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        >
            <LinearGradient
                colors={[AppColors.gradientStart, AppColors.gradientEnd]}
                style={StyleSheet.absoluteFillObject}
            />
            
            <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
                
                {/* Header Alanı */}
                <View style={styles.headerContainer}>
                    <Text style={styles.title}>Hesap Oluştur</Text>
                    <Text style={styles.subtitle}>Seyahat planlarınızı oluşturmaya başlayın</Text>
                </View>

                {/* Form Kartı (Blur Effect) */}
                <BlurView intensity={30} tint="dark" style={styles.formCard}>
                    
                    {/* Ad Soyad */}
                    <View style={styles.inputContainer}>
                        <Ionicons name="person" size={20} color={AppColors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={styles.input}
                            placeholder="Ad Soyad"
                            placeholderTextColor={AppColors.textTertiary}
                            autoCapitalize="words"
                            value={name}
                            onChangeText={setName}
                        />
                    </View>

                    {/* E-posta */}
                    <View style={styles.inputContainer}>
                        <Ionicons name="mail" size={20} color={AppColors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={styles.input}
                            placeholder="E-posta adresiniz"
                            placeholderTextColor={AppColors.textTertiary}
                            keyboardType="email-address"
                            autoCapitalize="none"
                            value={email}
                            onChangeText={setEmail}
                        />
                    </View>

                    {/* Şifre */}
                    <View style={styles.inputContainer}>
                        <Ionicons name="lock-closed" size={20} color={AppColors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={styles.input}
                            placeholder="Şifre (en az 6 karakter)"
                            placeholderTextColor={AppColors.textTertiary}
                            secureTextEntry
                            value={password}
                            onChangeText={setPassword}
                        />
                    </View>

                    {/* Şifre Tekrar */}
                    <View style={styles.inputContainer}>
                        <Ionicons name="lock-closed" size={20} color={AppColors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={styles.input}
                            placeholder="Şifre tekrar"
                            placeholderTextColor={AppColors.textTertiary}
                            secureTextEntry
                            value={confirmPassword}
                            onChangeText={setConfirmPassword}
                        />
                    </View>

                    {/* Kayıt Ol Butonu */}
                    <TouchableOpacity 
                        style={styles.registerButton} 
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

                {/* Giriş Yap Linki */}
                <TouchableOpacity 
                    style={styles.loginContainer}
                    onPress={() => {
                        hapticManager.buttonTap();
                        navigation?.goBack();
                    }}
                >
                    <Text style={styles.loginText}>
                        Zaten hesabınız var mı? <Text style={styles.loginHighlight}>Giriş Yap</Text>
                    </Text>
                </TouchableOpacity>

            </ScrollView>
        </KeyboardAvoidingView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: AppColors.background,
    },
    scrollContent: {
        flexGrow: 1,
        justifyContent: 'center',
        paddingHorizontal: AppLayout.largePadding,
    },
    headerContainer: {
        alignItems: 'center',
        marginBottom: 40,
        marginTop: 40,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        textAlign: 'center',
    },
    subtitle: {
        fontSize: 15,
        color: AppColors.textSecondary,
        marginTop: 12,
        textAlign: 'center',
    },
    formCard: {
        borderRadius: AppLayout.largeCornerRadius,
        padding: AppLayout.largePadding,
        overflow: 'hidden',
        backgroundColor: 'rgba(255, 255, 255, 0.05)',
        borderWidth: 1,
        borderColor: AppColors.border,
    },
    inputContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: 'rgba(255, 255, 255, 0.1)',
        borderRadius: AppLayout.cornerRadius,
        height: AppLayout.buttonHeight,
        marginBottom: 14,
        paddingHorizontal: 16,
    },
    inputIcon: {
        marginRight: 12,
    },
    input: {
        flex: 1,
        color: AppColors.textPrimary,
        fontSize: 16,
    },
    registerButton: {
        backgroundColor: AppColors.secondary, // İkincil renk (Turkuaz)
        height: AppLayout.buttonHeight,
        borderRadius: AppLayout.cornerRadius,
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 12,
    },
    registerButtonText: {
        color: '#FFF',
        fontSize: 17,
        fontWeight: 'bold',
    },
    loginContainer: {
        marginTop: 32,
        marginBottom: 40,
        alignItems: 'center',
    },
    loginText: {
        color: AppColors.textSecondary,
        fontSize: 15,
    },
    loginHighlight: {
        color: AppColors.accent, // İkincil vurgu (Turuncu)
        fontWeight: 'bold',
    }
});
