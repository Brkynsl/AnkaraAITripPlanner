// MARK: - ServiceProtocols.swift
// Amaç: Servis katmanı için protocol tanımlarını içerir.
// Açıklama: Protocol-oriented programming (POP) yaklaşımıyla servislerin
//           soyut arayüzlerini tanımlar. Bu sayede gerçek API servisleri ile
//           mock (sahte) servisleri birbirinin yerine kullanabiliriz.
//           Test edilebilirlik ve modülerlik için kritik bir tasarım kararıdır.
//           Aşama 2'de ulaşım, otel, restoran servisleri bu protocol'leri uygulayacak.

import Foundation
import CoreLocation

// MARK: - Auth Servis Protokolü
// Firebase Auth işlemlerinin soyut arayüzü.
// Test ortamında MockAuthService yazılabilir.
protocol AuthServiceProtocol {
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<AppUser, Error>) -> Void)
    func signUpWithEmail(email: String, password: String, displayName: String, completion: @escaping (Result<AppUser, Error>) -> Void)
    func signInWithApple(idToken: String, nonce: String, completion: @escaping (Result<AppUser, Error>) -> Void)
    func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<AppUser, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() throws
    var currentUserId: String? { get }
    var isLoggedIn: Bool { get }
}

// MARK: - Firestore Servis Protokolü
// Firestore CRUD işlemlerinin soyut arayüzü.
protocol FirestoreServiceProtocol {
    func saveUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void)
    func getUser(uid: String, completion: @escaping (Result<AppUser, Error>) -> Void)
    func updateUser(uid: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    func saveTrip(_ trip: Trip, completion: @escaping (Result<String, Error>) -> Void)
    func getTrips(userId: String, completion: @escaping (Result<[Trip], Error>) -> Void)
    func updateOnboardingStatus(uid: String, completed: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func savePreferences(uid: String, preferences: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void)
    func getPreferences(uid: String, completion: @escaping (Result<UserPreferences, Error>) -> Void)
}

// MARK: - Ulaşım Servis Protokolü
// Şehirler arası ulaşım verilerini sağlayan servisin arayüzü.
// Aşama 2'de gerçek API veya mock veriyle implement edilecek.
protocol TransportationServiceProtocol {
    func searchTransportation(
        from: String,
        to: String,
        date: Date,
        completion: @escaping (Result<[Transportation], Error>) -> Void
    )
}

// MARK: - Otel Servis Protokolü
protocol HotelServiceProtocol {
    func searchHotels(
        city: String,
        checkIn: Date,
        checkOut: Date,
        maxBudget: Double?,
        completion: @escaping (Result<[Hotel], Error>) -> Void
    )
}

// MARK: - Gezi Noktası Servis Protokolü
protocol AttractionServiceProtocol {
    func getAttractions(
        city: String,
        categories: [ActivityCategory]?,
        completion: @escaping (Result<[Attraction], Error>) -> Void
    )
}

// MARK: - Restoran Servis Protokolü
protocol RestaurantServiceProtocol {
    func searchRestaurants(
        city: String,
        priceRange: PriceRange?,
        cuisineType: String?,
        completion: @escaping (Result<[Restaurant], Error>) -> Void
    )
}

// MARK: - AI Planlama Servis Protokolü
// Trip planning motorunun arayüzü.
protocol TripPlanningServiceProtocol {
    func generatePlans(
        city: String,
        days: Int,
        budget: Double,
        preferences: UserPreferences?,
        completion: @escaping (Result<[TripPlan], Error>) -> Void
    )
}
