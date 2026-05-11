// NetworkManager.js
// JavaScript fetch API tabanlı generic networking katmanı

export const NetworkError = {
    INVALID_URL: "Geçersiz URL.",
    NO_INTERNET_CONNECTION: "İnternet bağlantısı yok.",
    TIMEOUT: "İstek zaman aşımına uğradı.",
    UNAUTHORIZED: "Yetkisiz erişim (401).",
    NOT_FOUND: "Sayfa bulunamadı (404).",
    RATE_LIMITED: "Çok fazla istek yapıldı (429).",
    SERVER_ERROR: "Sunucu hatası.",
    NO_DATA: "Veri alınamadı.",
    DECODING_FAILED: "Veri işlenemedi (JSON parse hatası).",
    UNKNOWN: "Bilinmeyen bir hata oluştu."
};

class NetworkManager {
    constructor() {
        this.timeoutDuration = 30000; // 30 saniye
    }

    // Fetch API üzerinde timeout uygulayan yardımcı fonksiyon
    async fetchWithTimeout(resource, options = {}) {
        const { timeout = this.timeoutDuration } = options;
        
        const controller = new AbortController();
        const id = setTimeout(() => controller.abort(), timeout);
        const response = await fetch(resource, {
            ...options,
            signal: controller.signal  
        });
        clearTimeout(id);
        return response;
    }

    // GET isteği
    async request(url) {
        try {
            const response = await this.fetchWithTimeout(url, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            });

            return await this.handleResponse(response);
        } catch (error) {
            return this.handleError(error);
        }
    }

    // POST isteği
    async post(url, body) {
        try {
            const response = await this.fetchWithTimeout(url, {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(body)
            });

            return await this.handleResponse(response);
        } catch (error) {
            return this.handleError(error);
        }
    }

    // HTTP Yanıtlarını kontrol eder
    async handleResponse(response) {
        if (!response.ok) {
            switch (response.status) {
                case 401: throw new Error(NetworkError.UNAUTHORIZED);
                case 404: throw new Error(NetworkError.NOT_FOUND);
                case 429: throw new Error(NetworkError.RATE_LIMITED);
                default: throw new Error(`${NetworkError.SERVER_ERROR} (${response.status})`);
            }
        }

        try {
            const data = await response.json();
            return data;
        } catch (error) {
            throw new Error(NetworkError.DECODING_FAILED);
        }
    }

    // Fetch hatalarını yakalar
    handleError(error) {
        if (error.name === 'AbortError') {
            throw new Error(NetworkError.TIMEOUT);
        } else if (error.message === 'Failed to fetch') {
            throw new Error(NetworkError.NO_INTERNET_CONNECTION);
        } else {
            throw error;
        }
    }
}

export const networkManager = new NetworkManager();
