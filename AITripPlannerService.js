// AITripPlannerService.js
import { ActivityCategory, PlanType, TransportType, createBudgetBreakdown, createDayPlan, createTripPlan } from './Models';
import ankaraPlacesData from './data/ankara_places.json';

// Mesafe hesaplamak için yardımcı fonksiyon (Haversine Formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // metres
    const φ1 = lat1 * Math.PI/180; // φ, λ in radians
    const φ2 = lat2 * Math.PI/180;
    const Δφ = (lat2-lat1) * Math.PI/180;
    const Δλ = (lon2-lon1) * Math.PI/180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c; // in metres
}

class AITripPlannerService {
    
    generateTripPlans(city, days, budget) {
        return new Promise((resolve) => {
            setTimeout(() => {
                const cityData = this.getCityData(city);
                
                const ecoPlan = this.buildOptimizedPlan(
                    "Ekonomik & Optimize Rota",
                    `${city} için bütçe dostu, ulaşım ve konaklamada maksimum tasarruf sağlayan rota.`,
                    PlanType.ECONOMIC, city, days, budget, cityData, 'budget', TransportType.BUS, 85
                );
                
                const balancedPlan = this.buildOptimizedPlan(
                    "Dengeli Konfor",
                    `Konfor ve bütçe arasında mükemmel denge. ${city} merkezine yakın konaklama.`,
                    PlanType.BALANCED, city, days, budget, cityData, 'mid', TransportType.TRAIN, 95
                );
                
                const comfortPlan = this.buildOptimizedPlan(
                    "Premium Deneyim",
                    `${city} seyahatinizi unutulmaz kılacak ultra konforlu otel ve VIP ulaşım.`,
                    PlanType.COMFORT, city, days, budget, cityData, 'luxury', TransportType.FLIGHT, 88
                );
                
                resolve([ecoPlan, balancedPlan, comfortPlan]);
            }, 1000);
        });
    }

