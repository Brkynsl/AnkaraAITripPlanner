// MainTabNavigator.js
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../ThemeContext';
import { hapticManager } from '../HapticManager';

import HomeScreen from './HomeScreen';
import MyTripsScreen from './MyTripsScreen';
import ProfileScreen from './ProfileScreen';

const Tab = createBottomTabNavigator();

export default function MainTabNavigator() {
    const { colors } = useTheme();

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
                tabBarActiveTintColor: colors.secondary,
                tabBarInactiveTintColor: colors.tabBarInactive,
                tabBarStyle: {
                    backgroundColor: colors.isDark ? colors.cardBackground : '#FFFFFF',
                    borderTopWidth: colors.isDark ? 0 : 0.5,
                    borderTopColor: colors.border,
                    elevation: 0,
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
