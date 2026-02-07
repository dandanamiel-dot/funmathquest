import SwiftUI

/// Beautiful confetti celebration animation with large visible pieces
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    private let colors: [Color] = [
        Color(red: 1.0, green: 0.84, blue: 0.0),     // Gold
        Color(red: 0.98, green: 0.46, blue: 0.64),   // Pink
        Color(red: 0.55, green: 0.40, blue: 0.94),   // Purple
        Color(red: 0.28, green: 0.56, blue: 0.95),   // Blue
        Color(red: 0.18, green: 0.72, blue: 0.66),   // Teal
        Color(red: 0.98, green: 0.56, blue: 0.24),   // Orange
        Color(red: 0.46, green: 0.84, blue: 0.46),   // Green
        Color.red,
        Color.yellow,
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(
                        color: particle.color,
                        shape: particle.shape,
                        size: particle.size
                    )
                    .position(x: particle.x, y: particle.y)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
                animateParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<60).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? .yellow,
                shape: ConfettiShape.allCases.randomElement() ?? .rectangle,
                x: CGFloat.random(in: 0...size.width),
                y: -CGFloat.random(in: 20...100),
                size: CGFloat.random(in: 12...24),
                rotation: Double.random(in: 0...360),
                velocity: CGFloat.random(in: 300...600),
                rotationSpeed: Double.random(in: 180...720),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles(in size: CGSize) {
        // Continuous animation loop
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            var allOffScreen = true
            
            for i in particles.indices {
                particles[i].y += particles[i].velocity * 0.016
                particles[i].x += CGFloat.random(in: -2...2)
                particles[i].rotation += particles[i].rotationSpeed * 0.016
                
                // Fade out near bottom
                if particles[i].y > size.height * 0.7 {
                    particles[i].opacity = max(0, particles[i].opacity - 0.02)
                }
                
                if particles[i].y < size.height + 50 {
                    allOffScreen = false
                }
            }
            
            if allOffScreen {
                timer.invalidate()
            }
        }
    }
}

/// Confetti particle data
private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let shape: ConfettiShape
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var rotation: Double
    let velocity: CGFloat
    let rotationSpeed: Double
    var opacity: Double
}

private enum ConfettiShape: CaseIterable {
    case rectangle
    case circle
    case triangle
    case star
}

/// Individual confetti piece
private struct ConfettiPiece: View {
    let color: Color
    let shape: ConfettiShape
    let size: CGFloat
    
    var body: some View {
        Group {
            switch shape {
            case .rectangle:
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: size, height: size * 0.6)
            case .circle:
                Circle()
                    .fill(color)
                    .frame(width: size * 0.8, height: size * 0.8)
            case .triangle:
                Triangle()
                    .fill(color)
                    .frame(width: size, height: size)
            case .star:
                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.8))
                    .foregroundStyle(color)
            }
        }
        .shadow(color: color.opacity(0.5), radius: 2)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Overlay modifier for easy confetti usage
struct ConfettiModifier: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isActive {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
    }
}

extension View {
    func confetti(isActive: Bool) -> some View {
        modifier(ConfettiModifier(isActive: isActive))
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        ConfettiView()
    }
}

