// HapticManager.js
// Expo Haptics kullanılarak yazılmış dokunsal geri bildirim servisi (React Native uyumlu)

import * as Haptics from 'expo-haptics';

class HapticManager {
    // Darbe (Impact) Feedback
    async impact(style = Haptics.ImpactFeedbackStyle.Medium) {
        try {
            await Haptics.impactAsync(style);
        } catch (error) {
            console.log("Haptic desteklenmiyor veya hata:", error);
        }
    }

    // Bildirim (Notification) Feedback
    async notification(type) {
        try {
            await Haptics.notificationAsync(type);
        } catch (error) {
            console.log("Haptic desteklenmiyor veya hata:", error);
        }
    }

    // Seçim (Selection) Feedback
    async selection() {
        try {
            await Haptics.selectionAsync();
        } catch (error) {
            console.log("Haptic desteklenmiyor veya hata:", error);
        }
    }

    // Kısa Yollar

    async success() {
        await this.notification(Haptics.NotificationFeedbackType.Success);
    }

    async error() {
        await this.notification(Haptics.NotificationFeedbackType.Error);
    }

    async warning() {
        await this.notification(Haptics.NotificationFeedbackType.Warning);
    }

    async buttonTap() {
        await this.impact(Haptics.ImpactFeedbackStyle.Light);
    }

    async lightImpact() {
        await this.impact(Haptics.ImpactFeedbackStyle.Light);
    }

    async selectionChanged() {
        await this.selection();
    }

    async cardSelect() {
        await this.impact(Haptics.ImpactFeedbackStyle.Medium);
    }
}

export const hapticManager = new HapticManager();
