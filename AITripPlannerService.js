// AITripPlannerService.js
import { ActivityCategory, PlanType, TransportType, createBudgetBreakdown, createDayPlan, createTripPlan } from './Models';
import ankaraPlacesData from './data/ankara_places.json';

// ─── Zaman Formatlama Yardımcı ───
function formatTime(totalMinutes) {
    const hours = Math.floor(totalMinutes / 60);
    const mins = totalMinutes % 60;
    return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
}

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
        
        // 1. Hedef Bütçe Ölçeklendirmesi — Plan tipine göre bütçe kullanımı
        // Eco: bütçenin %65'i, Dengeli: %80'i, Premium: tamamı
        let targetBudget = budget;
        if (type === PlanType.ECONOMIC) targetBudget = budget * 0.65;       // 20k → 13.000
        else if (type === PlanType.BALANCED) targetBudget = budget * 0.80;  // 20k → 16.000
        else if (type === PlanType.COMFORT) targetBudget = budget * 1.00;   // 20k → 20.000

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
        // Aktivite bütçesi: kısa tatillerde daha fazla aktiviteye harca
        const activityBudgetRatio = days <= 2 ? 0.45 : days <= 4 ? 0.38 : 0.30;
        const estimatedActivitiesCost = targetBudget * activityBudgetRatio;
        const targetTotalHotelCost = targetBudget - transportCost - estimatedActivitiesCost;
        let targetPricePerNight = daysToStay > 0 ? targetTotalHotelCost / daysToStay : targetTotalHotelCost;

        // Eksi veya çok düşük değerlere düşmemesi için alt limit
        if (targetPricePerNight < 500) targetPricePerNight = 500;

        // Havuzdaki otelleri fiyata göre sırala (ucuzdan pahalıya)
        const sortedHotels = [...cityData.hotels].sort((a, b) => a.pricePerNight - b.pricePerNight);

        // ─── Katmanlı Otel Havuzu ───
        // 3 planın aynı oteli seçmesini engellemek için oteller 3 fiyat dilimine bölünüyor.
        // Eko: en ucuz %33, Dengeli: ortanca %33, Premium: en pahalı %33
        const oneThird = Math.max(1, Math.floor(sortedHotels.length / 3));
        let tierHotels;
        if (type === PlanType.ECONOMIC) {
            tierHotels = sortedHotels.slice(0, oneThird);
        } else if (type === PlanType.BALANCED) {
            tierHotels = sortedHotels.slice(oneThird, oneThird * 2);
        } else {
            tierHotels = sortedHotels.slice(oneThird * 2);
        }

        // Kendi katmanı içinde hedef gecelik fiyata en yakın oteli bul
        let hotel = tierHotels.reduce((prev, curr) => {
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
            // Dinamik aktivite sayısı: kullanılabilir saatlere ve plan tipine göre
            // 09:00 - 22:00 = 13 saat, ortalama aktivite + yolculuk ~2.5 saat slot
            const availableHours = 13;
            const avgSlotHours = 2.5;
            const maxByTime = Math.floor(availableHours / avgSlotHours); // ~5

            let activitiesPerDay;
            if (type === PlanType.ECONOMIC) {
                activitiesPerDay = Math.min(maxByTime, 5, candidatePool.length);
            } else if (type === PlanType.BALANCED) {
                activitiesPerDay = Math.min(maxByTime + 1, 6, candidatePool.length);
            } else {
                activitiesPerDay = Math.min(maxByTime + 2, 7, candidatePool.length);
            }
            if (activitiesPerDay === 0) break;

            // Günün zaman sayacı (dakika cinsinden)
            let currentTimeMinutes = 540; // 09:00
            const MAX_END_MINUTES = 24 * 60; // 24:00 (gece yarısı)
            const TRAVEL_TIME_MINUTES = 30; // aktiviteler arası ortalama ulaşım

            let dayActivities = [];
            let shoppingCountToday = 0; // Günde en fazla 1 AVM/Alışveriş yeri
            let mosqueCountToday = 0;   // Günde en fazla 1 cami/türbe
            let mealCountToday = 0;     // Günde en fazla 1 restoran
            for (let j = 0; j < activitiesPerDay; j++) {
                // Eğer aday havuzu boşaldıysa tekrar doldur
                if (candidatePool.length === 0) {
                    candidatePool = [...cityData.activities];
                }

                // Günde sadece 1 yemek molası (2. sırada = öğle yemeği)
                let isMealTime = false;
                if (mealCountToday === 0) {
                    if (activitiesPerDay >= 5) {
                        isMealTime = (j === 2); // 3. sıra: Aktivite -> Aktivite -> Yemek -> Aktivite -> ...
                    } else if (activitiesPerDay === 4) {
                        isMealTime = (j === 2); // 3. sıra
                    } else if (activitiesPerDay === 3) {
                        isMealTime = (j === 1); // 2. sıra
                    }
                }

                // ─── A* ile Top-K Rastgele Seçim ───
                // En iyi 3 adayı bul, aralarından rastgele birini seç → her seferinde farklı rota!
                let topCandidates = []; // { index, fScore } dizisi

                for (let k = 0; k < candidatePool.length; k++) {
                    const candidate = candidatePool[k];

                    // Kategori zorlaması: Yemek saatinde sadece restoran
                    if (isMealTime && candidate.category !== "Yemek") continue;
                    if (!isMealTime && candidate.category === "Yemek") continue;

                    // ─── Yemek Katmanlaması ───
                    // Eko: Sadece ucuz lokantalar (≤500 TL)
                    // Dengeli: Orta segment restoranlar (≤750 TL)
                    // Premium: Tüm restoranlar dahil lüks (sınırsız)
                    if (isMealTime && candidate.category === "Yemek") {
                        const mealCost = (candidate.estimatedCost || 0) + (candidate.entryFee || 0);
                        if (type === PlanType.ECONOMIC && mealCost > 300) continue;   // sadece ucuz lokantalar
                        if (type === PlanType.BALANCED && mealCost > 600) continue;   // orta segment
                        // Premium: sınırsız — lüks dahil
                    }

                    const isShopping = candidate.category === "Alışveriş ve Eğlence";
                    const nameLower = candidate.name.toLowerCase();
                    const isMosque = nameLower.includes('cami') || nameLower.includes('türbe');

                    if (!isMealTime) {
                        // Günde en fazla 1 AVM
                        if (isShopping && shoppingCountToday >= 1) continue;
                        // Günde en fazla 1 Cami
                        if (isMosque && mosqueCountToday >= 1) continue;
                        // AVM ve Cami aynı gün olmasın (birbiriyle uyumsuz konseptler)
                        if ((isShopping && mosqueCountToday >= 1) || (isMosque && shoppingCountToday >= 1)) continue;
                    }

                    // Tarihi ve Kültürel / Doğa yerlerine öncelik bonusu
                    let priorityBonus = 0;
                    if (candidate.category === "Tarihi ve Kültürel") priorityBonus = 0.15;
                    else if (candidate.category === "Doğa ve Parklar") priorityBonus = 0.10;

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

                    // f(n) = wCost * g_norm + wDist * (dist_norm + h_norm) - qualityBonus * quality_norm - priorityBonus
                    const fScore = computeAStarScore(gCostNorm, distNorm, hNorm, qualityNorm, wCost, wDist) - priorityBonus;

                    // Top-3 listesine ekle (en düşük fScore = en iyi)
                    topCandidates.push({ index: k, fScore });
                    topCandidates.sort((a, b) => a.fScore - b.fScore);
                    if (topCandidates.length > 3) topCandidates.pop();
                }

                // Top-3 adaydan rastgele birini seç (her tıklamada farklı rota!)
                let bestIndex = -1;
                if (topCandidates.length > 0) {
                    const picked = topCandidates[Math.floor(Math.random() * topCandidates.length)];
                    bestIndex = picked.index;
                }

                // Hiç aday bulunamadıysa (isMealTime filtresi yüzünden olabilir), filtre olmadan en yakını seç
                if (bestIndex === -1) {
                    let fallbackBest = Infinity;
                    for (let k = 0; k < candidatePool.length; k++) {
                        const d = calculateDistance(currentLocation.lat, currentLocation.lon, candidatePool[k].latitude, candidatePool[k].longitude);
                        if (d < fallbackBest) { fallbackBest = d; bestIndex = k; }
                    }
                }

                let activity = candidatePool.splice(bestIndex, 1)[0];
                if (!activity) break;

                // Sayaçları güncelle
                if (activity.category === "Alışveriş ve Eğlence") shoppingCountToday++;
                if (activity.category === "Yemek") mealCountToday++;
                const actNameLower = activity.name.toLowerCase();
                if (actNameLower.includes('cami') || actNameLower.includes('türbe')) mosqueCountToday++;

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

                // Dinamik zaman çizelgesi: durationMinutes kullanarak 22:00'a kadar
                const duration = activity.durationMinutes || 120;
                if (currentTimeMinutes + duration > MAX_END_MINUTES) break; // Gün bitti

                activity = {
                    ...activity,
                    startTime: formatTime(currentTimeMinutes),
                    endTime: formatTime(currentTimeMinutes + duration),
                    transportInfo: `${distanceKm.toFixed(1)} km • ${transportMode}`,
                    transportCost: Math.floor(trCost)
                };

                currentTimeMinutes += duration + TRAVEL_TIME_MINUTES;

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
        const actualCost = transportCost + hotelTotalCost + totalActivitiesCost;

        // ─── Bütçe Sabitleme ───
        // Toplam maliyet HER ZAMAN hedef bütçeye eşit olacak.
        // Gerçek maliyetler (ulaşım+otel+giriş ücretleri) düşük kalırsa,
        // kalan bütçe yemek, eğlence ve günlük harcama olarak dağıtılır.
        let totalEstimatedCost = targetBudget;

        // Eğer gerçek maliyet hedefi aşıyorsa, oteli ucuzlatarak sığdır
        if (actualCost > targetBudget) {
            let tempCost = actualCost;
            while (tempCost > targetBudget && hotelIndex > 0) {
                hotelIndex--;
                hotel = sortedHotels[hotelIndex];
                hotelTotalCost = hotel.pricePerNight * daysToStay;
                tempCost = transportCost + hotelTotalCost + totalActivitiesCost;
            }
            totalEstimatedCost = Math.max(tempCost, targetBudget);
        }

        // Kalan bütçeyi yemek/eğlence/harcama olarak dağıt
        const remainingBudget = Math.max(0, totalEstimatedCost - actualCost);
        const foodBudget = totalActivitiesCost * 0.35 + remainingBudget * 0.45;      // Yemek
        const entertainmentBudget = totalActivitiesCost * 0.1 + remainingBudget * 0.20; // Eğlence
        const activitySpending = totalActivitiesCost * 0.45 + remainingBudget * 0.25;   // Aktivite harcama
        const otherBudget = totalActivitiesCost * 0.1 + remainingBudget * 0.10;         // Diğer

        const breakdown = createBudgetBreakdown(
            transportCost,
            hotelTotalCost,
            Math.floor(foodBudget),
            Math.floor(entertainmentBudget),
            Math.floor(activitySpending),
            Math.floor(otherBudget)
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
