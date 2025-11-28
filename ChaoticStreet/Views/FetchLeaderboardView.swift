import SwiftUI
import Charts

struct FetchLeaderboardView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel
    @State private var leaderboard: [ScoreEntry] = []
    @State private var isLoading = false
    @State private var isAnimating = false
    @State private var selectedTab: Int = 0
    @Binding var showLeaderboard: Bool

    var body: some View {
        NavigationView {
            ZStack {
                // Content based on selected tab
                if selectedTab == 0 {
                    LeaderboardTabView(
                        scoreViewModel: scoreViewModel,
                        leaderboard: $leaderboard,
                        isLoading: $isLoading,
                        isAnimating: $isAnimating,
                        refreshLeaderboard: refreshLeaderboard
                    )
                } else if selectedTab == 1 {
                    AchievementsTabView(scoreViewModel: scoreViewModel)
                } else {
                    MyScoresTabView(scoreViewModel: scoreViewModel)
                }
                
                // Custom overlay tab bar
                VStack {
                    Spacer()
                    
                    // Custom Tab Bar
                    HStack(spacing: 0) {
                        // Leaderboard Tab
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 0
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: selectedTab == 0 ? "chart.bar.xaxis" : "chart.bar")
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedTab == 0 ? Color("colorOrange") : Color("colorDarkBlue").opacity(0.6))
                                
                                Text("Leaderboard")
                                    .font(.caption2)
                                    .fontWeight(selectedTab == 0 ? .semibold : .medium)
                                    .foregroundColor(selectedTab == 0 ? Color("colorOrange") : Color("colorDarkBlue").opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        
                        // Achievements Tab
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 1
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: selectedTab == 1 ? "trophy.fill" : "trophy")
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedTab == 1 ? Color("colorOrange") : Color("colorDarkBlue").opacity(0.6))
                                
                                Text("Achievements")
                                    .font(.caption2)
                                    .fontWeight(selectedTab == 1 ? .semibold : .medium)
                                    .foregroundColor(selectedTab == 1 ? Color("colorOrange") : Color("colorDarkBlue").opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        
                        // My Scores Tab
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = 2
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedTab == 2 ? Color("colorOrange") : Color("colorDarkBlue").opacity(0.6))
                                
                                Text("My Scores")
                                    .font(.caption2)
                                    .fontWeight(selectedTab == 2 ? .semibold : .medium)
                                    .foregroundColor(selectedTab == 2 ? Color("colorOrange") : Color("colorDarkBlue").opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                    }
                    .background(
                        // Background with blur effect
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .background(Color.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
                    )
                    .overlay(
                        // Top border
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color("colorDarkBlue").opacity(0.2)),
                        alignment: .top
                    )
                    .overlay(
                        // Selection indicator
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: 40, height: 3)
                                .foregroundColor(Color("colorOrange"))
                                .offset(x: {
                                    let tabWidth = geometry.size.width / 3
                                    switch selectedTab {
                                    case 0: return tabWidth / 2 - 20
                                    case 1: return tabWidth * 1.5 - 20
                                    case 2: return tabWidth * 2.5 - 20
                                    default: return tabWidth / 2 - 20
                                    }
                                }())
                                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                        },
                        alignment: .top
                    )
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationTitle(selectedTab == 0 ? "Leaderboard" : selectedTab == 1 ? "Achievements" : "My Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("settings.done") {
                        showLeaderboard = false
                    }
                    .foregroundColor(Color("colorDarkBlue"))
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            refreshLeaderboard()
        }
    }
    
    private func refreshLeaderboard() {
        isLoading = true
        scoreViewModel.fetchLeaderboard { scores in
            withAnimation(.easeInOut(duration: 0.5)) {
                leaderboard = scores
                isLoading = false
            }
        }
    }
}

struct LeaderboardListView: View {
    let leaderboard: [ScoreEntry]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(leaderboard.enumerated()), id: \.element.score) { index, entry in
                LeaderboardRowView(entry: entry, rank: index + 1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .padding(.horizontal, 20)
    }
}

struct LeaderboardRowView: View {
    let entry: ScoreEntry
    let rank: Int
    
    private var rankIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    private var backgroundColor: Color {
        switch rank {
        case 1: return Color("colorYellow").opacity(0.3)
        case 2: return Color("colorLightGrey").opacity(0.4)
        case 3: return Color("colorOrange").opacity(0.2)
        default: return Color.white.opacity(0.8)
        }
    }
    
