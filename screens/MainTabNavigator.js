// MainTabNavigator.js
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { createMaterialTopTabNavigator } from '@react-navigation/material-top-tabs';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { hapticManager } from '../HapticManager';

import HomeScreen from './HomeScreen';
import MyTripsScreen from './MyTripsScreen';
import ProfileScreen from './ProfileScreen';

const Tab = createMaterialTopTabNavigator();

export default function MainTabNavigator() {
    const { colors } = useTheme();

    return (
        <Tab.Navigator
            tabBarPosition="bottom"
            screenOptions={({ route }) => ({
                headerShown: false,
                swipeEnabled: true,
                lazy: true,
                tabBarIcon: ({ focused, color }) => {
                    let iconName;
                    if (route.name === 'Home') {
                        iconName = focused ? 'home' : 'home-outline';
                    } else if (route.name === 'MyTrips') {
                        iconName = focused ? 'briefcase' : 'briefcase-outline';
                    } else if (route.name === 'Profile') {
                        iconName = focused ? 'person' : 'person-outline';
                    }
                    return <Ionicons name={iconName} size={24} color={color} />;
                },
                tabBarShowIcon: true,
                tabBarActiveTintColor: colors.secondary,
                tabBarInactiveTintColor: colors.tabBarInactive,
                tabBarIndicatorStyle: { 
                    backgroundColor: colors.secondary,
                    height: 2,
                    borderRadius: 1,
                },
                tabBarStyle: {
                    backgroundColor: colors.isDark ? colors.cardBackground : '#FFFFFF',
                    borderTopWidth: colors.isDark ? 0 : 0.5,
                    borderTopColor: colors.border,
                    elevation: 0,
                    shadowOpacity: 0,
                    height: 85,
                    paddingBottom: 25,
                    paddingTop: 5,
                },
                tabBarLabelStyle: {
                    fontSize: 11,
                    fontWeight: '500',
                    textTransform: 'none',
                    marginTop: 2,
                },
                tabBarIconStyle: {
                    marginBottom: -2,
                },
            })}
            screenListeners={{
                tabPress: () => {
                    hapticManager.selection();
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