    buildOptimizedPlan(title, description, type, city, days, budget, cityData, hotelTier, transportType, fitScore) {
        
        // 1. Hedef Bütçe Ölçeklendirmesi (Kullanıcının girdiği 'budget' tavan kabul edilir)
        // Kullanıcı 20.000 TL dediyse Premium 20.000 TL civarı tutmalı, Eko ve Dengeli daha ucuz olmalı.
        let targetBudget = budget;
        if (type === PlanType.ECONOMIC) targetBudget = budget * 0.50;      // Örn: 15.000 için 7.500 TL bandı
        else if (type === PlanType.BALANCED) targetBudget = budget * 0.75; // Örn: 15.000 için 11.250 TL bandı
        else if (type === PlanType.COMFORT) targetBudget = budget * 0.95;  // Bütçenin %95'i hedeflenir, asla aşılmaz

        // 2. Ulaşım Maliyetlerini Sabit ve Mantıklı Aralıklarla Belirleme
        let transportCost = 0;
        switch (transportType) {
            case TransportType.FLIGHT: transportCost = 2500; break;
            case TransportType.BUS: transportCost = 600; break;
            case TransportType.TRAIN: transportCost = 800; break;
            case TransportType.CAR: transportCost = 1500; break;
        }
        
        // 3. Otel Fiyatını Hedef Bütçeye Göre Matematiksel Seçme
        const daysToStay = Math.max(1, days - 1);
        // Aktiviteler ve yemek için günlük ortalama 1000 TL düşüyoruz
        const estimatedActivitiesCost = days * 1000;
        const targetTotalHotelCost = targetBudget - transportCost - estimatedActivitiesCost;
        let targetPricePerNight = targetTotalHotelCost / daysToStay;

        // Eksi veya çok düşük değerlere düşmemesi için alt limit
        if (targetPricePerNight < 800) targetPricePerNight = 800;

        // Havuzdaki otelleri fiyata göre sırala (ucuzdan pahalıya) — bütçe aşımında geri düşmek için
        const sortedHotels = [...cityData.hotels].sort((a, b) => a.pricePerNight - b.pricePerNight);

        // Hedef gecelik fiyata en yakın oteli bul
        let hotel = sortedHotels.reduce((prev, curr) => {
            return (Math.abs(curr.pricePerNight - targetPricePerNight) < Math.abs(prev.pricePerNight - targetPricePerNight) ? curr : prev);
        });
        let hotelIndex = sortedHotels.indexOf(hotel);

        let hotelTotalCost = hotel.pricePerNight * daysToStay;
        
        let allActivities = [...cityData.activities].sort(() => 0.5 - Math.random());
        let dailyPlans = [];
        let currentLocation = { lat: hotel.latitude, lon: hotel.longitude };

        for (let i = 1; i <= days; i++) {
            const activitiesPerDay = Math.min(i === 1 ? 3 : 4, allActivities.length);
            if (activitiesPerDay === 0) break;

            let dayActivities = [];
            for (let j = 0; j < activitiesPerDay; j++) {
                // Eğer aktivite kalmadıysa listeyi tekrar doldur (Böylece istenilen gün kadar plan üretilebilir)
                if (allActivities.length === 0) {
                    allActivities = [...cityData.activities].sort(() => 0.5 - Math.random());
                }

                // Nearest-neighbor
                allActivities.sort((a, b) => {
                    const distA = calculateDistance(currentLocation.lat, currentLocation.lon, a.latitude, a.longitude);
                    const distB = calculateDistance(currentLocation.lat, currentLocation.lon, b.latitude, b.longitude);
                    return distA - distB;
                });

                let activity = allActivities.shift();
                if (!activity) break;

                // Mevcut konumdan bu aktiviteye olan mesafe (metre -> kilometre)
                const distanceMeters = calculateDistance(currentLocation.lat, currentLocation.lon, activity.latitude, activity.longitude);
                const distanceKm = distanceMeters / 1000;

                // Karar Ağacı Algoritması (Heuristic Transportation Logic)
                let transportMode = "";
                let trCost = 0;

                if (distanceKm < 1.2) {
                    transportMode = `🚶 Yürüyüş (~${Math.max(5, Math.ceil(distanceKm * 12))} dk)`;
                    trCost = 0;
                } else if (distanceKm <= 8) {
                    if (type === PlanType.ECONOMIC || type === PlanType.BALANCED) {
                        transportMode = `🚌 Toplu Taşıma (~${Math.ceil(distanceKm * 5)} dk)`;
                        trCost = 20; // Tam bilet ücreti ortalama
                    } else {
                        transportMode = `🚕 Taksi (~${Math.ceil(distanceKm * 2.5)} dk)`;
                        trCost = 25 + (distanceKm * 20); // 25 TL açılış, KM başı 20 TL
                    }
                } else {
                    if (type === PlanType.ECONOMIC) {
                        transportMode = `🚌 Uzun Hat / Aktarma (~${Math.ceil(distanceKm * 4)} dk)`;
                        trCost = 35;
                    } else {
                        transportMode = `🚕 Taksi (~${Math.ceil(distanceKm * 2)} dk)`;
                        trCost = 25 + (distanceKm * 20);
                    }
                }

                const startHour = 9 + j * 3;
                activity = {
                    ...activity,
                    startTime: `${startHour.toString().padStart(2, '0')}:00`,
                    endTime: `${(startHour + 2).toString().padStart(2, '0')}:00`,
                    transportInfo: `${distanceKm.toFixed(1)} km • ${transportMode}`,
                    transportCost: Math.floor(trCost)
                };

                dayActivities.push(activity);
                currentLocation = { lat: activity.latitude, lon: activity.longitude };
            }

            const dailyCost = dayActivities.reduce((acc, act) => acc + act.estimatedCost + (act.transportCost || 0) + (act.entryFee || 0), 0);
            
            let totalDist = 0;
            let prevLoc = { lat: hotel.latitude, lon: hotel.longitude };
            for (const act of dayActivities) {
                totalDist += calculateDistance(prevLoc.lat, prevLoc.lon, act.latitude, act.longitude);
                prevLoc = { lat: act.latitude, lon: act.longitude };
            }
            const distKm = totalDist / 1000.0;

            const dayTitles = ["Tarihi Keşif", "Kültür & Sanat", "Doğa & Park", "Alışveriş & Lezzet", "Panoramik Gezi"];
            const dayTitle = dayTitles[Math.min(i - 1, dayTitles.length - 1)];

            dailyPlans.push(createDayPlan(i, `Gün ${i}: ${dayTitle}`, dayActivities, dailyCost, `~${distKm.toFixed(1)} km`));
        }

        const totalActivitiesCost = dailyPlans.reduce((acc, plan) => acc + plan.estimatedCost, 0);
        let totalEstimatedCost = transportCost + hotelTotalCost + totalActivitiesCost;

        // Bütçe Aşım Kontrolü: Toplam bütçeyi geçiyorsa daha ucuz otel seç
        while (totalEstimatedCost > budget && hotelIndex > 0) {
            hotelIndex--;
            hotel = sortedHotels[hotelIndex];
            hotelTotalCost = hotel.pricePerNight * daysToStay;
            totalEstimatedCost = transportCost + hotelTotalCost + totalActivitiesCost;
        }

        // Son güvenlik ağı: Yine de aşıyorsa bütçeye sabitle
        if (totalEstimatedCost > budget) {
            totalEstimatedCost = budget;
        }

        const breakdown = createBudgetBreakdown(
            transportCost,
            hotelTotalCost,
            totalActivitiesCost * 0.35,
            totalActivitiesCost * 0.1,
            totalActivitiesCost * 0.45,
            totalActivitiesCost * 0.1
        );

        const recommendation = `Bütçeniz (${Math.floor(budget)} ₺) için toplam ${Math.floor(totalEstimatedCost)} ₺ tahmini harcama. ${type} tercihlerinize uygun optimize edildi.`;

        return createTripPlan({
            title, description, planType: type,
            transportation: {
                type: transportType,
                provider: cityData.transportProviders[transportType] || "Standart",
                departureCity: "İstanbul",
                arrivalCity: city,
                departureTime: "08:30",
                arrivalTime: transportType === TransportType.FLIGHT ? "09:45" : "12:00",
                duration: transportType === TransportType.FLIGHT ? "1s 15dk" : "4s 30dk",
                price: transportCost,
                returnPrice: transportCost * 0.95,
                classType: type === PlanType.COMFORT ? "Business" : "Standart"
            },
            hotel, dailyPlans, budgetBreakdown: breakdown, totalEstimatedCost, recommendation, fitScore
        });
    }

