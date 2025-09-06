//
//  SettingsView.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 31.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var token: String
    @State private var saved = false
    let service: GitHubService

    init(service: GitHubService) {
        self.service = service
        _token = State(initialValue: service.token ?? "")
    }

    var body: some View {
        Form {
            Section(header: Text("GitHub API Token")) {
                SecureField("Enter token", text: $token)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                Button("Save") {
                    service.updateToken(token)
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
    SettingsView(service: GitHubService())
}
