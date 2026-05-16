// LoginScreen.js
import React, { useState } from 'react';
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

export default function LoginScreen({ navigation }) {
    const { state, errorMsg, signInWithEmail } = useAuthViewModel();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const isLoading = state === AuthState.LOADING;

    // React useEffect hook ile state error'u izlenip alert gösterilebilir
    React.useEffect(() => {
        if (state === AuthState.ERROR && errorMsg) {
            hapticManager.error();
            Alert.alert("Hata", errorMsg);
        } else if (state === AuthState.SUCCESS) {
            hapticManager.success();
            navigation.replace('MainTab');
            console.log("Giriş Başarılı!");
        }
    }, [state]);

    const handleLogin = () => {
        hapticManager.buttonTap();
        signInWithEmail(email, password);
    };

    const handleGoogleLogin = () => {
        hapticManager.buttonTap();
        Alert.alert("Bilgi", "Google Sign-In entegrasyonu expo-auth-session gibi kütüphaneler gerektirir.");
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
                    <Ionicons name="airplane" size={64} color={AppColors.secondary} />
                    <Text style={styles.title}>Ankara AI Trip Planner</Text>
                    <Text style={styles.subtitle}>Akıllı Seyahat Asistanınız</Text>
                </View>

                {/* Form Kartı (Blur Effect) */}
                <BlurView intensity={30} tint="dark" style={styles.formCard}>
                    
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
                            placeholder="Şifreniz"
                            placeholderTextColor={AppColors.textTertiary}
                            secureTextEntry
                            value={password}
                            onChangeText={setPassword}
                        />
                    </View>

                    {/* Login Butonu */}
                    <TouchableOpacity 
                        style={styles.loginButton} 
                        onPress={handleLogin}
                        disabled={isLoading}
                        activeOpacity={0.8}
                    >
                        {isLoading ? (
                            <ActivityIndicator color="#FFF" />
                        ) : (
                            <Text style={styles.loginButtonText}>Giriş Yap</Text>
                        )}
                    </TouchableOpacity>

                    <TouchableOpacity 
                        style={styles.forgotPasswordButton}
                        onPress={() => hapticManager.buttonTap()}
                    >
                        <Text style={styles.forgotPasswordText}>Şifremi Unuttum</Text>
                    </TouchableOpacity>
                </BlurView>

                {/* Sosyal Giriş */}
                <View style={styles.socialContainer}>
                    <View style={styles.divider}>
                        <View style={styles.line} />
                        <Text style={styles.dividerText}>veya</Text>
                        <View style={styles.line} />
                    </View>

                    <View style={styles.socialButtonsRow}>
                        <TouchableOpacity style={[styles.socialButton, { backgroundColor: '#FFFFFF' }]} onPress={handleGoogleLogin}>
                            <Ionicons name="logo-google" size={20} color="#4285F4" />
                            <Text style={[styles.socialButtonText, { color: '#4285F4' }]}>Google</Text>
                        </TouchableOpacity>

                        {Platform.OS === 'ios' && (
                            <TouchableOpacity style={[styles.socialButton, { backgroundColor: '#000000' }]} onPress={() => Alert.alert("Bilgi", "Apple yetkilendirmesi ayarlanacak.")}>
                                <Ionicons name="logo-apple" size={20} color="#FFFFFF" />
                                <Text style={[styles.socialButtonText, { color: '#FFFFFF' }]}>Apple</Text>
                            </TouchableOpacity>
                        )}
                    </View>
                </View>

                {/* Kayıt Ol Linki */}
                <TouchableOpacity 
                    style={styles.registerContainer}
                    onPress={() => navigation.navigate('Register')}
                >
                    <Text style={styles.registerText}>
                        Hesabınız yok mu? <Text style={styles.registerHighlight}>Kayıt Ol</Text>
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
        marginTop: 60,
    },
    title: {
        fontSize: 32,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        marginTop: 16,
    },
    subtitle: {
        fontSize: 16,
        color: AppColors.textSecondary,
        marginTop: 8,
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
        marginBottom: 16,
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
    loginButton: {
        backgroundColor: AppColors.accent,
        height: AppLayout.buttonHeight,
        borderRadius: AppLayout.cornerRadius,
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 8,
    },
    loginButtonText: {
        color: '#FFF',
        fontSize: 17,
        fontWeight: 'bold',
    },
    forgotPasswordButton: {
        alignItems: 'center',
        marginTop: 16,
    },
    forgotPasswordText: {
        color: AppColors.textSecondary,
        fontSize: 14,
    },
    socialContainer: {
        marginTop: 32,
    },
    divider: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 24,
    },
    line: {
        flex: 1,
        height: 1,
        backgroundColor: AppColors.border,
    },
    dividerText: {
        color: AppColors.textSecondary,
        paddingHorizontal: 12,
        fontSize: 14,
    },
    socialButtonsRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        gap: 12,
    },
    socialButton: {
        flex: 1,
        height: AppLayout.buttonHeight,
        borderRadius: AppLayout.cornerRadius,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
        elevation: 2,
    },
    socialButtonText: {
        fontSize: 16,
        fontWeight: 'bold',
        marginLeft: 10,
    },
    registerContainer: {
        marginTop: 40,
        marginBottom: 40,
        alignItems: 'center',
    },
    registerText: {
        color: AppColors.textSecondary,
        fontSize: 15,
    },
    registerHighlight: {
        color: AppColors.secondary,
        fontWeight: 'bold',
    }
});
