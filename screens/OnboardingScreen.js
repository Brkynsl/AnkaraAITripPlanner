// OnboardingScreen.js
import React, { useState, useRef } from 'react';
import { View, Text, StyleSheet, Dimensions, TouchableOpacity, FlatList } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useOnboardingViewModel } from '../useOnboardingViewModel';
import { hapticManager } from '../HapticManager';
import { AppColors, AppLayout } from './theme';

const { width, height } = Dimensions.get('window');

export default function OnboardingScreen({ navigation }) {
    const { pages, totalPages, isLastPage, completeOnboarding } = useOnboardingViewModel();
    const [currentIndex, setCurrentIndex] = useState(0);
    const flatListRef = useRef(null);

    const handleNext = async () => {
        hapticManager.buttonTap();
        
        if (isLastPage(currentIndex)) {
            await completeOnboarding();
            // navigation.replace('MainTab'); // Navigation kurulduğunda açılacak
            console.log("Onboarding tamamlandı, ana ekrana yönlendiriliyor...");
        } else {
            const nextIndex = currentIndex + 1;
            flatListRef.current?.scrollToIndex({ index: nextIndex, animated: true });
            setCurrentIndex(nextIndex);
        }
    };

    const handleSkip = async () => {
        hapticManager.buttonTap();
        await completeOnboarding();
        // navigation.replace('MainTab');
        console.log("Onboarding atlandı, ana ekrana yönlendiriliyor...");
    };

    const onScroll = (event) => {
        const slideSize = event.nativeEvent.layoutMeasurement.width;
        const index = event.nativeEvent.contentOffset.x / slideSize;
        const roundIndex = Math.round(index);
        
        if (currentIndex !== roundIndex) {
            setCurrentIndex(roundIndex);
            hapticManager.selectionChanged();
        }
    };

    const renderItem = ({ item }) => (
        <View style={styles.pageContainer}>
            <View style={[styles.iconContainer, { shadowColor: item.accentColor }]}>
                <Ionicons name={item.iconName} size={80} color={item.accentColor} />
            </View>
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.description}>{item.description}</Text>
        </View>
    );

    return (
        <View style={styles.container}>
            <LinearGradient
                colors={[AppColors.gradientStart, AppColors.primary, AppColors.gradientEnd]}
                style={StyleSheet.absoluteFillObject}
            />

            {!isLastPage(currentIndex) && (
                <TouchableOpacity style={styles.skipButton} onPress={handleSkip}>
                    <Text style={styles.skipText}>Atla</Text>
                </TouchableOpacity>
            )}

            <FlatList
                ref={flatListRef}
                data={pages}
                renderItem={renderItem}
                horizontal
                pagingEnabled
                showsHorizontalScrollIndicator={false}
                onScroll={onScroll}
                scrollEventThrottle={16}
                keyExtractor={(_, index) => index.toString()}
            />

            <View style={styles.bottomContainer}>
                {/* Dots */}
                <View style={styles.paginationContainer}>
                    {pages.map((_, index) => (
                        <View
                            key={index}
                            style={[
                                styles.dot,
                                { backgroundColor: currentIndex === index ? AppColors.secondary : 'rgba(255,255,255,0.3)' },
                                currentIndex === index && { width: 24 } // Aktif olan daha uzun
                            ]}
                        />
                    ))}
                </View>

                {/* Next / Start Button */}
                <TouchableOpacity 
                    style={[styles.nextButton, { backgroundColor: isLastPage(currentIndex) ? AppColors.accent : AppColors.secondary }]} 
                    onPress={handleNext}
                    activeOpacity={0.8}
                >
                    <Text style={styles.nextButtonText}>
                        {isLastPage(currentIndex) ? 'Başla' : 'İlerle'}
                    </Text>
                </TouchableOpacity>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    pageContainer: {
        width,
        alignItems: 'center',
        justifyContent: 'center',
        paddingHorizontal: AppLayout.largePadding,
    },
    iconContainer: {
        width: 160,
        height: 160,
        borderRadius: 80,
        backgroundColor: 'rgba(255,255,255,0.05)',
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 40,
        shadowOffset: { width: 0, height: 10 },
        shadowOpacity: 0.5,
        shadowRadius: 20,
        elevation: 10,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: AppColors.textPrimary,
        textAlign: 'center',
        marginBottom: 16,
    },
    description: {
        fontSize: 16,
        color: AppColors.textSecondary,
        textAlign: 'center',
        lineHeight: 24,
    },
    bottomContainer: {
        position: 'absolute',
        bottom: 40,
        left: 0,
        right: 0,
        paddingHorizontal: AppLayout.largePadding,
    },
    paginationContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        marginBottom: 32,
    },
    dot: {
        height: 8,
        width: 8,
        borderRadius: 4,
        marginHorizontal: 4,
    },
    nextButton: {
        height: AppLayout.buttonHeight,
        borderRadius: AppLayout.cornerRadius,
        justifyContent: 'center',
        alignItems: 'center',
    },
    nextButtonText: {
        color: '#FFFFFF',
        fontSize: 17,
        fontWeight: 'bold',
    },
    skipButton: {
        position: 'absolute',
        top: 60,
        right: 24,
        zIndex: 10,
        padding: 8,
    },
    skipText: {
        color: AppColors.textSecondary,
        fontSize: 15,
        fontWeight: '500',
    }
});
