import SwiftUI

struct PlayfulBackground: View {
    @State private var animateShapes = false
    @State private var sparkleOpacity: [Double] = Array(repeating: 0.3, count: 8)
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            // Floating shapes with animation
            Circle()
                .fill(Theme.modePink.opacity(0.2))
                .frame(width: 220, height: 220)
                .offset(x: -140, y: animateShapes ? -210 : -230)
                .blur(radius: 2)

            Circle()
                .fill(Theme.modeBlue.opacity(0.18))
                .frame(width: 260, height: 260)
                .offset(x: 160, y: animateShapes ? -130 : -150)
                .blur(radius: 2)

            Circle()
                .fill(Theme.modeOrange.opacity(0.2))
                .frame(width: 200, height: 200)
                .offset(x: 160, y: animateShapes ? 230 : 210)
                .blur(radius: 2)

            RoundedRectangle(cornerRadius: 60)
                .fill(Theme.modeTeal.opacity(0.15))
                .frame(width: 220, height: 120)
                .rotationEffect(.degrees(animateShapes ? -15 : -21))
                .offset(x: -140, y: 200)
                .blur(radius: 2)
            
            // Additional floating elements
            Circle()
                .fill(Theme.modePurple.opacity(0.15))
                .frame(width: 150, height: 150)
                .offset(x: 100, y: animateShapes ? 50 : 30)
                .blur(radius: 3)
            
            // Sparkles
            ForEach(0..<8, id: \.self) { index in
                SparkleDecoration(index: index)
                    .opacity(sparkleOpacity[index])
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateShapes = true
            }
            
            // Animate sparkles with slight delays
            for i in 0..<8 {
                withAnimation(.easeInOut(duration: 1.5 + Double(i) * 0.2).repeatForever(autoreverses: true).delay(Double(i) * 0.15)) {
                    sparkleOpacity[i] = 0.8
                }
            }
        }
    }
}

/// Small decorative sparkle
private struct SparkleDecoration: View {
    let index: Int
    
    private var position: CGPoint {
        let positions: [CGPoint] = [
            CGPoint(x: -120, y: -280),
            CGPoint(x: 150, y: -220),
            CGPoint(x: -80, y: 80),
            CGPoint(x: 130, y: 150),
            CGPoint(x: -150, y: 300),
            CGPoint(x: 100, y: 320),
            CGPoint(x: 0, y: -150),
            CGPoint(x: -50, y: 250)
        ]
        return positions[index % positions.count]
    }
    
    private var size: CGFloat {
        [12, 16, 10, 14, 12, 18, 10, 14][index % 8]
    }
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundStyle(
                [Theme.starGold, Theme.modePink, Theme.modeBlue, Theme.modePurple,
                 Theme.highlight, Theme.modeTeal, Theme.starGoldLight, Theme.modeOrange][index % 8]
            )
            .offset(x: position.x, y: position.y)
    }
}

#Preview {
    PlayfulBackground()
}

