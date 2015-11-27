protocol Character {
    var id: String { get }
    var name: String { get }
    var friends: [String] { get }
    var appearsIn: [Int] { get }
}

enum Episode: Int {
    case NewHope = 4
    case EmpireStrikesBack = 5
    case ReturnOfTheJedi = 6

    func getHero() -> Character {
        switch self {
        case .EmpireStrikesBack: return luke
        case .NewHope, .ReturnOfTheJedi: return artoo
        }
    }
}

extension Character {
    func getFriends() -> [Character] {
        return friends.map { id in
            if let humanFriend = humanTable[id] {
                return humanFriend
            } else if let droidFriend = droidTable[id] {
                return droidFriend
            }
            fatalError("Invalid relationship")
        }
    }
}

struct Human: Character {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Int]
    let homePlanet: String?

    static func getById(id: String) -> Human? {
        return humanTable[id]
    }

    init(id: String, name: String, friends: [String], appearsIn: [Int], homePlanet: String? = nil) {
        self.id = id
        self.name = name
        self.friends = friends
        self.appearsIn = appearsIn
        self.homePlanet = homePlanet
    }
}

struct Droid: Character {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Int]
    let primaryFunction: String

    static func getById(id: String) -> Droid? {
        return droidTable[id]
    }

    init(id: String, name: String, friends: [String], appearsIn: [Int], primaryFunction: String) {
        self.id = id
        self.name = name
        self.friends = friends
        self.appearsIn = appearsIn
        self.primaryFunction = primaryFunction
    }
}
