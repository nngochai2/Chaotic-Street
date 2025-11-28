import SwiftUI

struct LaneBasedRoadView: View {
    // Lane PNG dimensions (adjust to match your actual PNG size)
    @State private var laneWidth: CGFloat = 800    // Width of your lane PNG
    @State private var laneHeight: CGFloat = 200   // Height of your lane PNG
    
    // Positioning controls
    @State private var laneSpacing: CGFloat = 60   // Vertical spacing between lanes
    @State private var laneOffset: CGFloat = 0     // Horizontal offset for isometric effect
    @State private var laneScale: CGFloat = 1.0    // Scale factor for lanes
    
    // Road configuration
    @State private var numberOfLanes: Int = 8
    @State private var isometricAngle: CGFloat = 30  // Isometric perspective angle
    
    // UI controls
    @State private var showControls: Bool = true
    @State private var showLaneNumbers: Bool = true
    @State private var enableScrolling: Bool = false
    
    var body: some View {
        VStack {
            // Controls panel
            if showControls {
                controlsPanel
            }
            
            // Toggle controls button
            Button(showControls ? "Hide Controls" : "Show Controls") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showControls.toggle()
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            
            // Main road view
            GeometryReader { geometry in
                ZStack {
                    // Sky background
                    Color.blue.opacity(0.2)
                    
                    // Scrollable road lanes
                    if enableScrolling {
                        ScrollView(.vertical, showsIndicators: false) {
                            roadLanes(geometry: geometry)
                                .frame(height: CGFloat(numberOfLanes + 5) * (laneHeight * laneScale + laneSpacing))
                        }
                    } else {
                        roadLanes(geometry: geometry)
                    }
                    
                    // Info overlay
                    infoOverlay(geometry: geometry)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Road Lanes
    private func roadLanes(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<numberOfLanes, id: \.self) { laneIndex in
                laneView(laneIndex: laneIndex, geometry: geometry)
            }
        }
    }
    
    // MARK: - Individual Lane
    private func laneView(laneIndex: Int, geometry: GeometryProxy) -> some View {
        let position = calculateLanePosition(laneIndex: laneIndex, geometry: geometry)
        let laneType = determineLaneType(laneIndex: laneIndex)
        
        return ZStack {
            // Lane image
            Image(getLaneImageName(for: laneType))
                .resizable()
                .frame(
                    width: laneWidth * laneScale,
                    height: laneHeight * laneScale
                )
                .position(position)
                .zIndex(Double(numberOfLanes - laneIndex)) // Proper depth layering
                .rotation3DEffect(
                    .degrees(Double(isometricAngle)),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.3
                )
            
            // Lane number overlay
            if showLaneNumbers {
                Text("Lane \(laneIndex)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .position(
                        CGPoint(
                            x: position.x - (laneWidth * laneScale / 2) + 50,
                            y: position.y
                        )
                    )
                    .zIndex(Double(numberOfLanes - laneIndex + 100))
            }
        }
    }
    
    // MARK: - Lane Positioning
    private func calculateLanePosition(laneIndex: Int, geometry: GeometryProxy) -> CGPoint {
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        
        // Isometric positioning
        let yPosition = centerY + CGFloat(laneIndex) * laneSpacing
        let xPosition = centerX + (CGFloat(laneIndex) * laneOffset) // Isometric offset
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    // MARK: - Lane Types
    private func determineLaneType(laneIndex: Int) -> LaneType {
        switch laneIndex {
        case 0:
            return .start
        case _ where laneIndex % 3 == 0:
            return .safe
        default:
            return .traffic
        }
    }
    
    private func getLaneImageName(for laneType: LaneType) -> String {
        switch laneType {
        case .start:
            return "sidewalk_lane" // Your sidewalk PNG
        case .safe:
            return "sidewalk_lane" // Your sidewalk PNG
        case .traffic:
            return "road2" // Your road lane PNG (the one you showed)
        }
    }
    
    // MARK: - Controls Panel
    private var controlsPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                // Lane dimensions
                VStack {
                    Text("Lane Size")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    VStack {
                        HStack {
                            Text("Width: \(Int(laneWidth))")
                                .font(.caption2)
                            Slider(value: $laneWidth, in: 400...1200, step: 50)
                                .frame(width: 100)
                        }
                        HStack {
                            Text("Height: \(Int(laneHeight))")
                                .font(.caption2)
                            Slider(value: $laneHeight, in: 100...400, step: 25)
                                .frame(width: 100)
                        }
                    }
                }
                
                Divider()
                
                // Lane positioning
                VStack {
                    Text("Lane Positioning")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    VStack {
                        HStack {
                            Text("Spacing: \(Int(laneSpacing))")
                                .font(.caption2)
                            Slider(value: $laneSpacing, in: 20...120, step: 5)
                                .frame(width: 100)
                        }
                        HStack {
                            Text("Offset: \(Int(laneOffset))")
                                .font(.caption2)
                            Slider(value: $laneOffset, in: -50...50, step: 2)
                                .frame(width: 100)
                        }
                    }
                }
                
                Divider()
                
                // 3D effects
                VStack {
                    Text("3D Effects")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    VStack {
                        HStack {
                            Text("Scale: \(String(format: "%.2f", laneScale))")
                                .font(.caption2)
                            Slider(value: $laneScale, in: 0.5...2.0, step: 0.05)
                                .frame(width: 100)
                        }
                        HStack {
                            Text("Angle: \(Int(isometricAngle))°")
                                .font(.caption2)
                            Slider(value: $isometricAngle, in: -60...60, step: 5)
                                .frame(width: 100)
                        }
                    }
                }
                
                Divider()
                
                // Road configuration
                VStack {
                    Text("Road Config")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    VStack {
                        HStack {
                            Text("Lanes: \(numberOfLanes)")
                                .font(.caption2)
                            Slider(value: Binding(
                                get: { Double(numberOfLanes) },
                                set: { numberOfLanes = Int($0) }
                            ), in: 1...15, step: 1)
                                .frame(width: 100)
                        }
                        
                        Toggle("Scrolling", isOn: $enableScrolling)
                            .font(.caption2)
                        Toggle("Lane Numbers", isOn: $showLaneNumbers)
                            .font(.caption2)
                    }
                }
                
                Divider()
                
                // Action buttons
                VStack(spacing: 8) {
                    Button("Reset") {
                        laneWidth = 800
                        laneHeight = 200
                        laneSpacing = 60
                        laneOffset = 0
                        laneScale = 1.0
                        isometricAngle = 30
                        numberOfLanes = 8
                    }
                    .buttonStyle(ActionButtonStyle(color: .red))
                    
                    Button("Isometric Preset") {
                        laneSpacing = 45
                        laneOffset = 15
                        isometricAngle = 25
                        laneScale = 0.8
                    }
                    .buttonStyle(ActionButtonStyle(color: .blue))
                    
                    Button("Copy Values") {
                        let values = """
                        // Lane-based road settings:
                        laneWidth: \(laneWidth)
                        laneHeight: \(laneHeight)
                        laneSpacing: \(laneSpacing)
                        laneOffset: \(laneOffset)
                        laneScale: \(laneScale)
                        isometricAngle: \(isometricAngle)
                        numberOfLanes: \(numberOfLanes)
                        """
                        UIPasteboard.general.string = values
                        print(values)
                    }
                    .buttonStyle(ActionButtonStyle(color: .green))
                }
            }
            .padding()
        }
        .frame(height: 120)
        .background(Color.white.opacity(0.95))
    }
    