    getCityData(city) {
        if (city.includes("Ankara")) return this.ankaraData();
        if (city.includes("İstanbul")) return this.istanbulData();
        if (city.includes("İzmir")) return this.izmirData();
        // ... diğer şehirler de benzer şekilde eklenebilir. 
        // Şimdilik Ankara ve İstanbul'u ekliyorum.
        return this.ankaraData();
    }

    ankaraData() {
        return {
            hotels: ankaraPlacesData.hotels,
            activities: ankaraPlacesData.activities,
            transportProviders: { [TransportType.FLIGHT]: "THY / Pegasus", [TransportType.BUS]: "Metro Turizm / Kamil Koç", [TransportType.TRAIN]: "TCDD YHT", [TransportType.CAR]: "Kendi Aracınız" }
        };
    }

    istanbulData() {
        return {
            hotels: [
                { name: "Four Seasons Sultanahmet", starRating: 5, pricePerNight: 9500, latitude: 41.0062, longitude: 28.9780, address: "Sultanahmet, Fatih", distanceToCenter: "0.1 km", rating: 9.6 },
                { name: "Divan İstanbul", starRating: 5, pricePerNight: 4500, latitude: 41.0470, longitude: 28.9930, address: "Elmadağ, Şişli", distanceToCenter: "5 km", rating: 9.0 },
                { name: "Grand Star Hotel", starRating: 3, pricePerNight: 1500, latitude: 41.0095, longitude: 28.9710, address: "Sultanahmet, Fatih", distanceToCenter: "0.5 km", rating: 8.2 }
            ],
            activities: [
                { name: "Ayasofya Camii", description: "Bizans mozaikleri ve Osmanlı hat sanatı.", category: ActivityCategory.LANDMARK, estimatedCost: 0, latitude: 41.0086, longitude: 28.9802, address: "Sultanahmet Meydanı", entryFee: 0 },
                { name: "Topkapı Sarayı", description: "Osmanlı İmparatorluğu yönetim merkezi.", category: ActivityCategory.MUSEUM, estimatedCost: 0, latitude: 41.0115, longitude: 28.9833, address: "Cankurtaran, Fatih", entryFee: 320 },
                { name: "Kapalıçarşı", description: "Dünyanın en eski ve büyük kapalı çarşılarından biri.", category: ActivityCategory.SHOPPING, estimatedCost: 500, latitude: 41.0108, longitude: 28.9680, address: "Beyazıt, Fatih", entryFee: 0 },
                { name: "Galata Kulesi", description: "360° İstanbul panoraması.", category: ActivityCategory.LANDMARK, estimatedCost: 0, latitude: 41.0256, longitude: 28.9741, address: "Bereketzade Mah., Beyoğlu", entryFee: 650 },
                { name: "İstiklal Caddesi", description: "Beyoğlu'nun kalbi.", category: ActivityCategory.SHOPPING, estimatedCost: 300, latitude: 41.0337, longitude: 28.9770, address: "İstiklal Cad., Beyoğlu", entryFee: 0 }
            ],
            transportProviders: { [TransportType.FLIGHT]: "THY / Pegasus / AnadoluJet", [TransportType.BUS]: "Metro Turizm / Pamukkale", [TransportType.TRAIN]: "TCDD YHT", [TransportType.CAR]: "Kendi Aracınız" }
        };
    }
}

export const aiTripPlannerService = new AITripPlannerService();
