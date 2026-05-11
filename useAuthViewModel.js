// useAuthViewModel.js
// React Native / React Hook formatında AuthViewModel

import { useState } from 'react';
import { firebaseAuthService } from './FirebaseAuthService';
import { FormValidator } from './Validators';

export const AuthState = {
    IDLE: 'idle',
    LOADING: 'loading',
    SUCCESS: 'success',
    ERROR: 'error',
    PASSWORD_RESET_SENT: 'passwordResetSent'
};

export function useAuthViewModel() {
    const [state, setState] = useState(AuthState.IDLE);
    const [errorMsg, setErrorMsg] = useState(null);
    const [user, setUser] = useState(null);

    const _setLoading = () => {
        setState(AuthState.LOADING);
        setErrorMsg(null);
    };

    const _setError = (msg) => {
        setState(AuthState.ERROR);
        setErrorMsg(msg);
    };

    const _setSuccess = (userData) => {
        setState(AuthState.SUCCESS);
        setUser(userData);
    };

    // Firebase hatalarını Türkçe mesajlara çevirir
    const friendlyErrorMessage = (error) => {
        const code = error.code || error.message;
        if (code.includes('user-disabled')) return "Bu hesap devre dışı bırakılmış.";
        if (code.includes('invalid-email')) return "Geçersiz e-posta formatı.";
        if (code.includes('wrong-password') || code.includes('invalid-credential')) return "E-posta veya şifre hatalı.";
        if (code.includes('user-not-found')) return "Bu e-posta ile kayıtlı bir hesap bulunamadı.";
        if (code.includes('email-already-in-use')) return "Bu e-posta adresi zaten kullanılıyor.";
        if (code.includes('weak-password')) return "Şifre çok zayıf. En az 6 karakter kullanın.";
        if (code.includes('network-request-failed')) return "İnternet bağlantınızı kontrol edin.";
        return "Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.";
    };

    const signInWithEmail = async (email, password) => {
        const emailResult = FormValidator.validateEmail(email);
        if (!emailResult.isValid) return _setError(emailResult.errorMessage || "Geçersiz e-posta.");

        const passwordResult = FormValidator.validatePassword(password);
        if (!passwordResult.isValid) return _setError(passwordResult.errorMessage || "Geçersiz şifre.");

        _setLoading();
        try {
            const resultUser = await firebaseAuthService.signInWithEmail(email.trim(), password);
            _setSuccess(resultUser);
        } catch (error) {
            _setError(friendlyErrorMessage(error));
        }
    };

    const signUpWithEmail = async (name, email, password, confirmPassword) => {
        const nameResult = FormValidator.validateName(name);
        if (!nameResult.isValid) return _setError(nameResult.errorMessage || "Geçersiz isim.");

        const emailResult = FormValidator.validateEmail(email);
        if (!emailResult.isValid) return _setError(emailResult.errorMessage || "Geçersiz e-posta.");

        const passwordResult = FormValidator.validatePassword(password);
        if (!passwordResult.isValid) return _setError(passwordResult.errorMessage || "Geçersiz şifre.");

        const matchResult = FormValidator.validatePasswordMatch(password, confirmPassword);
        if (!matchResult.isValid) return _setError(matchResult.errorMessage || "Şifreler eşleşmiyor.");

        _setLoading();
        try {
            const resultUser = await firebaseAuthService.signUpWithEmail(email.trim(), password, name.trim());
            _setSuccess(resultUser);
        } catch (error) {
            _setError(friendlyErrorMessage(error));
        }
    };

    const resetPassword = async (email) => {
        const emailResult = FormValidator.validateEmail(email);
        if (!emailResult.isValid) return _setError(emailResult.errorMessage || "Geçersiz e-posta.");

        _setLoading();
        try {
            await firebaseAuthService.resetPassword(email.trim());
            setState(AuthState.PASSWORD_RESET_SENT);
        } catch (error) {
            _setError(friendlyErrorMessage(error));
        }
    };

    const signInWithGoogle = async (idToken) => {
        _setLoading();
        try {
            const resultUser = await firebaseAuthService.signInWithGoogle(idToken);
            _setSuccess(resultUser);
        } catch (error) {
            _setError(friendlyErrorMessage(error));
        }
    };

    const signInWithApple = async (idToken, nonce) => {
        _setLoading();
        try {
            const resultUser = await firebaseAuthService.signInWithApple(idToken, nonce);
            _setSuccess(resultUser);
        } catch (error) {
            _setError(friendlyErrorMessage(error));
        }
    };

    return {
        state,
        errorMsg,
        user,
        signInWithEmail,
        signUpWithEmail,
        resetPassword,
        signInWithGoogle,
        signInWithApple
    };
}
