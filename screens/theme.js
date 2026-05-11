// theme.js
// Uygulama genelinde kullanılacak renk, font ve layout sabitleri

export const AppColors = {
    primary: '#1C1C1E',      // Koyu tema arka plan ana renk
    secondary: '#00C7BF',    // Vurgu rengi (Turkuaz/Mint)
    accent: '#FF9500',       // İkincil vurgu (Turuncu)
    background: '#000000',   // Tam siyah (OLED uyumlu)
    
    // Gradient Renkleri
    gradientStart: '#2C3E50',
    gradientEnd: '#000000',
    
    // UI Elementleri
    cardBackground: 'rgba(255, 255, 255, 0.1)',
    textPrimary: '#FFFFFF',
    textSecondary: 'rgba(255, 255, 255, 0.7)',
    textTertiary: 'rgba(255, 255, 255, 0.4)',
    border: 'rgba(255, 255, 255, 0.2)'
};

export const AppLayout = {
    cornerRadius: 12,
    largeCornerRadius: 24,
    defaultPadding: 16,
    largePadding: 24,
    buttonHeight: 52
};
