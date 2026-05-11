// App.js
import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ActivityIndicator, View } from 'react-native';

// Firebase İlklendirme (Tüm servislerden önce çağrılmalı)
import './firebaseConfig';

// Tema ve Firebase Servisi
import { AppColors } from './screens/theme';
import { firebaseAuthService } from './FirebaseAuthService';

// Ekranlar (Auth & Onboarding)
import OnboardingScreen from './screens/OnboardingScreen';
import LoginScreen from './screens/LoginScreen';
import RegisterScreen from './screens/RegisterScreen';

// Ekranlar (Main Tab)
import MainTabNavigator from './screens/MainTabNavigator';

// Ekranlar (Trip Flow & Diğerleri)
import TripBuilderScreen from './screens/TripBuilderScreen';
import GeneratingTripScreen from './screens/GeneratingTripScreen';
import TripAlternativesScreen from './screens/TripAlternativesScreen';
import TripDetailScreen from './screens/TripDetailScreen';
import TripMapScreen from './screens/TripMapScreen';
import PreferencesScreen from './screens/PreferencesScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  const [isLoading, setIsLoading] = useState(true);
  const [initialRoute, setInitialRoute] = useState('Onboarding');

  useEffect(() => {
    checkInitialState();
  }, []);

  const checkInitialState = async () => {
    try {
      // 1. Firebase Auth durumunu kontrol et
      // Not: Gerçek projede onAuthStateChanged listener'ı kullanmak daha iyidir
      // Burada basitlik adına doğrudan servisten okuyoruz veya bekliyoruz
      const user = firebaseAuthService.currentFirebaseUser;
      
      // 2. Onboarding tamamlandı mı?
      const hasCompletedOnboarding = await AsyncStorage.getItem('hasCompletedOnboarding');
      
      if (user) {
        setInitialRoute('MainTab');
      } else if (hasCompletedOnboarding === 'true') {
        setInitialRoute('Login');
      } else {
        setInitialRoute('Onboarding');
      }
    } catch (error) {
      console.error("Başlangıç durumu kontrol edilemedi", error);
      setInitialRoute('Onboarding');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <View style={{ flex: 1, backgroundColor: AppColors.background, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color={AppColors.secondary} />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator 
        initialRouteName={initialRoute}
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: AppColors.background },
          animation: 'slide_from_right'
        }}
      >
        {/* Onboarding & Auth */}
        <Stack.Screen name="Onboarding" component={OnboardingScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Register" component={RegisterScreen} options={{ presentation: 'modal' }} />

        {/* Main Application */}
        <Stack.Screen name="MainTab" component={MainTabNavigator} />
        
        {/* Trip Flow */}
        <Stack.Screen name="TripBuilder" component={TripBuilderScreen} />
        <Stack.Screen name="GeneratingTrip" component={GeneratingTripScreen} options={{ animation: 'fade' }} />
        <Stack.Screen name="TripAlternatives" component={TripAlternativesScreen} options={{ presentation: 'fullScreenModal' }} />
        
        {/* Details & Map */}
        <Stack.Screen name="TripDetail" component={TripDetailScreen} />
        <Stack.Screen name="TripMap" component={TripMapScreen} options={{ presentation: 'modal', animation: 'slide_from_bottom' }} />
        
        {/* Profile Settings */}
        <Stack.Screen name="Preferences" component={PreferencesScreen} />

      </Stack.Navigator>
    </NavigationContainer>
  );
}
