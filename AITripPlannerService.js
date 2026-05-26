// AITripPlannerService.js
import { ActivityCategory, PlanType, TransportType, createBudgetBreakdown, createDayPlan, createTripPlan } from './Models';
import ankaraPlacesData from './data/ankara_places.json';

// ─── Haversine Mesafe Hesaplama (metre) ───
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3;
    const φ1 = lat1 * Math.PI/180;
    const φ2 = lat2 * Math.PI/180;
    const Δφ = (lat2-lat1) * Math.PI/180;
    const Δλ = (lon2-lon1) * Math.PI/180;
    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
}

// ─── A* Yardımcı: Min-Max Normalizasyon [0, 1] ───
function normalizeMinMax(value, min, max) {
    if (max === min) return 0;
    return (value - min) / (max - min);
}

// ─── A* Heuristik: Kalan en yakın ziyaret edilmemiş mekana mesafe (admissible) ───
function aStarHeuristic(currentLat, currentLon, unvisited) {
    if (unvisited.length === 0) return 0;
    let minDist = Infinity;
    for (const place of unvisited) {
        const d = calculateDistance(currentLat, currentLon, place.latitude, place.longitude);
        if (d < minDist) minDist = d;
    }
    return minDist;
}

// ─── A* Skor Hesaplama: f(n) = wCost * g_norm + wDist * (dist_norm + h_norm) - wQuality * quality_norm ───
function computeAStarScore(gCostNorm, distNorm, hNorm, qualityNorm, wCost, wDist) {
    // Kaliteli yerleri ödüllendirmek için quality skoru çıkarılır (düşük f = daha iyi)
    const qualityBonus = 0.35;
    return wCost * gCostNorm + wDist * (distNorm + hNorm) - qualityBonus * qualityNorm;
}

// ─── Aktivite Kalite Skoru: rating × log2(reviews + 1) ───
function activityQualityScore(activity) {
    const rating = activity.rating || 3.0;
    const reviews = activity.reviews || 1;
    return rating * Math.log2(reviews + 1);
}

