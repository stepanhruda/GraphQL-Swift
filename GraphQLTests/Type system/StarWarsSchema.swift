import GraphQL

let starWarsSchema = { () -> Schema in
    var characterInterface: SchemaInterface<Character>!
    var droidType: SchemaObject<Droid>!
    var humanType: SchemaObject<Human>!
  
    let episodeEnum = SchemaEnum<Episode>(
        name: "Episode",
        description: "One of the films in the Star Wars Trilogy",
        values: [
            SchemaEnumValue(
                value: .NewHope,
                description: "Released in 1977."),
            SchemaEnumValue(
                value: .EmpireStrikesBack,
                description: "Released in 1980."),
            SchemaEnumValue(
                value: .ReturnOfTheJedi,
                description: "Released in 1983."),
        ])

    let characterInterfaceDefinition = SchemaInterface<Character>(
        name: "Character",
        description: "A character in the Star Wars Trilogy",
        fields: { [
            SchemaObjectField(
                name: "id",
                swiftType: String.self,
                description: "The id of the character.",
                resolve: { $0.id }),
            SchemaObjectField(
                name: "name",
                swiftType: Optional<String>.self,
                description: "The name of the character.",
                resolve: { $0.name }),
            SchemaObjectField(
                name: "friends",
                swiftType: [Character].self,
                description: "The friends of the character, or an empty list if they have none.",
                resolve: { $0.getFriends() }),
            SchemaObjectField(
                name: "appearsIn",
                swiftType: [Episode].self,
                description: "Which movies they appear in.",
                resolve: { $0.appearsIn }),
        ] },
        resolveType: { character in
            let matchingType: AnySchemaObject = Human.getById(character.id) != nil ? humanType : droidType
            return matchingType })
    characterInterface = characterInterfaceDefinition
//
//    let humanTypeDefinition = SchemaObject<Human>(
//        name: "Human",
//        description: "A humanoid creature in the Star Wars universe.",
//        fields: { [
//            SchemaObjectField(
//                name: "id",
//                swiftType: String.self,
//                description: "The id of the human.",
//                resolve: { $0.id }),
//            SchemaObjectField(
//                name: "name",
//                swiftType: Optional<String>.self,
//                description: "The name of the human.",
//                resolve: { $0.name }),
//            SchemaObjectField(
//                name: "friends",
//                swiftType: [Character].self,
//                description: "The friends of the human, or an empty list if they have none.",
//                resolve: { $0.getFriends() }),
//            SchemaObjectField(
//                name: "appearsIn",
//                swiftType: [Episode].self,
//                description: "Which movies they appear in.",
//                resolve: { $0.appearsIn }),
//            SchemaObjectField(
//                name: "homePlanet",
//                swiftType: Optional<String>.self,
//                description: "The home planet of the human, or null if unknown.",
//                resolve: { $0.homePlanet }),
//            ] },
//        interfaces: [characterInterface])
//    humanType = humanTypeDefinition
//
//
//    let droidTypeDefinition = SchemaObject<Droid>(
//        name: "Droid",
//        description: "A mechanical creature in the Star Wars universe.",
//        fields: { [
//            SchemaObjectField(
//                name: "id",
//                swiftType: String.self,
//                description: "The id of the droid.",
//                resolve: { $0.id }),
//            SchemaObjectField(
//                name: "name",
//                swiftType: Optional<String>.self,
//                description: "The name of the droid.",
//                resolve: { $0.name }),
//            SchemaObjectField(
//                name: "friends",
//                swiftType: [Character].self,
//                description: "The friends of the droid, or an empty list if they have none.",
//                resolve: { $0.getFriends() }),
//            SchemaObjectField(
//                name: "appearsIn",
//                swiftType: [Episode].self,
//                description: "Which movies they appear in.",
//                resolve: { $0.appearsIn }),
//            SchemaObjectField(
//                name: "primaryFunction",
//                swiftType: Optional<String>.self,
//                description: "The primary function of the droid.",
//                resolve: { $0.primaryFunction }),
//            ] },
//
//        interfaces: [characterInterface])
//    droidType = droidTypeDefinition

    let queryType = SchemaObject<Query>(
        name: "Query",
        fields: { [
//            SchemaObjectField(
//                name: "hero",
//                swiftType: Character.self,
//                arguments: [
//                    SchemaInputValue(
//                        name: "episode",
//                        type: episodeEnum,
//                        description: "If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode."
//                    ),
//                ],
//                resolve: { toResolve in
//                    return undefined()
//                    let episode = toResolve as! Episode
//                    return episode.getHero()
//                }
//            ),
//            SchemaObjectField(
//                name: "human",
//                swiftType: Human.self,
//                arguments: [
//                    SchemaInputValue(
//                        name: "id",
//                        type: NonNull(StringType()),
//                        description: "id of the human"),
//                ],
//                resolve: { toResolve in
//                    return undefined()
//                    let id = toResolve as! String
//                    return Human.getById(id)
//                }
//            ),
//            SchemaObjectField(
//                name: "droid",
//                swiftType: Droid.self,
//                arguments: [
//                    SchemaInputValue(
//                        name: "id",
//                        type: NonNull(StringType()),
//                        description: "id of the droid"),
//                ],
//                resolve: { toResolve in
//                    return undefined()
//                    let id = toResolve as! String
//                    return Droid.getById(id)
//                }
//            ),
            ] })

    return Schema(queryType: undefined())
}()
