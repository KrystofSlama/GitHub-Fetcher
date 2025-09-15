//
//  RepoIssueView.swift
//  GitHubFetcher
//
//  Created by Kryštof Sláma on 15.09.2025.
//

import SwiftUI

struct RepoIssueView: View {
    let repoName : String
    
    let issueNumber : Int
    
    var body: some View {
        Text(repoName)
        Text("\(issueNumber)")
    }
}

#Preview {
    RepoIssueView(repoName: "Test", issueNumber: 123)
}
