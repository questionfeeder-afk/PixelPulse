import SwiftUI

@main
struct PixelPulseArcadeApp: App {
    @StateObject private var store = AppStore()
    var body: some Scene {
        WindowGroup("PixelPulse Arcade") {
            RootView()
                .environmentObject(store)
                .frame(minWidth: 1100, minHeight: 720)
        }
        .windowStyle(.titleBar)
        .commands { SidebarCommands() }
    }
}

final class AppStore: ObservableObject {
    @Published var loggedIn = false
    @Published var username = ""
    @Published var palette: Palette = .purple
    @Published var friends: [String] = []
    @Published var messages: [Message] = []
    @Published var notifications: [NotificationItem] = []
    
    func login(username: String) { self.username = username; loggedIn = true }
    func logout() { loggedIn = false; username = "" }
    func addFriend(_ name: String) { if !friends.contains(name), !name.isEmpty { friends.append(name) } }
    func sendMessage(to: String, text: String) {
        guard !text.isEmpty else { return }
        messages.append(Message(from: username, to: to, text: text, date: .now))
    }
}

enum Palette: String, CaseIterable, Identifiable { case purple, blue, green, orange, pink; var id: Self { self }
    var accent: Color { switch self { case .purple: .purple; case .blue: .blue; case .green: .green; case .orange: .orange; case .pink: .pink } }
}
struct Message: Identifiable { let id = UUID(); let from: String; let to: String; let text: String; let date: Date }
struct NotificationItem: Identifiable { let id = UUID(); let text: String }

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        if store.loggedIn { MainView() } else { LoginView() }
    }
}

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var signUp = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, store.palette.accent.opacity(0.35), .black], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("PIXELPULSE").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("ARCADE").font(.title2.bold()).foregroundStyle(store.palette.accent)
                VStack(spacing: 12) {
                    TextField("Username", text: $username).textFieldStyle(.roundedBorder)
                    if signUp { TextField("Email", text: $email).textFieldStyle(.roundedBorder) }
                    SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
                    Button(signUp ? "Create Account" : "Log In") { store.login(username: username.isEmpty ? "Player" : username) }
                        .buttonStyle(.borderedProminent).tint(store.palette.accent).controlSize(.large)
                    Button(signUp ? "Already have an account? Log in" : "Create an account") { signUp.toggle() }.buttonStyle(.link)
                }.frame(width: 360).padding(28).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 24))
                Text("WIP (work in progress)").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var store: AppStore
    @State private var selection = "Home"
    var body: some View {
        NavigationSplitView {
            List(["Home","Games","Friends","Messages","Settings"], id: \.self, selection: $selection) { item in
                Label(item, systemImage: icon(item)).tag(item)
            }.navigationTitle("PixelPulse")
        } detail: {
            Group { switch selection { case "Games": GamesView(); case "Friends": FriendsView(); case "Messages": MessagesView(); case "Settings": SettingsView(); default: HomeView() } }
                .toolbar { ToolbarItem(placement: .automatic) { Text("@\(store.username)").font(.subheadline).foregroundStyle(.secondary) } }
        }
        .tint(store.palette.accent)
    }
    func icon(_ s: String) -> String { switch s { case "Home":"house.fill"; case "Games":"gamecontroller.fill"; case "Friends":"person.2.fill"; case "Messages":"message.fill"; case "Settings":"gearshape.fill"; default:"circle" } }
}

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    var body: some View { VStack(alignment: .leading, spacing: 24) { Text("Welcome back, \(store.username)!").font(.largeTitle.bold()); Text("Pick a game and start playing.").foregroundStyle(.secondary); HStack { Stat(title:"Games", value:"10"); Stat(title:"Friends", value:"\(store.friends.count)"); Stat(title:"Messages", value:"\(store.messages.count)") }; Spacer() }.padding(40) }
}
struct Stat: View { let title:String; let value:String; var body: some View { VStack(alignment:.leading) { Text(value).font(.largeTitle.bold()); Text(title).foregroundStyle(.secondary) }.frame(width:180, alignment:.leading).padding(20).background(.quaternary).clipShape(RoundedRectangle(cornerRadius:18)) } }

