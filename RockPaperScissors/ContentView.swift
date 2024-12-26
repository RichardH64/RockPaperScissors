//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Richard Harrison on 12/26/24.
//

import SwiftUI

enum AppState{
    case home
    case game
    case result
}

enum GameChoices {
    case rock
    case paper
    case scissors
    
    var name: String {
        switch self {
        case .rock: 
            return "Rock"
        case .paper:
            return "Paper"
        case .scissors:
            return "Scissors"
        }
    }
    
    func ties(_ other: GameChoices) -> Bool {
        return self == other
    }
    
    func beats(_ other: GameChoices) -> Bool {
        switch (self, other) {
        case (.rock, .scissors), (.scissors, .paper), (.paper, .rock):
            return true
        default:
            return false
        }
    }
    
    static func random() -> GameChoices {
        return [GameChoices.rock, .paper, .scissors].randomElement()!
    }
}

class Application : ObservableObject {
    @Published var state: AppState = .home
    @Published var playerChoice: GameChoices?
    @Published var opponentChoice: GameChoices?
    @Published var result: String = ""
    
    var resultImageName: String {
        switch result {
        case "You Won":
            return "flag.filled.and.flag.crossed"
        case "You Loss":
            return "flag.and.flag.filled.crossed"
        case "You Tied":
            return "flag.2.crossed.fill"
        default:
            return "questionmark.circle"
        }
    }
    
    var backgroundColor: Color {
        switch result {
        case "You Won":
            return .green
        case "You Loss":
            return .red
        case "You Tied":
            return .yellow
        default:
            return .yellow
        }
    }
    
    func calcWin() {
        guard let playerChoice = playerChoice, let opponentChoice = opponentChoice else {
            return
        }
        
        if playerChoice.ties(opponentChoice) {
            result = "You Tied"
        }
        else if playerChoice.beats(opponentChoice) {
            result = "You Won"
        }
        else {
            result = "You Loss"
        }
        
        state = .result
    }
    
    func reset() {
        state = .home
        playerChoice = nil
        opponentChoice = nil
        result = ""
    }
}

struct ContentView: View {
    @StateObject private var app = Application()

    var body: some View {
        switch app.state {
        case .home:
            HomeView(app: app)
        case .game:
            GameView(app: app)
        case .result:
            ResultView(app: app)
        }
    }
}

struct HomeView: View {
    @ObservedObject var app: Application

    var body: some View {
        ZStack {
            app.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Rock, Paper, Scissors!")
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .padding(16)
                Image(systemName: "gamecontroller")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.tint)
                Spacer()
                GlassButtonView(label:"Click Me") {
                    app.state = .game
                }
            }
        }
    }
}

struct GameView: View {
    @ObservedObject var app: Application
    
    var body: some View {
        ZStack {
            app.backgroundColor.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "gamecontroller.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Spacer()
                Text("Choose")
                    .font(.title)
                    .fontWeight(.bold)
                HStack(alignment: .center) {
                    GlassButtonView(label:"Rock", icon: "mountain.2.fill") {
                        app.playerChoice = .rock
                        app.opponentChoice = GameChoices.random()
                        app.calcWin()
                    }
                    GlassButtonView(label:"Paper", icon: "document.fill") {
                        app.playerChoice = .paper
                        app.opponentChoice = GameChoices.random()
                        app.calcWin()
                    }
                    GlassButtonView(label:"Scissors", icon: "scissors") {
                        app.playerChoice = .scissors
                        app.opponentChoice = GameChoices.random()
                        app.calcWin()
                    }
                }
                .padding(.bottom, 200)
//                HStack(alignment: .center) {
//                    GlassButtonView(label:"Spock", icon: "mountain.2.fill") {
//                    }
//                    GlassButtonView(label:"Lizard", icon: "document.fill") {
//                    }
//                }
            }
        }
    }
}

struct ResultView: View {
    @ObservedObject var app: Application

    var body: some View {
        ZStack {
            app.backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.25), value: app.backgroundColor)

            VStack(spacing: 20) {
                Image(systemName: app.resultImageName)
                    .imageScale(.large)
                Text(app.result)
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .padding(16)
                HStack {
                    GlassWidget(text: "You Picked: \(app.playerChoice?.name ?? "None")")
                    GlassWidget(text: "Opp Picked: \(app.opponentChoice?.name ?? "None")")
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )
                .cornerRadius(16)
                Spacer()
                GlassButtonView(label:"Play Again", icon: "house.fill") {
                    app.reset()
                }
            }
        }
    }
}

struct ButtonView: View {
    var icon: String?
    var label: String
    var action: () -> Void
    
    init(
        label: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                Text(label)
            }
            .padding()
            .background(Color.blue)
            .foregroundStyle(Color.white)
            .cornerRadius(16)
            
        }
    }
}

struct GlassButtonView: View {
    var icon: String?
    var label: String
    var action: () -> Void
    
    init(
        label: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 27, height: 27)
                        .foregroundStyle(.tint)
                }
                Text(label)
                    .font(.headline)
            }
            .padding()
            .background(.ultraThinMaterial) // Apply the glass effect
            .cornerRadius(16) // Smooth rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1) // Add a subtle border
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // Add depth with shadow
        }
    }
}

struct GlassWidget: View {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(.ultraThinMaterial) // Apply the glass effect
        .cornerRadius(16) // Smooth rounded corners
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.6), lineWidth: 1) // Add a subtle border
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // Add depth with shadow
    }
}


#Preview {
    ContentView()
}
