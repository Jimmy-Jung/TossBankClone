import Foundation
import SwiftData
import DomainModule

/// SwiftData 스키마 관리자
public class SchemaManager {
    /// 모델 컨테이너 생성
    /// - Returns: 모델 컨테이너
    public static func createModelContainer() throws -> ModelContainer {
        // 스키마 정의
        let schema = Schema([
            Account.self,
            Transaction.self,
            TransactionMetadata.self
        ])
        
        // 모델 컨테이너 구성
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        // 모델 컨테이너 생성
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
} 