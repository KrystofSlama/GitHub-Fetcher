//
//  KeychainHelper.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 06.09.2025.
//

import Security
import Foundation

protocol TokenStore {
    func getToken() -> String?
    func saveToken(_ token: String)
}

final class KeychainHelper: TokenStore {
    static let shared = KeychainHelper()
    private init() {}

    func saveToken(_ token: String) {
        let tokenData = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "github_api_token",
            kSecValueData as String: tokenData
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "github_api_token",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            if let data = item as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}
