// Models.js
// Swift'teki TripPlan, DayPlan, PlannedActivity, BudgetBreakdown gibi modellerin JavaScript karşılığı.

export const ActivityCategory = {
    MUSEUM: 'museum',
    RESTAURANT: 'restaurant',
    PARK: 'park',
    LANDMARK: 'landmark',
    SHOPPING: 'shopping',
    NIGHTLIFE: 'nightlife',
    TRANSPORT: 'transport',
    HOTEL: 'hotel',
    OTHER: 'other'
};

export const PlanType = {
    ECONOMIC: 'economic',
    BALANCED: 'balanced',
    COMFORT: 'comfort'
};

export const TransportType = {
    FLIGHT: 'flight',
    BUS: 'bus',
    TRAIN: 'train',
    CAR: 'car'
};

// JS'de struct yerine genellikle class veya doğrudan object literal kullanılır.
// Burada tip tanımlamalarını ve veri yapısını oluşturacak factory fonksiyonları ekleyebiliriz.

export const createBudgetBreakdown = (transportation, accommodation, food, localTransport, activities, miscellaneous) => ({
    transportation,
    accommodation,
    food,
    localTransport,
    activities,
    miscellaneous,
    total: transportation + accommodation + food + localTransport + activities + miscellaneous
});

export const createPlannedActivity = ({
    name, description, category, startTime, endTime, estimatedCost, 
    latitude, longitude, address, transportToNext = null, transportCost = null, 
    entryFee = null, openingHours = null, transportInfo = null, tips = null
}) => ({
    name, description, category, startTime, endTime, estimatedCost, 
    latitude, longitude, address, transportToNext, transportCost, 
    entryFee, openingHours, transportInfo, tips
});

export const createDayPlan = (dayNumber, title, activities, estimatedCost, totalDistance = null) => ({
    dayNumber,
    title,
    activities,
    estimatedCost,
    totalDistance
});

export const createTripPlan = ({
    title, description, planType, transportation, hotel, dailyPlans, 
    budgetBreakdown, totalEstimatedCost, recommendation, fitScore
}) => ({
    title, description, planType, transportation, hotel, dailyPlans, 
    budgetBreakdown, totalEstimatedCost, recommendation, fitScore
});
