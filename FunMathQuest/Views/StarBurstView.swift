import SwiftUI

/// Star burst animation when earning stars
struct StarBurstView: View {
    @State private var isAnimating = false
    
    private let starCount = 8
    private let starColor = Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
    
    var body: some View {
        ZStack {
            // Radiating stars
            ForEach(0..<starCount, id: \.self) { index in
                StarShape()
                    .fill(starColor)
                    .frame(width: 20, height: 20)
                    .offset(y: isAnimating ? -80 : 0)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(starCount))))
                    .opacity(isAnimating ? 0 : 1)
                    .scaleEffect(isAnimating ? 0.3 : 1)
            }
            
            // Center burst
            Circle()
                .fill(
                    RadialGradient(
                        colors: [starColor, starColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: isAnimating ? 100 : 20
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(isAnimating ? 0 : 0.6)
            
            // Sparkles
            ForEach(0..<12, id: \.self) { index in
                SparkleShape()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .offset(y: isAnimating ? -60 : -20)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .opacity(isAnimating ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

/// Five-pointed star shape
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        
        var path = Path()
        
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = (Double(i) * .pi / Double(points)) - (.pi / 2)
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

/// Diamond sparkle shape
private struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: center.y))
        path.closeSubpath()
        
        return path
    }
}

/// Animated star with bounce and glow
struct AnimatedStar: View {
    @State private var isGlowing = false
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Glow effect
            StarShape()
                .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5))
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: 8)
                .scaleEffect(isGlowing ? 1.2 : 1.0)
            
            // Main star
            StarShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.94, blue: 0.4),
                            Color(red: 1.0, green: 0.84, blue: 0.0),
                            Color(red: 0.9, green: 0.7, blue: 0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        StarBurstView()
        AnimatedStar(size: 50)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.purple.opacity(0.3))
}