    private var borderColor: Color {
        switch rank {
        case 1: return Color("colorYellow")
        case 2: return Color("colorLightGrey")
        case 3: return Color("colorOrange")
        default: return Color("colorDarkBlue").opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            VStack {
                if rank <= 3 {
                    Text(rankIcon)
                        .font(.title)
                        .scaleEffect(rank == 1 ? 1.2 : 1.0)
                } else {
                    Text(rankIcon)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("colorDarkBlue"))
                        .frame(width: 30, height: 30)
                        .background(Color("colorLightGrey").opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .frame(width: 50)
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color("colorDarkBlue"))
                        .font(.caption)
                    Text("\(entry.email)")
                        .font(.caption)
                        .foregroundColor(Color("colorDarkRed"))
                    Spacer()
                    DifficultyBadge(difficulty: entry.difficulty)
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color("colorOrange"))
                        .font(.caption)
                    Text("\(entry.score) pts")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("colorDarkBlue"))
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color("colorRed"))
                            .font(.caption2)
                        Text("\(entry.distance)m")
                            .font(.caption)
                            .foregroundColor(Color("colorDarkRed"))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(Color("colorRed"))
                            .font(.caption2)
                        Text(formatTime(entry.timeAlive))
                            .font(.caption)
                            .foregroundColor(Color("colorDarkRed"))
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: rank <= 3 ? 2 : 1)
        )
        .shadow(color: Color("colorDarkBlue").opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct DifficultyBadge: View {
    let difficulty: String
    
    private var badgeColor: Color {
        switch difficulty.lowercased() {
        case "easy": return Color("colorRed")
        case "medium": return Color("colorOrange")
        case "hard": return Color("colorDarkRed")
        default: return Color("colorDarkBlue")
        }
    }
    
    var body: some View {
        Text(difficulty.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .cornerRadius(8)
    }
}

struct EmptyLeaderboardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("No Scores Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("colorDarkBlue"))
            
            Text("Be the first to play and set a high score!")
                .font(.subheadline)
                .foregroundColor(Color("colorDarkRed"))
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(40)
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("colorDarkBlue").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Leaderboard Tab View
struct LeaderboardTabView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel
    @Binding var leaderboard: [ScoreEntry]
    @Binding var isLoading: Bool
    @Binding var isAnimating: Bool
    let refreshLeaderboard: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                GameBackgroundView(colors: [
                    Color("colorYellow").opacity(0.1),
                    Color("colorOrange").opacity(0.2),
                    Color("colorDarkBlue").opacity(0.1)
                ])
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)
                        
                        // Header with trophy animation
                        VStack(spacing: 16) {
                            Text("🏆")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("Leaderboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Top players from around the world")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 10)
                        
                        // Refresh button
                        Button {
                            refreshLeaderboard()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Refresh Leaderboard")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(SecondaryGameButtonStyle(isEnabled: !isLoading))
                        .disabled(isLoading)
                        .padding(.horizontal, 20)
                        
                        // Leaderboard content
                        if leaderboard.isEmpty && !isLoading {
                            EmptyLeaderboardView()
                        } else {
                            LeaderboardListView(leaderboard: leaderboard)
                        }
                        
                        Spacer(minLength: 120) // Extra space for overlay tab bar
                    }
                }
            }
        }
    }
}

// MARK: - Achievements Tab View
struct AchievementsTabView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient matching the leaderboard
                GameBackgroundView(colors: [
                    Color("colorYellow").opacity(0.1),
                    Color("colorOrange").opacity(0.2),
                    Color("colorDarkBlue").opacity(0.1)
                ])
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)
                        
                        // Header with trophy animation
                        VStack(spacing: 16) {
                            Text("🏅")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("Achievements")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Your gaming milestones and accomplishments")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 10)
                        
                        // Refresh button
                        Button {
                            scoreViewModel.fetchAchievements()
                        } label: {
                            HStack {
                                if scoreViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Refresh Achievements")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(SecondaryGameButtonStyle(isEnabled: !scoreViewModel.isLoading))
                        .disabled(scoreViewModel.isLoading)
                        .padding(.horizontal, 20)
                        
                        // Achievements content
                        if scoreViewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading achievements...")
                                    .foregroundColor(Color("colorDarkBlue"))
                                    .font(.subheadline)
                            }
                            .padding(.top, 40)
                        } else if scoreViewModel.achievementMilestones.isEmpty {
                            EmptyAchievementsView()
                        } else {
                            AchievementListView(scoreViewModel: scoreViewModel)
                        }
                        
                        Spacer(minLength: 120) // Extra space for overlay tab bar
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            scoreViewModel.fetchAchievements()
        }
    }
}

// MARK: - Achievement List View
struct AchievementListView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(scoreViewModel.achievementMilestones, id: \.id) { milestone in
                AchievementRowView(milestone: milestone, scoreViewModel: scoreViewModel)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Achievement Row View
struct AchievementRowView: View {
    let milestone: (score: Int, id: String, name: String, description: String)
    @ObservedObject var scoreViewModel: ScoreViewModel
    
    private var isUnlocked: Bool {
        scoreViewModel.achievements.contains(where: { $0.milestoneId == milestone.id })
    }
    
