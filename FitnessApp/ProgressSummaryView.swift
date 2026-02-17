//
//  ProgressSummaryView.swift
//  FitnessApp
//
//  Created by Eshna Gupta on 2/16/26.
//

import SwiftUI

struct ProgressSummaryView: View {

    @StateObject private var viewModel = ProgressSummaryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Based on your last 7 days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else if let summary = viewModel.summary {
                        ScrollView {
                            Text(summary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    } else {
                        Spacer()
                        Text("Tap below to get a personal trainer-style summary of your recent workouts and mood.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                }

                if !viewModel.isLoading {
                    Button("Generate progress summary") {
                        Task {
                            await viewModel.generateSummary()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Progress summary")
        }
    }
}

#Preview {
    ProgressSummaryView()
}
