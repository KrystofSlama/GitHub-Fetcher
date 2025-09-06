//
//  SettingsView.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 31.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var token: String = KeychainHelper.getToken() ?? ""
        @State private var saved = false
        
        var body: some View {
            Form {
                Section(header: Text("GitHub API Token")) {
                    SecureField("Enter token", text: $token)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    Button("Save") {
                        KeychainHelper.saveToken(token)
                        saved = true
                    }
                }
                
                if saved {
                    Text("✅ Token saved!")
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("API Settings")
        }
    }

#Preview {
    SettingsView()
}
