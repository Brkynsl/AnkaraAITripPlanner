const fs = require('fs');
const path = require('path');
const vm = require('vm');

console.log("✈️  AI Trip Planner Algoritma Test Aracına Hoş Geldiniz! ✈️\n");

try {
    // Models.js ve AITripPlannerService.js dosyalarını okuyoruz
    const modelsCode = fs.readFileSync(path.join(__dirname, 'Models.js'), 'utf-8');
    const serviceCode = fs.readFileSync(path.join(__dirname, 'AITripPlannerService.js'), 'utf-8');
    const dataPath = path.join(__dirname, 'data', 'ankara_places.json');
    const placesData = require(dataPath);

    // ES6 Import/Export komutlarını Node.js CommonJS yapısına (require/module.exports) çeviriyoruz
    // (Böylece React Native projesini bozmadan saf Node.js ile test edebileceğiz)
    
    let compiledModels = modelsCode
        .replace(/export class/g, 'class')
        .replace(/export const/g, 'const')
        .replace(/export function/g, 'function')
        + '\n\nmodule.exports = { ActivityCategory, PlanType, TransportType, createBudgetBreakdown, createDayPlan, createTripPlan };';

    let compiledService = serviceCode
        .replace(/import {([^}]+)} from '\.\/Models';/g, 'const {$1} = Models;')
        .replace(/import ([a-zA-Z0-9_]+) from '\.\/data\/ankara_places\.json';/g, 'const $1 = globalPlacesData;')
        .replace(/export const aiTripPlannerService/g, 'const aiTripPlannerService')
        .replace(/export class/g, 'class')
        + '\n\nmodule.exports = { aiTripPlannerService, AITripPlannerService };';

    // Sanal bir Node.js modül ortamı oluşturuyoruz
    const sandbox = {
        require: require,
        console: console,
        Math: Math,
        Promise: Promise,
        setTimeout: setTimeout,
        module: { exports: {} },
        exports: {}
    };
    vm.createContext(sandbox);

    // 1. Models.js'i çalıştır
    vm.runInContext(compiledModels, sandbox);
    const Models = sandbox.module.exports;

    // 2. AITripPlannerService.js için yeni ve temiz bir ortam oluştur (Çakışmaları önlemek için)
    const sandbox2 = {
        require: require,
        console: console,
        Math: Math,
        Promise: Promise,
        setTimeout: setTimeout,
        module: { exports: {} },
        exports: {},
        Models: Models,
        globalPlacesData: placesData
    };
    vm.createContext(sandbox2);
    
    vm.runInContext(compiledService, sandbox2);
    const { aiTripPlannerService } = sandbox2.module.exports;

    // ----- TEST SENARYOSU ----- //
    const testCity = "Ankara";
    const testDays = 4;
    const testBudget = 10000;

    console.log(`🔍 TEST SENARYOSU: ${testCity} | ${testDays} Gün | ${testBudget} TL Bütçe`);
    console.log("Algoritma çalışıyor, rotalar optimize ediliyor...\n");

    aiTripPlannerService.generateTripPlans(testCity, testDays, testBudget).then(plans => {
        plans.forEach((plan, index) => {
            console.log(`========================================================`);
            console.log(`🏆 PLAN ${index + 1}: ${plan.title} (${plan.planType})`);
            console.log(`========================================================`);
            console.log(`🏨 Seçilen Otel: ${plan.hotel.name}`);
            console.log(`⭐ Otel Kalitesi: ${plan.hotel.rating || plan.hotel.starRating || 3.5} Yıldız / Puan`);
            console.log(`💰 Gecelik Fiyat: ${plan.hotel.pricePerNight} TL`);
            console.log(`🚌 Ulaşım: ${plan.transportation.provider} (${plan.transportation.type}) - ${plan.transportation.price} TL`);
            console.log(`--------------------------------------------------------`);
            console.log(`💵 TOPLAM MALİYET: ${Math.floor(plan.totalEstimatedCost)} TL`);
            console.log(`--------------------------------------------------------`);
            
            // İlk günün rotasını örnek olarak yazdır
            const day1 = plan.dailyPlans[0];
            console.log(`📍 ÖRNEK GÜN 1 ROTASI (${day1.title}):`);
            day1.activities.forEach((act, i) => {
                const isMeal = act.category === "Yemek" ? "🍽️ " : (act.category === "Alışveriş ve Eğlence" ? "🛍️ " : "🏛️ ");
                console.log(`  ${i+1}. [${act.startTime}] ${isMeal}${act.name} (${act.estimatedCost + (act.entryFee || 0)} TL)`);
                if (act.transportInfo) {
                    console.log(`      └─ Ulaşım: ${act.transportInfo} (${act.transportCost} TL)`);
                }
            });
            console.log("\n");
        });
        
        console.log("✅ Algoritma Testi Başarıyla Tamamlandı!");
        console.log("Hocalarınıza sunum yaparken 'testBudget' ve 'testDays' değişkenlerini değiştirip anında sonuç alabilirsiniz.");
    });

} catch (error) {
    console.error("Test sırasında bir hata oluştu:", error);
}
