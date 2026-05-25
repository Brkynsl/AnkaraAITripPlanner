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
import { useTheme } from '../ThemeContext';
import { AppLayout } from './theme';

export default function LoginScreen({ navigation }) {
    const { state, errorMsg, signInWithEmail } = useAuthViewModel();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const { colors } = useTheme();

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
                    <Ionicons name="airplane" size={64} color={colors.secondary} />
                    <Text style={[styles.title, { color: colors.textPrimary }]}>Ankara AI Trip Planner</Text>
                    <Text style={[styles.subtitle, { color: colors.textSecondary }]}>Akıllı Seyahat Asistanınız</Text>
                </View>

                {/* Form Kartı (Blur Effect) */}
                <BlurView intensity={30} tint={colors.blurTint} style={[styles.formCard, { borderColor: colors.border, backgroundColor: colors.cardBackgroundRGBA }]}>
                    
                    {/* E-posta */}
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

                    {/* Şifre */}
                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="lock-closed" size={20} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="Şifreniz"
                            placeholderTextColor={colors.textTertiary}
                            secureTextEntry
                            value={password}
                            onChangeText={setPassword}
                        />
                    </View>

                    {/* Login Butonu */}
                    <TouchableOpacity 
                        style={[styles.loginButton, { backgroundColor: colors.accent }]} 
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
                        <Text style={[styles.forgotPasswordText, { color: colors.textSecondary }]}>Şifremi Unuttum</Text>
                    </TouchableOpacity>
                </BlurView>

                {/* Sosyal Giriş */}
                <View style={styles.socialContainer}>
                    <View style={styles.divider}>
                        <View style={[styles.line, { backgroundColor: colors.border }]} />
                        <Text style={[styles.dividerText, { color: colors.textSecondary }]}>veya</Text>
                        <View style={[styles.line, { backgroundColor: colors.border }]} />
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
                    <Text style={[styles.registerText, { color: colors.textSecondary }]}>
                        Hesabınız yok mu? <Text style={[styles.registerHighlight, { color: colors.secondary }]}>Kayıt Ol</Text>
                    </Text>
                </TouchableOpacity>

            </ScrollView>
        </KeyboardAvoidingView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
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
        marginTop: 16,
    },
    subtitle: {
        fontSize: 16,
        marginTop: 8,
    },
    formCard: {
        borderRadius: AppLayout.largeCornerRadius,
        padding: AppLayout.largePadding,
        overflow: 'hidden',
        borderWidth: 1,
    },
    inputContainer: {
        flexDirection: 'row',
        alignItems: 'center',
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
        fontSize: 16,
    },
    loginButton: {
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
    },
    dividerText: {
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
        fontSize: 15,
    },
    registerHighlight: {
        fontWeight: 'bold',
    }
});
