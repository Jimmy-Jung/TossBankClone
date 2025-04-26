//
//  RepositoryError.swift
//  DataModule
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation

/// 리포지토리 오류 정의
public enum RepositoryError: Error {
    case itemNotFound
    case serverError
    case networkError
    case offlineError
    case unauthorized
}
