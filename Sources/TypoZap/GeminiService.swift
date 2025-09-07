import Foundation
import Security

class GeminiService {
    
    // MARK: - Properties
    private let keychainService = "com.typozap.gemini"
    private let keychainAccount = "api_key"
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    private let tonesData: [ToneData]
    
    // MARK: - Initialization
    init() {
        // Load tones from tones.json
        self.tonesData = GeminiService.loadTonesFromBundle()
    }
    
    // MARK: - API Key Management
    func hasValidAPIKey() -> Bool {
        return getAPIKey() != nil
    }
    
    func setAPIKey(_ apiKey: String) {
        saveAPIKeyToKeychain(apiKey)
    }
    
    private func getAPIKey() -> String? {
        return getAPIKeyFromKeychain()
    }
    
    // MARK: - Keychain Operations
    private func saveAPIKeyToKeychain(_ apiKey: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: apiKey.data(using: .utf8)!
        ]
        
        // Delete existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving API key to keychain: \(status)")
        }
    }
    
    private func getAPIKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return nil
    }
    
    // MARK: - Tone Management
    func getAvailableTones() -> [ToneData] {
        return tonesData
    }
    
    func getToneByTitle(_ title: String) -> ToneData? {
        return tonesData.first { $0.title == title }
    }
    
    private static func loadTonesFromBundle() -> [ToneData] {
        guard let path = Bundle.main.path(forResource: "tones", ofType: "json"),
              let data = NSData(contentsOfFile: path),
              let json = try? JSONSerialization.jsonObject(with: data as Data) as? [String: Any],
              let tonesArray = json["tones"] as? [[String: String]] else {
            print("⚠️ Could not load tones.json, using default tone")
            return [ToneData(title: "default", description: "Corrects grammar, spelling, and punctuation without changing the tone or meaning of the text.", prompt: "Please correct the grammar, spelling, and punctuation in the following text. Return only the corrected text without any explanations or additional formatting:\n{text}")]
        }
        
        return tonesArray.compactMap { toneDict in
            guard let title = toneDict["title"],
                  let description = toneDict["description"],
                  let prompt = toneDict["prompt"] else { return nil }
            return ToneData(title: title, description: description, prompt: prompt)
        }
    }
    
    // MARK: - Grammar Correction
    func correctGrammar(text: String, tone: String = "default", completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = getAPIKey() else {
            print("❌ No API key found")
            completion(.failure(GeminiError.noAPIKey))
            return
        }
        
        print("🔑 Using API key: \(String(apiKey.prefix(10)))...")
        print("📝 Text to correct: \(text)")
        print("🎭 Using tone: \(tone)")
        
        // Get the tone-specific prompt
        let toneData = getToneByTitle(tone) ?? tonesData.first!
        let prompt = toneData.prompt.replacingOccurrences(of: "{text}", with: text)
        
        print("📝 Using prompt: \(prompt)")
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: prompt)
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.1,
                topK: 1,
                topP: 0.8,
                maxOutputTokens: 1024
            )
        )
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(GeminiError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-goog-api-key")
        
        do {
            let requestData = try JSONEncoder().encode(requestBody)
            request.httpBody = requestData
            
            // Log the request details
            print("📤 API Request Details:")
            print("   - URL: \(url)")
            print("   - Method: \(request.httpMethod ?? "unknown")")
            print("   - Headers: \(request.allHTTPHeaderFields ?? [:])")
            if let requestString = String(data: requestData, encoding: .utf8) {
                print("   - Request Body: \(requestString)")
            }
        } catch {
            print("❌ Failed to encode request: \(error)")
            completion(.failure(error))
            return
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            // Log HTTP response details
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                print("📡 HTTP Headers: \(httpResponse.allHeaderFields)")
                
                // Check for HTTP errors
                if httpResponse.statusCode != 200 {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    completion(.failure(GeminiError.httpError(httpResponse.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                print("❌ No data received from API")
                completion(.failure(GeminiError.noData))
                return
            }
            
            // Log the raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw API Response: \(responseString)")
            }
            
            do {
                let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
                
                if let text = response.candidates?.first?.content?.parts?.first?.text {
                    let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    print("✅ Successfully extracted text: \(cleanedText)")
                    completion(.success(cleanedText))
                } else {
                    print("❌ Invalid response structure:")
                    print("   - Candidates: \(response.candidates?.count ?? 0)")
                    print("   - First candidate content: \(response.candidates?.first?.content != nil)")
                    print("   - First candidate parts: \(response.candidates?.first?.content?.parts?.count ?? 0)")
                    print("   - First part text: \(response.candidates?.first?.content?.parts?.first?.text ?? "nil")")
                    completion(.failure(GeminiError.invalidResponse))
                }
            } catch {
                print("❌ JSON Decoding error: \(error)")
                print("❌ Failed to decode response as GeminiResponse")
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Request/Response Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]?
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let topK: Int
    let topP: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent?
}

// MARK: - Tone Data Structure
struct ToneData {
    let title: String
    let description: String
    let prompt: String
}

// MARK: - Errors
enum GeminiError: LocalizedError {
    case noAPIKey
    case invalidURL
    case noData
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key found. Please set your Gemini API key."
        case .invalidURL:
            return "Invalid URL for API request."
        case .noData:
            return "No data received from API."
        case .invalidResponse:
            return "Invalid response structure from API. Check console for details."
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode). Check console for response details."
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}
