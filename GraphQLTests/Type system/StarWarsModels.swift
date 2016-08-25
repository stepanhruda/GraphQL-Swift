import GraphQL

protocol Character: GraphQLType {
    var id: String { get }
    var name: String { get }
    var friends: [String] { get }
    var appearsIn: [Episode] { get }
}

enum Episode: String, GraphQLType {
    case NewHope = "NEWHOPE"
    case EmpireStrikesBack = "EMPIRE"
    case ReturnOfTheJedi = "JEDI"

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

struct Human: Character, GraphQLType {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Episode]
    let homePlanet: String?

    static func getById(id: String) -> Human? {
        return humanTable[id]
    }

    init(id: String, name: String, friends: [String], appearsIn: [Episode], homePlanet: String? = nil) {
        self.id = id
        self.name = name
        self.friends = friends
        self.appearsIn = appearsIn
        self.homePlanet = homePlanet
    }
}

struct Droid: Character, GraphQLType {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Episode]
    let primaryFunction: String

    static func getById(id: String) -> Droid? {
        return droidTable[id]
    }

    init(id: String, name: String, friends: [String], appearsIn: [Episode], primaryFunction: String) {
        self.id = id
        self.name = name
        self.friends = friends
        self.appearsIn = appearsIn
        self.primaryFunction = primaryFunction
    }
}

struct Query {}
