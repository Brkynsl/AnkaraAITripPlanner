// AppUser.js
// Firebase Auth ve Firestore'da tutulan kullanıcı modeli

export const AuthProvider = {
    EMAIL: 'email',
    APPLE: 'apple',
    GOOGLE: 'google'
};

export const createAppUser = ({
    uid,
    displayName,
    email,
    photoURL = null,
    authProvider,
    hasCompletedOnboarding = false,
    createdAt = new Date(),
    updatedAt = null
}) => ({
    uid,
    displayName,
    email,
    photoURL,
    authProvider,
    hasCompletedOnboarding,
    createdAt,
    updatedAt
});
