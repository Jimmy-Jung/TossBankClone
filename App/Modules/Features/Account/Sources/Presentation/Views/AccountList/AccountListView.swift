//
//  AccountListView.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct AccountListView: View {
    @StateObject var viewModel: AccountListViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = viewModel.error {
                VStack {
                    Text("계좌 정보를 불러오는데 실패했습니다")
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Button("다시 시도") {
                        Task {
                            viewModel.send(.refresh)
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            } else {
                List(viewModel.accounts, id: \.id) { account in
                    AccountRowView(account: account)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.send(.selectAccount(id: account.id))
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.send(.refresh)
                }
            }
        }
        .navigationTitle("내 계좌")
        .task {
            viewModel.send(.viewDidLoad)
        }
    }
}
