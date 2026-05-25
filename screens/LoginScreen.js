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
import { AppLayout, scale, verticalScale, moderateScale } from './theme';

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
        Alert.alert(
            "Google ile Giriş",
            "Google Sign-In, Expo Go ortamında doğrudan çalışmaz. Uygulamanın production build'i oluşturulduktan sonra 'expo-auth-session' veya '@react-native-google-signin/google-signin' kütüphanesi ile entegre edilmelidir.\n\nŞu an e-posta ile giriş yapabilirsiniz.",
            [{ text: "Anladım" }]
        );
    };

    const handleAppleLogin = () => {
        hapticManager.buttonTap();
        Alert.alert(
            "Apple ile Giriş",
            "Apple Sign-In, Expo Go ortamında doğrudan çalışmaz. Uygulamanın production build'i oluşturulduktan sonra 'expo-apple-authentication' kütüphanesi ile entegre edilmelidir.\n\nŞu an e-posta ile giriş yapabilirsiniz.",
            [{ text: "Anladım" }]
        );
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
            
            <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">
                
                {/* Header Alanı */}
                <View style={styles.headerContainer}>
                    <Ionicons name="airplane" size={moderateScale(56)} color={colors.secondary} />
                    <Text style={[styles.title, { color: colors.textPrimary }]}>Ankara AI Trip Planner</Text>
                    <Text style={[styles.subtitle, { color: colors.textSecondary }]}>Akıllı Seyahat Asistanınız</Text>
                </View>

                {/* Form Kartı (Blur Effect) */}
                <BlurView intensity={30} tint={colors.blurTint} style={[styles.formCard, { borderColor: colors.border, backgroundColor: colors.cardBackgroundRGBA }]}>
                    
                    {/* E-posta */}
                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="mail" size={moderateScale(18)} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="E-posta adresiniz"
                            placeholderTextColor={colors.placeholderText}
                            keyboardType="email-address"
                            autoCapitalize="none"
                            value={email}
                            onChangeText={setEmail}
                        />
                    </View>

                    {/* Şifre */}
                    <View style={[styles.inputContainer, { backgroundColor: colors.inputBackground }]}>
                        <Ionicons name="lock-closed" size={moderateScale(18)} color={colors.textSecondary} style={styles.inputIcon} />
                        <TextInput 
                            style={[styles.input, { color: colors.textPrimary }]}
                            placeholder="Şifreniz"
                            placeholderTextColor={colors.placeholderText}
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
                        <TouchableOpacity 
                            style={[styles.socialButton, { 
                                backgroundColor: colors.isDark ? 'rgba(255,255,255,0.1)' : '#FFFFFF',
                                borderWidth: colors.isDark ? 1 : 0,
                                borderColor: colors.border 
                            }]} 
                            onPress={handleGoogleLogin}
                        >
                            <Ionicons name="logo-google" size={moderateScale(18)} color={colors.isDark ? '#FFFFFF' : '#4285F4'} />
                            <Text style={[styles.socialButtonText, { color: colors.isDark ? '#FFFFFF' : '#4285F4' }]}>Google</Text>
                        </TouchableOpacity>

                        {Platform.OS === 'ios' && (
                            <TouchableOpacity 
                                style={[styles.socialButton, { 
                                    backgroundColor: colors.isDark ? 'rgba(255,255,255,0.1)' : '#000000',
                                    borderWidth: colors.isDark ? 1 : 0,
                                    borderColor: colors.border
                                }]} 
                                onPress={handleAppleLogin}
                            >
                                <Ionicons name="logo-apple" size={moderateScale(18)} color="#FFFFFF" />
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
        marginBottom: verticalScale(32),
        marginTop: verticalScale(40),
    },
    title: {
        fontSize: moderateScale(28),
        fontWeight: 'bold',
        marginTop: verticalScale(12),
        textAlign: 'center',
    },
    subtitle: {
        fontSize: moderateScale(15),
        marginTop: verticalScale(6),
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
        marginBottom: verticalScale(14),
        paddingHorizontal: scale(16),
    },
    inputIcon: {
        marginRight: scale(12),
    },
    input: {
        flex: 1,
        fontSize: moderateScale(15),
    },
    loginButton: {
        height: AppLayout.buttonHeight,
        borderRadius: AppLayout.cornerRadius,
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: verticalScale(6),
    },
    loginButtonText: {
        color: '#FFF',
        fontSize: moderateScale(16),
        fontWeight: 'bold',
    },
    forgotPasswordButton: {
        alignItems: 'center',
        marginTop: verticalScale(14),
    },
    forgotPasswordText: {
        fontSize: moderateScale(13),
    },
    socialContainer: {
        marginTop: verticalScale(28),
    },
    divider: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: verticalScale(20),
    },
    line: {
        flex: 1,
        height: 1,
    },
    dividerText: {
        paddingHorizontal: scale(12),
        fontSize: moderateScale(13),
    },
    socialButtonsRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        gap: scale(12),
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
        fontSize: moderateScale(15),
        fontWeight: 'bold',
        marginLeft: scale(10),
    },
    registerContainer: {
        marginTop: verticalScale(32),
        marginBottom: verticalScale(32),
        alignItems: 'center',
    },
    registerText: {
        fontSize: moderateScale(14),
    },
    registerHighlight: {
        fontWeight: 'bold',
    }
});
