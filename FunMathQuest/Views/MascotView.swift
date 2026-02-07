import SwiftUI

/// Mascot mood states
enum MascotMood: String, CaseIterable {
    case happy      // Default happy state
    case excited    // Celebrating correct answer
    case encouraging // After wrong answer
    case thinking   // While waiting for answer
    case waving     // Greeting on home screen
}

/// Cute fox mascot with expressions and speech bubbles
struct MascotView: View {
    let mood: MascotMood
    let message: String?
    let size: CGFloat
    
    @State private var isAnimating = false
    @State private var bounceOffset: CGFloat = 0
    
    init(mood: MascotMood = .happy, message: String? = nil, size: CGFloat = 100) {
        self.mood = mood
        self.message = message
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Speech bubble
            if let message = message {
                SpeechBubble(text: message)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Fox mascot
            ZStack {
                // Body shadow
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: size * 0.8, height: size * 0.3)
                    .offset(y: size * 0.4)
                    .blur(radius: 4)
                
                // Fox body
                FoxBody(mood: mood)
                    .frame(width: size, height: size)
                    .offset(y: bounceOffset)
            }
        }
        .onAppear {
            startIdleAnimation()
            startMoodAnimation()
        }
        .onChange(of: mood) { _, _ in
            startMoodAnimation()
        }
    }
    
    private func startIdleAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            bounceOffset = -5
        }
    }
    
    private func startMoodAnimation() {
        switch mood {
        case .excited:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatCount(3)) {
                bounceOffset = -15
            }
        case .waving:
            isAnimating = true
        default:
            break
        }
    }
}

/// Fox body composed of shapes
private struct FoxBody: View {
    let mood: MascotMood
    
    @State private var earWiggle: Double = 0
    @State private var tailWag: Double = 0
    
    private let foxOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    private let foxLight = Color(red: 1.0, green: 0.9, blue: 0.8)
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                // Tail
                TailShape()
                    .fill(foxOrange)
                    .frame(width: w * 0.4, height: h * 0.3)
                    .rotationEffect(.degrees(tailWag), anchor: .leading)
                    .offset(x: w * 0.3, y: h * 0.2)
                
                // Tail tip
                Circle()
                    .fill(foxLight)
                    .frame(width: w * 0.15)
                    .offset(x: w * 0.45, y: h * 0.15)
                    .rotationEffect(.degrees(tailWag * 0.5), anchor: .init(x: 0.3, y: 0.5))
                
                // Body
                Ellipse()
                    .fill(foxOrange)
                    .frame(width: w * 0.6, height: h * 0.5)
                    .offset(y: h * 0.15)
                
                // Belly
                Ellipse()
                    .fill(foxLight)
                    .frame(width: w * 0.35, height: h * 0.35)
                    .offset(y: h * 0.2)
                
                // Head
                Circle()
                    .fill(foxOrange)
                    .frame(width: w * 0.55, height: w * 0.55)
                    .offset(y: -h * 0.1)
                
                // Left ear
                EarShape()
                    .fill(foxOrange)
                    .frame(width: w * 0.18, height: h * 0.22)
                    .rotationEffect(.degrees(-15 + earWiggle))
                    .offset(x: -w * 0.15, y: -h * 0.35)
                
                // Right ear
                EarShape()
                    .fill(foxOrange)
                    .frame(width: w * 0.18, height: h * 0.22)
                    .rotationEffect(.degrees(15 - earWiggle))
                    .offset(x: w * 0.15, y: -h * 0.35)
                
                // Inner ears
                EarShape()
                    .fill(Color.pink.opacity(0.5))
                    .frame(width: w * 0.1, height: h * 0.12)
                    .rotationEffect(.degrees(-15 + earWiggle))
                    .offset(x: -w * 0.15, y: -h * 0.32)
                
                EarShape()
                    .fill(Color.pink.opacity(0.5))
                    .frame(width: w * 0.1, height: h * 0.12)
                    .rotationEffect(.degrees(15 - earWiggle))
                    .offset(x: w * 0.15, y: -h * 0.32)
                
                // Face patch
                FacePatch()
                    .fill(foxLight)
                    .frame(width: w * 0.45, height: h * 0.35)
                    .offset(y: h * 0.02)
                