    // MARK: - Info Overlay
    private func infoOverlay(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lane-Based Road System")
                        .fontWeight(.bold)
                    Text("Lanes: \(numberOfLanes)")
                    Text("Spacing: \(Int(laneSpacing))px")
                    Text("Scale: \(String(format: "%.2f", laneScale))")
                    Text("Angle: \(Int(isometricAngle))°")
                }
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
                
                Text("Screen: \(Int(geometry.size.width))×\(Int(geometry.size.height))")
                    .font(.caption)
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

// MARK: - Production Lane-Based Road
struct ProductionLaneRoad: View {
    // Final optimized values (update after testing)
    let laneWidth: CGFloat = 800
    let laneHeight: CGFloat = 200
    let laneSpacing: CGFloat = 60
    let laneOffset: CGFloat = 15
    let laneScale: CGFloat = 0.8
    let isometricAngle: CGFloat = 25
    
    let numberOfLanes: Int
    
    init(numberOfLanes: Int = 10) {
        self.numberOfLanes = numberOfLanes
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.blue.opacity(0.2)
                
                ForEach(0..<numberOfLanes, id: \.self) { laneIndex in
                    let position = calculateLanePosition(laneIndex: laneIndex, geometry: geometry)
                    let laneType = determineLaneType(laneIndex: laneIndex)
                    
                    Image(getLaneImageName(for: laneType))
                        .resizable()
                        .frame(
                            width: laneWidth * laneScale,
                            height: laneHeight * laneScale
                        )
                        .position(position)
                        .zIndex(Double(numberOfLanes - laneIndex))
                        .rotation3DEffect(
                            .degrees(Double(isometricAngle)),
                            axis: (x: 1, y: 0, z: 0),
                            perspective: 0.3
                        )
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private func calculateLanePosition(laneIndex: Int, geometry: GeometryProxy) -> CGPoint {
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        
        let yPosition = centerY + CGFloat(laneIndex) * laneSpacing
        let xPosition = centerX + (CGFloat(laneIndex) * laneOffset)
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    private func determineLaneType(laneIndex: Int) -> LaneType {
        switch laneIndex {
        case 0: return .start
        case _ where laneIndex % 3 == 0: return .safe
        default: return .traffic
        }
    }
    
    private func getLaneImageName(for laneType: LaneType) -> String {
        switch laneType {
        case .start, .safe: return "sidewalk_lane"
        case .traffic: return "road_lane"
        }
    }
}

// MARK: - Button Style
struct ActionButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    LaneBasedRoadView()
}
