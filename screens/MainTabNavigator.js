// MainTabNavigator.js
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { AppColors } from './theme';
import { hapticManager } from '../HapticManager';

// Ekranları import edin
import HomeScreen from './HomeScreen';
import MyTripsScreen from './MyTripsScreen';
import ProfileScreen from './ProfileScreen';

const Tab = createBottomTabNavigator();

export default function MainTabNavigator() {
    return (
        <Tab.Navigator
            screenOptions={({ route }) => ({
                headerShown: false,
                tabBarIcon: ({ focused, color, size }) => {
                    let iconName;

                    if (route.name === 'Home') {
                        iconName = focused ? 'home' : 'home-outline';
                    } else if (route.name === 'MyTrips') {
                        iconName = focused ? 'briefcase' : 'briefcase-outline';
                    } else if (route.name === 'Profile') {
                        iconName = focused ? 'person' : 'person-outline';
                    }

                    return <Ionicons name={iconName} size={size} color={color} />;
                },
                tabBarActiveTintColor: AppColors.secondary, // Seçili renk (Turkuaz)
                tabBarInactiveTintColor: 'rgba(255,255,255,0.4)', // Seçili olmayan renk
                tabBarStyle: {
                    backgroundColor: AppColors.cardBackground, // Şeffaf/Blur tarzı arka plan
                    borderTopWidth: 0,
                    elevation: 0, // Android shadow kapat
                    height: 85,
                    paddingBottom: 25,
                    paddingTop: 10,
                },
                tabBarLabelStyle: {
                    fontSize: 11,
                    fontWeight: '500',
                }
            })}
            screenListeners={{
                tabPress: () => {
                    hapticManager.selection(); // Tab değişimlerinde hafif titreşim
                },
            }}
        >
            <Tab.Screen 
                name="Home" 
                component={HomeScreen} 
                options={{ title: 'Ana Sayfa' }} 
            />
            <Tab.Screen 
                name="MyTrips" 
                component={MyTripsScreen} 
                options={{ title: 'Tatilim' }} 
            />
            <Tab.Screen 
                name="Profile" 
                component={ProfileScreen} 
                options={{ title: 'Profilim' }} 
            />
        </Tab.Navigator>
    );
}
