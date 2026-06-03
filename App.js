// App.js
import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { ActivityIndicator, View } from 'react-native';

// Firebase İlklendirme (Tüm servislerden önce çağrılmalı)
import './firebaseConfig';

// Tema
import { ThemeProvider, useTheme } from './ThemeContext';
import { firebaseAuthService } from './FirebaseAuthService';

// Ekranlar (Auth)
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

function AppNavigator() {
  const { colors } = useTheme();
  const [isLoading, setIsLoading] = useState(true);
  const [initialRoute, setInitialRoute] = useState('Login');

  useEffect(() => {
    checkInitialState();
  }, []);

  const checkInitialState = async () => {
    try {
      // Firebase Auth durumunu kontrol et
      const user = firebaseAuthService.currentFirebaseUser;

      if (user) {
        setInitialRoute('MainTab');
      } else {
        setInitialRoute('Login');
      }
    } catch (error) {
      console.error("Başlangıç durumu kontrol edilemedi", error);
      setInitialRoute('Login');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <View style={{ flex: 1, backgroundColor: colors.background, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color={colors.secondary} />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName={initialRoute}
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: colors.background },
          animation: 'slide_from_right'
        }}
      >
        {/* Auth */}
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

export default function App() {
  return (
    <ThemeProvider>
      <AppNavigator />
    </ThemeProvider>
  );
}