    private var achievement: Achievement? {
        scoreViewModel.achievements.first(where: { $0.milestoneId == milestone.id })
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Achievement Icon
            VStack {
                Text(isUnlocked ? "🏆" : "🔒")
                    .font(.system(size: 32))
                    .opacity(isUnlocked ? 1.0 : 0.5)
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(isUnlocked ? Color("colorOrange").opacity(0.2) : Color.gray.opacity(0.1))
            )
            
            // Achievement Details
            VStack(alignment: .leading, spacing: 8) {
                Text(milestone.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isUnlocked ? Color("colorDarkBlue") : Color.gray)
                
                Text(milestone.description)
                    .font(.subheadline)
                    .foregroundColor(isUnlocked ? Color("colorDarkRed") : Color.gray)
                    .opacity(0.8)
                
                if let achievement = achievement {
                    Text("Achieved: \(achievement.achievedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(Color("colorOrange"))
                        .fontWeight(.medium)
                } else {
                    Text("Not yet achieved")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            
            Spacer()
            
            // Achievement Status
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("colorOrange"))
                    .font(.title2)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? Color("colorOrange").opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Empty Achievements View
struct EmptyAchievementsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎯")
                .font(.system(size: 60))
            
            Text("No Achievements Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("colorDarkBlue"))
            
            Text("Start playing to unlock your first achievements!")
                .font(.subheadline)
                .foregroundColor(Color("colorDarkRed"))
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(40)
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("colorDarkBlue").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - My Scores Tab View
struct MyScoresTabView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel
    @State private var userScores: [ScoreEntry] = []
    @State private var isAnimating = false
    @State private var userId = "41TvdnKQ4ubnNRFMqSwuTISn4H72"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient matching other tabs
                GameBackgroundView(colors: [
                    Color("colorYellow").opacity(0.1),
                    Color("colorOrange").opacity(0.2),
                    Color("colorDarkBlue").opacity(0.1)
                ])
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)
                        
                        // Header with chart animation
                        VStack(spacing: 16) {
                            Text("📊")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("My Scores")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Your personal performance history")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 10)
                        
                        // Refresh button
                        Button {
                            fetchUserScores()
                        } label: {
                            HStack {
                                if scoreViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Load My Scores")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(SecondaryGameButtonStyle(isEnabled: !scoreViewModel.isLoading))
                        .disabled(scoreViewModel.isLoading)
                        .padding(.horizontal, 20)
                        
                        // Chart Section
                        if !userScores.isEmpty {
                            VStack(spacing: 16) {
                                Text("Performance Chart")
                                    .font(.headline)
                                    .foregroundColor(Color("colorDarkBlue"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                
                                MyScoresChartView(userScores: userScores)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Scores content
                        if scoreViewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading your scores...")
                                    .foregroundColor(Color("colorDarkBlue"))
                                    .font(.subheadline)
                            }
                            .padding(.top, 40)
                        } else if userScores.isEmpty {
                            EmptyMyScoresView()
                        } else {
                            MyScoresListView(userScores: userScores)
                        }
                        
                        Spacer(minLength: 120) // Extra space for overlay tab bar
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private func fetchUserScores() {
        scoreViewModel.fetchUserScores { scores in
            withAnimation(.easeInOut(duration: 0.5)) {
                userScores = scores
            }
        }
    }
}

// MARK: - My Scores Chart View
struct MyScoresChartView: View {
    var userScores: [ScoreEntry]
    
    var body: some View {
        Chart {
            ForEach(userScores.prefix(15).enumerated().map({ $0 }), id: \.offset) { index, entry in
                BarMark(
                    x: .value("Game", index + 1),
                    y: .value("Score", entry.score)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("colorOrange"), Color("colorDarkBlue")],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
        }
        .frame(height: 200)
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("colorDarkBlue").opacity(0.3), lineWidth: 1)
        )
        .chartXAxisLabel("Game Session")
        .chartYAxisLabel("Score")
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
    }
}

// MARK: - My Scores List View
struct MyScoresListView: View {
    let userScores: [ScoreEntry]
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(userScores.indices, id: \.self) { index in
                MyScoreRowView(score: userScores[index], gameNumber: index + 1)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - My Score Row View
struct MyScoreRowView: View {
    let score: ScoreEntry
    let gameNumber: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Game number
            VStack {
                Text("#\(gameNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("colorOrange"))
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(Color("colorOrange").opacity(0.2))
            )
            
            // Score details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Score: \(score.score)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("colorDarkBlue"))
                    
                    Spacer()
                    
                    DifficultyBadge(difficulty: score.difficulty)
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(score.distance)m")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("colorDarkRed"))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Time Alive")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(score.timeAlive)s")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("colorDarkRed"))
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("colorDarkBlue").opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Empty My Scores View
struct EmptyMyScoresView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎮")
                .font(.system(size: 60))
            
            Text("No Games Played Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("colorDarkBlue"))
            
            Text("Start playing to see your score history and track your progress!")
                .font(.subheadline)
                .foregroundColor(Color("colorDarkRed"))
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(40)
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("colorDarkBlue").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    let mockViewModel = ScoreViewModel()
    FetchLeaderboardView(scoreViewModel: mockViewModel, showLeaderboard: .constant(true))
}
