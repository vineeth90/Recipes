//
//  RecipeImageView.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import SwiftUI

struct RecipeImageView: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    case .empty:
                        loadingView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.12))

            ProgressView()
                .tint(.secondary)
        }
    }
    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.12))

            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Image unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

