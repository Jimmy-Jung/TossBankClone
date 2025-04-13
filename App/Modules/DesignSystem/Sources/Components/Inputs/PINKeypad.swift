import SwiftUI
import SwiftData

/// PIN 코드 입력을 위한 커스텀 키패드 컴포넌트
public struct PINKeypad: View {
    // MARK: - 속성
    let onNumberTapped: (Int) -> Void
    let onDeleteTapped: () -> Void
    
    private let numbers: [[Int?]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [nil, 0, nil]
    ]
    
    // MARK: - 생성자
    public init(onNumberTapped: @escaping (Int) -> Void, onDeleteTapped: @escaping () -> Void) {
        self.onNumberTapped = onNumberTapped
        self.onDeleteTapped = onDeleteTapped
    }
    
    // MARK: - 바디
    public var body: some View {
        VStack(spacing: 20) {
            ForEach(0..<numbers.count, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(0..<numbers[row].count, id: \.self) { column in
                        if let number = numbers[row][column] {
                            keyButton(number: number)
                        } else if row == 3 && column == 2 {
                            deleteButton
                        } else {
                            emptyKey
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 헬퍼 메서드
    private func keyButton(number: Int) -> some View {
        Button {
            onNumberTapped(number)
        } label: {
            Text("\(number)")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var deleteButton: some View {
        Button {
            onDeleteTapped()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var emptyKey: some View {
        Circle()
            .foregroundColor(.clear)
            .frame(width: 70, height: 70)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// MARK: - PIN 표시기
public struct PINIndicator: View {
    // MARK: - 속성
    private let pinLength: Int
    private let isError: Bool
    private let maxLength: Int
    
    // MARK: - 생성자
    public init(pinLength: Int, isError: Bool = false, maxLength: Int = 6) {
        self.pinLength = pinLength
        self.isError = isError
        self.maxLength = maxLength
    }
    
    // MARK: - 바디
    public var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<maxLength, id: \.self) { index in
                Circle()
                    .fill(index < pinLength
                          ? (isError ? ColorTokens.State.error : ColorTokens.Brand.primary)
                          : ColorTokens.Background.secondary)
                    .frame(width: 16, height: 16)
                    .animation(.spring(response: 0.2), value: pinLength)
                    .animation(.spring(response: 0.2), value: isError)
            }
        }
    }
}

// MARK: - 햅틱 매니저
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - 프리뷰
struct PINKeypad_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PINIndicator(pinLength: 3)
                .padding()
            
            Spacer()
            
            PINKeypad(
                onNumberTapped: { _ in },
                onDeleteTapped: {}
            )
            .padding()
        }
        .background(ColorTokens.Background.primary)
        .previewLayout(.sizeThatFits)
    }
} 
