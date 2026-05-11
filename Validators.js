// Validators.js
// Form doğrulama mantığını merkezi bir yapıda toplayan servis

export const ValidationResult = {
    valid: () => ({ isValid: true, errorMessage: null }),
    invalid: (message) => ({ isValid: false, errorMessage: message })
};

export const FormValidator = {
    
    validateEmail: (email) => {
        const trimmed = email.trim();
        if (trimmed.length === 0) {
            return ValidationResult.invalid("E-posta adresi boş bırakılamaz.");
        }
        // Basit regex email kontrolü
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(trimmed)) {
            return ValidationResult.invalid("Geçerli bir e-posta adresi giriniz.");
        }
        return ValidationResult.valid();
    },

    validatePassword: (password) => {
        if (password.length === 0) {
            return ValidationResult.invalid("Şifre boş bırakılamaz.");
        }
        if (password.length < 6) {
            return ValidationResult.invalid("Şifre en az 6 karakter olmalıdır.");
        }
        return ValidationResult.valid();
    },

    validatePasswordMatch: (password, confirmPassword) => {
        if (confirmPassword.length === 0) {
            return ValidationResult.invalid("Şifre tekrarı boş bırakılamaz.");
        }
        if (password !== confirmPassword) {
            return ValidationResult.invalid("Şifreler eşleşmiyor.");
        }
        return ValidationResult.valid();
    },

    validateName: (name) => {
        const trimmed = name.trim();
        if (trimmed.length === 0) {
            return ValidationResult.invalid("Ad soyad boş bırakılamaz.");
        }
        if (trimmed.length < 2) {
            return ValidationResult.invalid("Geçerli bir ad soyad giriniz (en az 2 karakter).");
        }
        return ValidationResult.valid();
    },

    validateBudget: (budgetText) => {
        const trimmed = String(budgetText).trim();
        if (trimmed.length === 0) {
            return ValidationResult.invalid("Bütçe boş bırakılamaz.");
        }
        const budget = Number(trimmed);
        if (isNaN(budget)) {
            return ValidationResult.invalid("Geçerli bir sayı giriniz.");
        }
        if (budget <= 0) {
            return ValidationResult.invalid("Bütçe sıfırdan büyük olmalıdır.");
        }
        if (budget > 1000000) {
            return ValidationResult.invalid("Bütçe gerçekçi bir değer olmalıdır.");
        }
        return ValidationResult.valid();
    },

    validateDays: (daysText) => {
        const trimmed = String(daysText).trim();
        if (trimmed.length === 0) {
            return ValidationResult.invalid("Gün sayısı boş bırakılamaz.");
        }
        const days = Number(trimmed);
        if (isNaN(days) || !Number.isInteger(days)) {
            return ValidationResult.invalid("Geçerli bir tamsayı giriniz.");
        }
        if (days < 1) {
            return ValidationResult.invalid("En az 1 gün seçmelisiniz.");
        }
        if (days > 30) {
            return ValidationResult.invalid("En fazla 30 gün seçebilirsiniz.");
        }
        return ValidationResult.valid();
    },

    validateCity: (city) => {
        if (city.trim().length === 0) {
            return ValidationResult.invalid("Lütfen bir şehir seçiniz.");
        }
        return ValidationResult.valid();
    }
};
