import Foundation
import UIKit

class FeedbackService {
    static let shared = FeedbackService()
    
    private init() {}
    
    func submitFeedback(text: String) async throws {
        // Try Resend API first if API key is configured
        if !ResendConfig.apiKey.isEmpty {
            do {
                try await sendViaResendAPI(text: text)
                return
            } catch {
                print("⚠️ Resend API failed, falling back to mailto: \(error.localizedDescription)")
                // Fall through to mailto fallback
            }
        }
        
        // Fallback to mailto: if Resend API is not configured or fails
        try await sendViaMailto(text: text)
    }
    
    private func sendViaResendAPI(text: String) async throws {
        guard !ResendConfig.apiKey.isEmpty else {
            throw NSError(domain: "FeedbackService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resend API key not configured"])
        }
        
        guard let url = URL(string: ResendConfig.apiURL) else {
            throw NSError(domain: "FeedbackService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(ResendConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Escape HTML special characters for safety
        let escapedText = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\n", with: "<br>")
        
        let requestBody: [String: Any] = [
            "from": "LifeLab Feedback <\(ResendConfig.senderEmail)>",
            "to": [ResendConfig.recipientEmail],
            "subject": "LifeLab 用戶反饋",
            "html": "<p>\(escapedText)</p>"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "FeedbackService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(errorMessage)"])
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Resend API Error (\(httpResponse.statusCode)): \(errorMessage.prefix(200))")
            throw NSError(domain: "FeedbackService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error (\(httpResponse.statusCode)): \(errorMessage)"])
        }
        
        print("✅ Feedback sent successfully via Resend API")
    }
    
    private func sendViaMailto(text: String) async throws {
        let subject = "LifeLab 用戶反饋"
        let body = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(ResendConfig.recipientEmail)?subject=\(subjectEncoded)&body=\(body)") {
            await MainActor.run {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            throw NSError(domain: "FeedbackService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create mailto URL"])
        }
    }
}
