import SwiftUI

struct PlayfulBackground: View {
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(Theme.modePink.opacity(0.18))
                .frame(width: 220, height: 220)
                .offset(x: -140, y: -220)

            Circle()
                .fill(Theme.modeBlue.opacity(0.16))
                .frame(width: 260, height: 260)
                .offset(x: 160, y: -140)

            Circle()
                .fill(Theme.modeOrange.opacity(0.18))
                .frame(width: 200, height: 200)
                .offset(x: 160, y: 220)

            RoundedRectangle(cornerRadius: 60)
                .fill(Theme.modeTeal.opacity(0.12))
                .frame(width: 220, height: 120)
                .rotationEffect(.degrees(-18))
                .offset(x: -140, y: 200)
        }
    }
}

#Preview {
    PlayfulBackground()
}
