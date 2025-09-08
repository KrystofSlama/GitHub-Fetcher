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
    @State private var isPresentedPopover: Bool = false
    let service: GitHubService

    init(service: GitHubService) {
        self.service = service
        _token = State(initialValue: service.token ?? "")
    }

    var body: some View {
        Form {
            Section(header: Text("GitHub API Token")) {
                HStack {
                    SecureField("Enter token", text: $token)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Button {
                        isPresentedPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .popover(isPresented: $isPresentedPopover,
                                     content: {
                                VStack(alignment: .leading) {
                                    // Title row
                                    HStack {
                                        Text("Why Token?")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }.padding(.top)
                                    
                                    // Description
                                    Text("You need Personal Acces Token (PAT) to acces repositories from GitHub")
                                        .font(.title3)
                                    Spacer()
                                    Text("Where Token?")
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                    Text("To create PAT go to your profile settings > Developer settings > Personal access token")
                                        .padding(.bottom)
                                    // Details
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Recommended:")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        Text("• Fine-grained tokens")
                                            .font(.title3)
                                        Text("• As access use only **Public repositories**")
                                            .font(.title3)
                                        Text("• Don’t forget to set up **Expiration** date")
                                            .font(.title3)
                                            .padding(.bottom, 16)
                                        Text("Other:")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        Text("• Classic PAT: use **public_repo** for public repos")
                                            .font(.title3)
                                    }
                                    .font(.callout)
                                    
                                    Spacer()
                                    // Link
                                    Link("Open GitHub Token Settings →", destination: URL(string: "https://github.com/settings/personal-access-tokens")!)
                                        .font(.callout)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                .padding()
                            })
                            .presentationCompactAdaptation(.popover)
                    }.foregroundStyle(.black)
                }
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
