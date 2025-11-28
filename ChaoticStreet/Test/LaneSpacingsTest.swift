import SwiftUI

struct LaneSpacingTest: View {
    // Lane settings
    @State private var laneSpacing: CGFloat = 150
    @State private var laneOffset: CGFloat = 0
    @State private var showDebugInfo: Bool = true
    
    let laneWidth: CGFloat = 900
    let laneHeight: CGFloat = 200
    let laneScale: CGFloat = 1.15
    let isometricAngle: Double = 5.0
    
    var body: some View {
        VStack {
            // Controls
            VStack {
                HStack {
                    Text("Lane Spacing: \(Int(laneSpacing))")
                    Slider(value: $laneSpacing, in: 50...300, step: 10)
                }
                HStack {
                    Text("Lane Offset: \(Int(laneOffset))")
                    Slider(value: $laneOffset, in: -100...100, step: 5)
                }
                Toggle("Debug Info", isOn: $showDebugInfo)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            
            // Test view
            GeometryReader { geometry in
                ZStack {
                    Color.blue.opacity(0.2)
                    
                    // Test with fewer lanes to see overlap clearly
                    ForEach(-3...3, id: \.self) { laneIndex in
                        testLane(
                            laneIndex: laneIndex,
                            centerX: geometry.size.width / 2,
                            centerY: geometry.size.height / 2
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func testLane(laneIndex: Int, centerX: CGFloat, centerY: CGFloat) -> some View {
        let position = CGPoint(
            x: centerX + CGFloat(laneIndex) * laneOffset,
            y: centerY + CGFloat(laneIndex) * laneSpacing
        )
        
        let laneColor = getLaneColor(for: laneIndex)
        
        ZStack {
            // Lane rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(laneColor)
                .stroke(Color.black, lineWidth: 2) // Add border to see overlap
                .frame(
                    width: laneWidth * laneScale,
                    height: laneHeight * laneScale
                )
                .position(position)
                .zIndex(Double(10 - laneIndex)) // Proper z-ordering
                .rotation3DEffect(
                    .degrees(isometricAngle),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.3
                )
            
            // Debug info
            if showDebugInfo {
                VStack {
                    Text("Lane \(laneIndex)")
                        .fontWeight(.bold)
                    Text("Y: \(Int(position.y))")
                    Text("Z: \(10 - laneIndex)")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
                .position(position)
                .zIndex(Double(20 - laneIndex)) // Above lane
            }
        }
    }
    
    private func getLaneColor(for laneIndex: Int) -> Color {
        switch laneIndex {
        case 0:
            return Color.green.opacity(0.8) // Start lane
        case _ where laneIndex % 2 == 0:
            return Color.gray.opacity(0.6)  // Safe lane
        default:
            return Color.black.opacity(0.7) // Traffic lane
        }
    }
}

#Preview {
    LaneSpacingTest()
}