struct GamesView: View {
    let games = ["Reaction Rush","Memory Match","Number Guess","Brick Breaker","Snake","Tic-Tac-Toe","Aim Trainer","Higher or Lower","Dodge","Word Scramble"]
    var body: some View { ScrollView { LazyVGrid(columns:[GridItem(.adaptive(minimum:220))], spacing:18) { ForEach(games, id:\.self) { game in NavigationLink { GameView(name: game) } label: { VStack(alignment:.leading, spacing:10) { Image(systemName:"gamecontroller.fill").font(.title); Text(game).font(.headline); Text("Play now").font(.caption).foregroundStyle(.secondary) }.frame(maxWidth:.infinity, minHeight:130, alignment:.leading).padding(20).background(.quaternary).clipShape(RoundedRectangle(cornerRadius:20)) } } }.padding(30) } }

struct GameView: View {
    let name: String
    @State private var score = 0
    @State private var target = Int.random(in: 1...10)
    @State private var guess = ""
    @State private var reaction = false
    var body: some View { VStack(spacing:24) { Text(name).font(.largeTitle.bold()); Text("Score: \(score)").font(.title3); Spacer(); content; Spacer() }.padding(40) }
    @ViewBuilder var content: some View {
        switch name {
        case "Reaction Rush": Button(reaction ? "CLICK!" : "Wait...") { if reaction { score += 1; reaction = false } }.buttonStyle(.borderedProminent).controlSize(.large).task { try? await Task.sleep(for:.seconds(1)); reaction = true }
        case "Number Guess": VStack { Text("Guess 1–10"); TextField("Number", text:$guess).textFieldStyle(.roundedBorder).frame(width:120); Button("Guess") { if Int(guess) == target { score += 1; target = Int.random(in:1...10); guess = "" } }.buttonStyle(.borderedProminent) }
        case "Tic-Tac-Toe": VStack(spacing:8) { ForEach(0..<3,id:\.self) { _ in HStack { ForEach(0..<3,id:\.self) { _ in Button("○") { score += 1 }.font(.largeTitle).frame(width:70,height:70).background(.quaternary).clipShape(RoundedRectangle(cornerRadius:12)) } } } }
        case "Higher or Lower": Button("Higher or Lower — click to score") { score += 1 }.buttonStyle(.borderedProminent)
        case "Aim Trainer": Button("🎯 HIT TARGET") { score += 1 }.buttonStyle(.borderedProminent).controlSize(.large)
        case "Memory Match": Button("Reveal a Pair") { score += 1 }.buttonStyle(.borderedProminent)
        case "Brick Breaker": Button("Launch Ball") { score += 1 }.buttonStyle(.borderedProminent)
        case "Snake": Button("Eat Food") { score += 1 }.buttonStyle(.borderedProminent)
        case "Dodge": Button("Dodge") { score += 1 }.buttonStyle(.borderedProminent)
        default: Button("Unscramble Word") { score += 1 }.buttonStyle(.borderedProminent)
        }
    }
}

struct FriendsView: View {
    @EnvironmentObject var store: AppStore
    @State private var name = ""
    var body: some View { VStack(alignment:.leading, spacing:20) { Text("Friends").font(.largeTitle.bold()); HStack { TextField("Add by username", text:$name).textFieldStyle(.roundedBorder); Button("Add") { store.addFriend(name); name = "" }.buttonStyle(.borderedProminent) }; List(store.friends, id:\.self) { Text($0) }; Spacer() }.padding(30) }
}
struct MessagesView: View {
    @EnvironmentObject var store: AppStore
    @State private var friend = ""
    @State private var text = ""
    var body: some View { VStack(alignment:.leading, spacing:18) { Text("Messages").font(.largeTitle.bold()); HStack { TextField("Friend username", text:$friend).textFieldStyle(.roundedBorder); TextField("Message", text:$text).textFieldStyle(.roundedBorder); Button("Send") { store.sendMessage(to:friend,text:text); text="" }.buttonStyle(.borderedProminent) }; List(store.messages) { m in VStack(alignment:.leading) { Text("@\(m.from) → @\(m.to)").font(.caption).foregroundStyle(.secondary); Text(m.text) } }; Spacer() }.padding(30) }
}
struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    var body: some View { Form { Section("Color palette") { Picker("Accent", selection:$store.palette) { ForEach(Palette.allCases) { Text($0.rawValue.capitalized).tag($0) } }.pickerStyle(.segmented) }; Section { Button("Log Out", role:.destructive) { store.logout() } } }.padding(30) }
}