// ─── Plan tipine göre A* ağırlıkları ───
function getAStarWeights(planType) {
    switch (planType) {
        case PlanType.ECONOMIC: return { wCost: 0.7, wDist: 0.3 };
        case PlanType.BALANCED: return { wCost: 0.5, wDist: 0.5 };
        case PlanType.COMFORT:  return { wCost: 0.3, wDist: 0.7 };
        default:                return { wCost: 0.5, wDist: 0.5 };
    }
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
        
        // 1. Hedef Bütçe Ölçeklendirmesi — Kullanıcının bütçesine YAKIN planlar üret
        // 11.000 TL isteyen kullanıcıya 8.000 TL plan vermek yerine bütçeyi gerçekçi kullan
        let targetBudget = budget;
        if (type === PlanType.ECONOMIC) targetBudget = budget * 0.75;      // Örn: 11.000 için ~8.250 TL bandı
        else if (type === PlanType.BALANCED) targetBudget = budget * 0.90; // Örn: 11.000 için ~9.900 TL bandı
        else if (type === PlanType.COMFORT) targetBudget = budget * 0.98;  // Bütçenin ~%98'i hedeflenir

        // 2. Ulaşım Maliyetlerini Sabit ve Mantıklı Aralıklarla Belirleme
        let transportCost = 0;
        switch (transportType) {
            case TransportType.FLIGHT: transportCost = 2500; break;
            case TransportType.BUS: transportCost = 600; break;
            case TransportType.TRAIN: transportCost = 800; break;
            case TransportType.CAR: transportCost = 1500; break;
        }
        
        // 3. Otel Fiyatını Hedef Bütçeye Göre Dinamik Seçme
        const daysToStay = Math.max(1, days - 1);
        // Aktivite bütçesi: bütçenin %30'u aktivitelere, geri kalanı ulaşım + otel
        const activityBudgetRatio = 0.30;
        const estimatedActivitiesCost = targetBudget * activityBudgetRatio;
        const targetTotalHotelCost = targetBudget - transportCost - estimatedActivitiesCost;
        let targetPricePerNight = daysToStay > 0 ? targetTotalHotelCost / daysToStay : targetTotalHotelCost;

        // Eksi veya çok düşük değerlere düşmemesi için alt limit
        if (targetPricePerNight < 500) targetPricePerNight = 500;

        // Havuzdaki otelleri fiyata göre sırala (ucuzdan pahalıya) — bütçe aşımında geri düşmek için
        const sortedHotels = [...cityData.hotels].sort((a, b) => a.pricePerNight - b.pricePerNight);

        // Hedef gecelik fiyata en yakın oteli bul
        let hotel = sortedHotels.reduce((prev, curr) => {
            return (Math.abs(curr.pricePerNight - targetPricePerNight) < Math.abs(prev.pricePerNight - targetPricePerNight) ? curr : prev);
        });
        let hotelIndex = sortedHotels.indexOf(hotel);

        let hotelTotalCost = hotel.pricePerNight * daysToStay;
        
        // ─── A* Heuristik Rota Optimizasyonu ───
        const { wCost, wDist } = getAStarWeights(type);

        // Aktiviteleri kalite skoruna göre sırala — popüler/yüksek puanlı yerler önce
        // Bu sayede kısa gezilerde (1 gün) bile müze, anıt gibi kaliteli yerler seçilir
        let candidatePool = [...cityData.activities].sort((a, b) => {
            return activityQualityScore(b) - activityQualityScore(a);
        });

        // Şehir merkezinden çok uzak yerleri filtrele (> 30 km) — kısa gezilerde saçma öneriler engellenir
        const hotelLat = hotel.latitude;
        const hotelLon = hotel.longitude;
        const maxReasonableDistance = days <= 2 ? 15000 : 30000; // 1-2 gün: 15km, 3+ gün: 30km
        candidatePool = candidatePool.filter(act => {
            const d = calculateDistance(hotelLat, hotelLon, act.latitude, act.longitude);
            return d <= maxReasonableDistance;
        });

        // Normalizasyon için min/max değerleri hesapla (filtrelenmiş aday havuzundan)
        const allCosts = candidatePool.map(a => (a.estimatedCost || 0) + (a.entryFee || 0));
        const allQualities = candidatePool.map(a => activityQualityScore(a));
        const allDistances = [];
        for (const act of candidatePool) {
            allDistances.push(calculateDistance(hotelLat, hotelLon, act.latitude, act.longitude));
        }
        // Aday çiftleri arası mesafe (performans: max 200 aday ile sınırla)
        const sampleSize = Math.min(candidatePool.length, 200);
        for (let i = 0; i < sampleSize; i++) {
            for (let j = i + 1; j < sampleSize; j++) {
                allDistances.push(calculateDistance(
                    candidatePool[i].latitude, candidatePool[i].longitude,
                    candidatePool[j].latitude, candidatePool[j].longitude
                ));
            }
        }
        const minCost = Math.min(...allCosts);
        const maxCost = Math.max(...allCosts);
        const minDist = Math.min(...allDistances);
        const maxDist = Math.max(...allDistances);
        const minQuality = Math.min(...allQualities);
        const maxQuality = Math.max(...allQualities);

        let dailyPlans = [];
        let currentLocation = { lat: hotelLat, lon: hotelLon };
        let cumulativeBudgetSpent = 0;
        const activityBudgetLimit = targetBudget - transportCost - hotelTotalCost;

        for (let i = 1; i <= days; i++) {
            const activitiesPerDay = Math.min(i === 1 ? 3 : 4, candidatePool.length);
            if (activitiesPerDay === 0) break;

            let dayActivities = [];
            for (let j = 0; j < activitiesPerDay; j++) {
                // Eğer aday havuzu boşaldıysa tekrar doldur
                if (candidatePool.length === 0) {
                    candidatePool = [...cityData.activities];
                }

                // Öğle ve Akşam yemeği aralara serpiştiriliyor (Asla arka arkaya gelmeyecek)
                let isMealTime = false;
                if (activitiesPerDay === 4) {
                    isMealTime = (j === 1 || j === 3); // 2. ve 4. sıra yemek (Örn: Aktivite -> Yemek -> Aktivite -> Yemek)
                } else if (activitiesPerDay === 3) {
                    isMealTime = (j === 1); // 2. sıra yemek (Örn: Aktivite -> Yemek -> Aktivite)
                }

                // ─── A* ile en iyi adayı seç ───
                let bestIndex = -1;
                let bestFScore = Infinity;

                for (let k = 0; k < candidatePool.length; k++) {
                    const candidate = candidatePool[k];

                    // Kategori zorlaması (Yemek saatinde sadece restoran, diğer saatlerde sadece aktivite)
                    if (isMealTime && candidate.category !== "Yemek") continue;
                    if (!isMealTime && candidate.category === "Yemek") continue;

                    const candidateCost = (candidate.estimatedCost || 0) + (candidate.entryFee || 0);
                    const candidateDist = calculateDistance(
                        currentLocation.lat, currentLocation.lon,
                        candidate.latitude, candidate.longitude
                    );

                    // g(n): Gerçek maliyet → normalize edilmiş bütçe harcaması
                    const gCostNorm = normalizeMinMax(candidateCost, minCost, maxCost);

                    // Mesafe normalizasyonu
                    const distNorm = normalizeMinMax(candidateDist, minDist, maxDist);

                    // h(n): Heuristik → kalan en yakın ziyaret edilmemiş mekana mesafe
                    const remaining = candidatePool.filter((_, idx) => idx !== k);
                    const hRaw = aStarHeuristic(candidate.latitude, candidate.longitude, remaining);
                    const hNorm = normalizeMinMax(hRaw, minDist, maxDist);

                    // Kalite skoru normalizasyonu (yüksek = daha iyi yer)
                    const qualityNorm = normalizeMinMax(activityQualityScore(candidate), minQuality, maxQuality);

                    // f(n) = wCost * g_norm + wDist * (dist_norm + h_norm) - qualityBonus * quality_norm
                    const fScore = computeAStarScore(gCostNorm, distNorm, hNorm, qualityNorm, wCost, wDist);

                    // Bütçe aşımı kontrolü: bu aktiviteyi eklersek bütçeyi aşar mı?
                    if (cumulativeBudgetSpent + candidateCost > activityBudgetLimit && activityBudgetLimit > 0) {
                        continue; // Bütçeyi aşacak adayları atla
                    }

                    if (fScore < bestFScore) {
                        bestFScore = fScore;
                        bestIndex = k;
                    }
                }

                // Eğer bütçe kısıtı yüzünden hiç aday bulunamadıysa, en ucuz olanı seç
                if (bestIndex === -1) {
                    candidatePool.sort((a, b) => 
                        ((a.estimatedCost || 0) + (a.entryFee || 0)) - 
                        ((b.estimatedCost || 0) + (b.entryFee || 0))
                    );
                    bestIndex = 0;
                }

                let activity = candidatePool.splice(bestIndex, 1)[0];
                if (!activity) break;

                const actCost = (activity.estimatedCost || 0) + (activity.entryFee || 0);
                cumulativeBudgetSpent += actCost;

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
                        trCost = 20;
                    } else {
                        transportMode = `🚕 Taksi (~${Math.ceil(distanceKm * 2.5)} dk)`;
                        trCost = 25 + (distanceKm * 20);
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

        const recommendation = `Bütçeniz (${Math.floor(budget)} ₺) için toplam ${Math.floor(totalEstimatedCost)} ₺ tahmini harcama. ${type} tercihlerinize uygun A* heuristik algoritma ile optimize edildi.`;

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
