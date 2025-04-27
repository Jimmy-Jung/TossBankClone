//
//  AccountDetailView.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct AccountDetailView: View {
    @StateObject var viewModel: AccountDetailViewModel
    
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
                        viewModel.send(.refresh)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            } else if let account = viewModel.account {
                // 계좌 정보
                AccountInfoCardView(account: account)
                    .padding()
                
                // 송금 버튼
                Button(action: {
                    viewModel.send(.transferButtonTapped)
                }) {
                    Text("송금하기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 거래 내역 목록
                if viewModel.transactions.isEmpty {
                    Text("거래 내역이 없습니다")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.transactions, id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .listStyle(.plain)
                }
            } else {
                Text("계좌 정보를 불러오는 중입니다...")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .navigationTitle("계좌 상세")
        .task {
            viewModel.send(.viewDidLoad)
        }
    }
}