                // Eyes
                eyeView(isLeft: true, w: w, h: h)
                eyeView(isLeft: false, w: w, h: h)
                
                // Nose
                Circle()
                    .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                    .frame(width: w * 0.08)
                    .offset(y: h * 0.02)
                
                // Mouth
                mouthView(w: w, h: h)
                
                // Cheeks (blush)
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: w * 0.12)
                    .offset(x: -w * 0.18, y: h * 0.02)
                
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: w * 0.12)
                    .offset(x: w * 0.18, y: h * 0.02)
                
                // Glasses (for character)
                if mood == .thinking || mood == .happy {
                    GlassesView()
                        .frame(width: w * 0.5, height: h * 0.15)
                        .offset(y: -h * 0.08)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                earWiggle = 5
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                tailWag = 20
            }
        }
    }
    
    @ViewBuilder
    private func eyeView(isLeft: Bool, w: CGFloat, h: CGFloat) -> some View {
        let xOffset = isLeft ? -w * 0.12 : w * 0.12
        
        ZStack {
            // Eye white
            Ellipse()
                .fill(Color.white)
                .frame(width: w * 0.14, height: w * 0.16)
            
            // Pupil
            Circle()
                .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                .frame(width: w * 0.08)
                .offset(y: mood == .thinking ? -2 : 0)
            
            // Eye shine
            Circle()
                .fill(Color.white)
                .frame(width: w * 0.03)
                .offset(x: w * 0.02, y: -w * 0.02)
            
            // Excited sparkle
            if mood == .excited {
                StarShape()
                    .fill(Color.yellow)
                    .frame(width: w * 0.06)
                    .offset(x: w * 0.03, y: -w * 0.03)
            }
        }
        .offset(x: xOffset, y: -h * 0.12)
    }
    
    @ViewBuilder
    private func mouthView(w: CGFloat, h: CGFloat) -> some View {
        switch mood {
        case .happy, .waving:
            // Smile
            SmileShape()
                .stroke(Color(red: 0.2, green: 0.15, blue: 0.1), lineWidth: 2)
                .frame(width: w * 0.15, height: h * 0.08)
                .offset(y: h * 0.1)
        case .excited:
            // Big open smile
            Ellipse()
                .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                .frame(width: w * 0.12, height: h * 0.08)
                .offset(y: h * 0.1)
        case .encouraging:
            // Encouraging smile
            SmileShape()
                .stroke(Color(red: 0.2, green: 0.15, blue: 0.1), lineWidth: 2)
                .frame(width: w * 0.12, height: h * 0.05)
                .offset(y: h * 0.1)
        case .thinking:
            // Thinking o
            Circle()
                .stroke(Color(red: 0.2, green: 0.15, blue: 0.1), lineWidth: 2)
                .frame(width: w * 0.06)
                .offset(y: h * 0.1)
        }
    }
}

// MARK: - Shape Components

private struct EarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        return path
    }
}

private struct TailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

private struct FacePatch: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX * 0.8, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.maxX * 0.2, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        return path
    }
}

private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

private struct GlassesView: View {
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 0.3, green: 0.25, blue: 0.2), lineWidth: 2)
            Rectangle()
                .fill(Color(red: 0.3, green: 0.25, blue: 0.2))
                .frame(width: 8, height: 2)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 0.3, green: 0.25, blue: 0.2), lineWidth: 2)
        }
    }
}

/// Speech bubble for mascot messages
struct SpeechBubble: View {
    let text: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Text(text)
                    .font(Theme.bodyFont(14))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    )
                
                // Bubble tail
                Triangle()
                    .fill(Color.white)
                    .frame(width: 16, height: 10)
                    .offset(y: -1)
            }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 30) {
        MascotView(mood: .waving, message: "Welcome back! 👋", size: 120)
        
        HStack(spacing: 20) {
            MascotView(mood: .happy, size: 80)
            MascotView(mood: .excited, message: "Great job! 🎉", size: 80)
            MascotView(mood: .encouraging, message: "Try again!", size: 80)
            MascotView(mood: .thinking, size: 80)
        }
    }
    .padding()
    .background(Theme.backgroundGradient)
}
