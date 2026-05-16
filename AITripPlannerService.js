// AITripPlannerService.js
import { ActivityCategory, PlanType, TransportType, createBudgetBreakdown, createDayPlan, createTripPlan } from './Models';

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
        let hotel;
        if (hotelTier === 'budget') {
            hotel = cityData.hotels[cityData.hotels.length - 1] || cityData.hotels[0];
        } else if (hotelTier === 'mid') {
            hotel = cityData.hotels.length > 1 ? cityData.hotels[1] : cityData.hotels[0];
        } else {
            hotel = cityData.hotels[0];
        }

        let transportCost = 0;
        switch (transportType) {
            case TransportType.FLIGHT: transportCost = Math.random() * (3500 - 1800) + 1800; break;
            case TransportType.BUS: transportCost = Math.random() * (950 - 450) + 450; break;
            case TransportType.TRAIN: transportCost = Math.random() * (700 - 300) + 300; break;
            case TransportType.CAR: transportCost = Math.random() * (2500 - 1200) + 1200; break;
        }

        const hotelTotalCost = hotel.pricePerNight * Math.max(1, days - 1);
        
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
        const totalEstimatedCost = transportCost + hotelTotalCost + totalActivitiesCost;

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
            hotels: [
                { name: "JW Marriott Ankara", starRating: 5, pricePerNight: 4200, latitude: 39.9075, longitude: 32.8630, address: "Kavaklıdere Mah., Çankaya", distanceToCenter: "3 km", amenities: ["WiFi", "Havuz", "Spa", "Fitness", "Restoran"], rating: 9.3 },
                { name: "Divan Çukurhan", starRating: 5, pricePerNight: 3200, latitude: 39.9395, longitude: 32.8630, address: "Necatibey Cad., Ulus", distanceToCenter: "0.3 km", amenities: ["WiFi", "Tarihi Bina", "Restoran", "Bar"], rating: 9.5 },
                { name: "Ibis Ankara Kızılay", starRating: 3, pricePerNight: 1200, latitude: 39.9208, longitude: 32.8543, address: "Kızılay, Çankaya", distanceToCenter: "1 km", amenities: ["WiFi", "Kahvaltı", "Klima"], rating: 8.1 },
                { name: "Otel Mithat", starRating: 2, pricePerNight: 650, latitude: 39.9178, longitude: 32.8610, address: "Kızılay, Çankaya", distanceToCenter: "0.8 km", amenities: ["WiFi", "Kahvaltı"], rating: 7.2 }
            ],
            activities: [
                { name: "Anıtkabir", description: "Mustafa Kemal Atatürk'ün anıt mezarı.", category: ActivityCategory.LANDMARK, estimatedCost: 0, latitude: 39.9254, longitude: 32.8369, address: "Anıt Cad., Tandoğan", entryFee: 0 },
                { name: "Ankara Kalesi", description: "Roma döneminden kalma tarihi kale.", category: ActivityCategory.LANDMARK, estimatedCost: 0, latitude: 39.9408, longitude: 32.8642, address: "Kale Mah., Altındağ", entryFee: 0 },
                { name: "Anadolu Medeniyetleri Müzesi", description: "Dünya'nın en zengin arkeoloji müzelerinden biri.", category: ActivityCategory.MUSEUM, estimatedCost: 0, latitude: 39.9380, longitude: 32.8590, address: "Gözcü Sok. No:2, Ulus", entryFee: 120 },
                { name: "Hamamönü Tarihi Bölge", description: "Restore edilmiş Osmanlı evleri.", category: ActivityCategory.SHOPPING, estimatedCost: 200, latitude: 39.9366, longitude: 32.8674, address: "Hamamönü Sok., Altındağ", entryFee: 0 },
                { name: "Tunalı Hilmi Caddesi", description: "Ankara'nın popüler alışveriş ve eğlence caddesi.", category: ActivityCategory.SHOPPING, estimatedCost: 300, latitude: 39.9072, longitude: 32.8612, address: "Tunalı Hilmi Cad., Kavaklıdere", entryFee: 0 },
                { name: "Kuğulu Park", description: "Ankara'nın simgesi olan kuğuların yaşadığı park.", category: ActivityCategory.PARK, estimatedCost: 0, latitude: 39.9046, longitude: 32.8606, address: "Kuğulu Park, Kavaklıdere", entryFee: 0 }
            ],
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
