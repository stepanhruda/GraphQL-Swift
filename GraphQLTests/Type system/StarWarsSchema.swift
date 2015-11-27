@testable import GraphQL

protocol Character {
    var id: String { get }
}

struct Human: Character {
    let id: String

    static func getById(id: String) -> Human? {
        return nil
    }

    func getFriends() -> [Character] {
        return []
    }
}

struct Droid: Character {
    let id: String

    static func getById(id: String) -> Droid? {
        return nil
    }

    func getFriends() -> [Character] {
        return []
    }
}

struct Episode {
    func getHero() -> Character {
        return Human.getById("luke")!
    }
}

let starWarsSchema = {
    var characterInterface: SchemaInterface!
    var droidType: SchemaObjectType!
    var humanType: SchemaObjectType!

    let episodeEnum = SchemaEnum(
        name: "Episode",
        description: "One of the films in the Star Wars Trilogy",
        values: [
            "NEWHOPE": SchemaEnumValue(
                value: 4,
                description: "Released in 1977."),
            "EMPIRE": SchemaEnumValue(
                value: 5,
                description: "Released in 1977."),
            "JEDI": SchemaEnumValue(
                value: 6,
                description: "Released in 1977."),
        ])

    let characterInterfaceDefinition = SchemaInterface(
        name: "Character",
        description: "A character in the Star Wars Trilogy",
        fields: { [
            "id": SchemaField(
                type: .NonNull(.String),
                description: "The id of the character."),
            "name": SchemaField(
                type: .String,
                description: "The name of the character."),
            "friends": SchemaField(
                type: .List(.Interface(characterInterface)),
                description: "The friends of the character, or an empty list if they have none."),
            "appearsIn": SchemaField(
                type: .Enum(episodeEnum),
                description: "Which movies they appear in."),
            ] },
        resolveType: { toResolve in
            let character = toResolve as! Character
            return Human.getById(character.id) != nil ? humanType : droidType
    })
    characterInterface = characterInterfaceDefinition

    let humanTypeDefinition = SchemaObjectType(
        name: "Human",
        description: "A humanoid creature in the Star Wars universe.",
        fields: { [
            "id": SchemaField(
                type: .NonNull(.String),
                description: "The id of the human."),
            "name": SchemaField(
                type: .String,
                description: "The name of the human."),
            "friends": SchemaField(
                type: .List(.Interface(characterInterface)),
                description: "The friends of the human, or an empty list if they have none.",
                resolve: { toResolve in
                    let human = toResolve as! Human
                    return human.getFriends()
            }),
            "appearsIn": SchemaField(
                type: .List(.Enum(episodeEnum)),
                description: "Which movies they appear in."),
            "homePlanet": SchemaField(
                type: .String,
                description: "The home planet of the human, or null if unknown.")
            ] },
        interfaces: [characterInterface])
    humanType = humanTypeDefinition

    let droidTypeDefinition = SchemaObjectType(
        name: "Droid",
        description: "A mechanical creature in the Star Wars universe.",
        fields: { [
            "id": SchemaField(
                type: .NonNull(.String),
                description: "The id of the droid."),
            "name": SchemaField(
                type: .String,
                description: "The name of the droid."),
            "friends": SchemaField(
                type: .List(.Interface(characterInterface)),
                description: "The friends of the droid, or an empty list if they have none.",
                resolve: { toResolve in
                    let droid = toResolve as! Droid
                    return droid.getFriends()
            }),
            "appearsIn": SchemaField(
                type: .List(.Enum(episodeEnum)),
                description: "Which movies they appear in."),
            "primaryFunction": SchemaField(
                type: .String,
                description: "The primary function of the droid."),
            ] },
        
        interfaces: [characterInterface])
    droidType = droidTypeDefinition

    let queryType = SchemaObjectType(
        name: "Query",
        fields: { [
            "hero": SchemaField(
                type: .Interface(characterInterface),
                arguments: [
                    "episode": (
                        type: .Enum(episodeEnum),
                        description: "If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode."
                    )
                ],
                resolve: { toResolve in
                    let episode = toResolve as! Episode
                    return episode.getHero()
                }
            ),
            "human": SchemaField(
                type: .Object(humanType),
                arguments: [
                    "id": (
                        type: .NonNull(.String),
                        description: "id of the human"
                    )
                ],
                resolve: { toResolve in
                    let id = toResolve as! String
                    return Human.getById(id)
                }
            ),
            "droid": SchemaField(
                type: .Object(droidType),
                arguments: [
                    "id": (
                        type: .NonNull(.String),
                        description: "id of the droid"
                    )
                ],
                resolve: { toResolve in
                    let id = toResolve as! String
                    return Droid.getById(id)
                }
            ),
            ] })
}



