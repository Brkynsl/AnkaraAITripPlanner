// theme.js
// Layout sabitleri — renk değerleri artık ThemeContext üzerinden yönetiliyor.
// import { useTheme } from '../ThemeContext'; şeklinde kullanılmalı.

import { Dimensions, Platform, StatusBar } from 'react-native';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// Responsive ölçekleme yardımcıları
// iPhone 14 Pro (390pt) bazında normalize edilmiştir
const guidelineBaseWidth = 390;
const guidelineBaseHeight = 844;

// Genişliğe göre ölçekle (yatay elemanlar, padding, margin vb.)
export const scale = (size) => (SCREEN_WIDTH / guidelineBaseWidth) * size;

// Yüksekliğe göre ölçekle (dikey elemanlar)
export const verticalScale = (size) => (SCREEN_HEIGHT / guidelineBaseHeight) * size;

// Orta düzey ölçekleme (font boyutları için ideal — büyük ekranlarda aşırı büyümez)
export const moderateScale = (size, factor = 0.5) => size + (scale(size) - size) * factor;

// Safe area top padding (status bar)
export const STATUS_BAR_HEIGHT = Platform.OS === 'ios' ? 44 : StatusBar.currentHeight || 24;

export const AppLayout = {
    cornerRadius: scale(12),
    largeCornerRadius: scale(24),
    defaultPadding: scale(16),
    largePadding: scale(24),
    buttonHeight: verticalScale(52),
    // Responsive ekran boyutları
    screenWidth: SCREEN_WIDTH,
    screenHeight: SCREEN_HEIGHT,
    statusBarHeight: STATUS_BAR_HEIGHT,
    // Responsive top padding (safe area dahil)
    headerPaddingTop: STATUS_BAR_HEIGHT + verticalScale(16),
};
