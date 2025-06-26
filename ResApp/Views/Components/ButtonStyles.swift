import SwiftUI

// MARK: - Custom Button Styles

struct OutcomeButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color
    let geometry: GeometryProxy
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: geometry.size.width * 0.016, weight: .bold))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, geometry.size.width * 0.015)
            .padding(.vertical, geometry.size.height * 0.008)
            .background(isSelected ? color : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.008)
                    .stroke(color, lineWidth: 2)
            )
            .cornerRadius(geometry.size.width * 0.008)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct FunctionalButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let geometry: GeometryProxy
    let isEnabled: Bool
    
    init(backgroundColor: Color, foregroundColor: Color = .white, geometry: GeometryProxy, isEnabled: Bool = true) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.geometry = geometry
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: geometry.size.width * 0.018, weight: .bold))
            .foregroundColor(isEnabled ? foregroundColor : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.height * 0.015)
            .background(isEnabled ? backgroundColor : Color.gray.opacity(0.3))
            .cornerRadius(geometry.size.width * 0.012)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

struct EnergyButtonStyle: ButtonStyle {
    let isSelected: Bool
    let geometry: GeometryProxy
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: geometry.size.width * 0.016, weight: .bold))
            .foregroundColor(isSelected ? .white : .blue)
            .padding(.horizontal, geometry.size.width * 0.015)
            .padding(.vertical, geometry.size.height * 0.008)
            .background(isSelected ? Color.blue : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.008)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .cornerRadius(geometry.size.width * 0.008)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 