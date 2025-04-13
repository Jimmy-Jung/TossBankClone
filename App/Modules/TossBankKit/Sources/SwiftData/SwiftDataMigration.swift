import Foundation
import SwiftData

// MARK: - 스키마 버전
public enum SchemaVersion: Int, Comparable {
    case v1 = 1
    case v2 = 2
    // 추가 버전은 필요에 따라 확장
    
    public static var current: SchemaVersion {
        return .v1 // 현재 버전
    }
    
    public static func < (lhs: SchemaVersion, rhs: SchemaVersion) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 스키마 관리자
public final class SchemaManager {
    // 현재 앱 버전에서 사용하는 최신 스키마
    public static func currentSchema() -> Schema {
        Schema([
            Account.self,
            Transaction.self,
            TransactionMetadata.self
        ])
    }
    
    // SwiftData 컨테이너 생성
    public static func createModelContainer() throws -> ModelContainer {
        let schema = currentSchema()
        let modelConfiguration = ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        return container
    }
    
    // 마이그레이션을 위한 스키마 버전 관리 (나중에 필요할 때 구현)
    private static func configureVersionedSchema() -> Schema {
        // 현재는 v1만 사용하므로 간단하게 현재 스키마 반환
        return currentSchema()
        
        // 향후 버전 업그레이드 시 아래와 같은 방식으로 확장
        /*
        let schema = Schema([
            Account.self,
            Transaction.self,
            TransactionMetadata.self
        ])
        
        let v1Schema = Schema([
            // v1 모델 정의
        ])
        
        let migrationPlan = SchemaMigrationPlan(
            from: v1Schema,
            to: schema,
            migration: { context in
                // 마이그레이션 코드
            }
        )
        
        return schema
        */
    }
}

// MARK: - 마이그레이션 예시 (v1 -> v2)
/*
// 실제 마이그레이션이 필요한 경우 주석 해제하여 사용
public struct MigrationV1toV2: SchemaMigration {
    public let fromVersion = 1
    public let toVersion = 2
    
    public func performMigration(from oldSchema: Schema, to newSchema: Schema) throws {
        // 필드가 추가된 경우
        try migrateEntity(in: oldSchema, to: newSchema, fromType: "Account", toType: "Account") { oldInstance, newInstance in
            if let id = oldInstance["id"] as? String {
                newInstance["id"] = id
            }
            if let name = oldInstance["name"] as? String {
                newInstance["name"] = name
            }
            if let type = oldInstance["type"] as? String {
                newInstance["type"] = type
            }
            if let balance = oldInstance["balance"] as? Decimal {
                newInstance["balance"] = balance
            }
            if let number = oldInstance["number"] as? String {
                newInstance["number"] = number
            }
            if let isActive = oldInstance["isActive"] as? Bool {
                newInstance["isActive"] = isActive
            }
            if let createdAt = oldInstance["createdAt"] as? Date {
                newInstance["createdAt"] = createdAt
            }
            if let updatedAt = oldInstance["updatedAt"] as? Date {
                newInstance["updatedAt"] = updatedAt
            }
            
            // 새로운 필드가 추가된 경우 기본값 설정
            newInstance["newField"] = "기본값" // 예시: 새로 추가된 필드
        }
    }
}
*/

// MARK: - 모의 데이터 생성기
public final class MockDataGenerator {
    public static func generateMockData(in context: ModelContext) {
        // 계좌 생성
        let checkingAccount = Account(
            name: "일상 계좌",
            type: .checking,
            balance: 2_500_000,
            number: "123-456-789",
            isActive: true
        )
        
        let savingsAccount = Account(
            name: "저축 계좌",
            type: .savings,
            balance: 15_000_000,
            number: "123-456-790",
            isActive: true
        )
        
        // 트랜잭션 생성 및 계좌에 추가
        let calendar = Calendar.current
        
        // 입금 트랜잭션
        let deposit = Transaction(
            amount: 1_000_000,
            type: .deposit,
            description: "급여",
            category: .income,
            date: calendar.date(byAdding: .day, value: -5, to: Date())!,
            account: checkingAccount,
            metadata: TransactionMetadata(
                merchantName: "토스뱅크",
                reference: "incoming"
            )
        )
        
        // 출금 트랜잭션
        let withdrawal = Transaction(
            amount: 50_000,
            type: .withdrawal,
            description: "ATM 출금",
            category: .other,
            date: calendar.date(byAdding: .day, value: -3, to: Date())!,
            account: checkingAccount
        )
        
        // 결제 트랜잭션
        let payment = Transaction(
            amount: 15_000,
            type: .payment,
            description: "스타벅스 결제",
            category: .food,
            date: calendar.date(byAdding: .day, value: -2, to: Date())!,
            account: checkingAccount,
            metadata: TransactionMetadata(
                location: "서울시 강남구",
                merchantName: "스타벅스",
                merchantLogo: "starbucks_logo"
            )
        )
        
        // 송금 트랜잭션
        let transfer = Transaction(
            amount: 200_000,
            type: .transfer,
            description: "저축 계좌로 이체",
            category: .transfer,
            date: calendar.date(byAdding: .day, value: -1, to: Date())!,
            account: checkingAccount,
            metadata: TransactionMetadata(
                merchantName: "토스뱅크",
                reference: "outgoing"
            )
        )
        
        // 저축 계좌 입금 트랜잭션 (위 송금의 반대편)
        let transferIn = Transaction(
            amount: 200_000,
            type: .transfer,
            description: "일상 계좌에서 이체",
            category: .transfer,
            date: calendar.date(byAdding: .day, value: -1, to: Date())!,
            account: savingsAccount,
            metadata: TransactionMetadata(
                merchantName: "토스뱅크",
                reference: "incoming"
            )
        )
        
        // 모델 컨텍스트에 저장
        context.insert(checkingAccount)
        context.insert(savingsAccount)
        
        if checkingAccount.transactions == nil {
            checkingAccount.transactions = []
        }
        if savingsAccount.transactions == nil {
            savingsAccount.transactions = []
        }
        
        checkingAccount.transactions?.append(contentsOf: [deposit, withdrawal, payment, transfer])
        savingsAccount.transactions?.append(transferIn)
        
        // 변경사항 저장
        try? context.save()
    }
} 