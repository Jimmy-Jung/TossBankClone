import SwiftUI

public struct PINIndicator: View {
    let pinLength: Int
    let maxDigits: Int
    let isError: Bool
    
    public init(pinLength: Int, maxDigits: Int = 6, isError: Bool = false) {
        self.pinLength = pinLength
        self.maxDigits = maxDigits
        self.isError = isError
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<maxDigits, id: \.self) { index in
                Circle()
                    .fill(getCircleColor(for: index))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(getStrokeColor(for: index), lineWidth: 1)
                    )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: pinLength)
        .animation(.easeInOut(duration: 0.2), value: isError)
    }
    
    private func getCircleColor(for index: Int) -> Color {
        if isError {
            return .red.opacity(0.15)
        }
        
        return index < pinLength ? .accentColor : .clear
    }
    
    private func getStrokeColor(for index: Int) -> Color {
        if isError {
            return .red
        }
        
        return index < pinLength ? .accentColor : .gray.opacity(0.5)
    }
} 