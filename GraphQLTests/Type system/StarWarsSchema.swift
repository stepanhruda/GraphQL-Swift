import GraphQL

let starWarsSchema = { () -> Schema in
    var characterInterface: SchemaInterface!
    var droidType: SchemaObject!
    var humanType: SchemaObject!

    let episodeEnum = SchemaEnum<Movie>(
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

    let characterInterfaceDefinition = SchemaInterface(
        name: "Character",
        description: "A character in the Star Wars Trilogy",
        fields: { [
            SchemaObjectField(
                name: "id",
                type: NonNull(StringType()),
                description: "The id of the character."),
            SchemaObjectField(
                name: "name",
                type: StringType(),
                description: "The name of the character."),
            SchemaObjectField(
                name: "friends",
                type: List(characterInterface),
                description: "The friends of the character, or an empty list if they have none."),
            SchemaObjectField(
                name: "appearsIn",
                type: episodeEnum,
                description: "Which movies they appear in."),
            ] },
        resolveType: { toResolve in
            let character = toResolve as! Character
            return Human.getById(character.id) != nil ? humanType : droidType })
    characterInterface = characterInterfaceDefinition

    let humanTypeDefinition = SchemaObject(
        name: "Human",
        description: "A humanoid creature in the Star Wars universe.",
        fields: { [
            SchemaObjectField(
                name: "id",
                type: NonNull(StringType()),
                description: "The id of the human."),
            SchemaObjectField(
                name: "name",
                type: StringType(),
                description: "The name of the human."),
            SchemaObjectField(
                name: "friends",
                type: List(characterInterface),
                description: "The friends of the human, or an empty list if they have none.",
                resolve: { toResolve in
                    let human = toResolve as! Human
                    return human.getFriends() }),
            SchemaObjectField(
                name: "appearsIn",
                type: List(episodeEnum),
                description: "Which movies they appear in."),
            SchemaObjectField(
                name: "homePlanet",
                type: StringType(),
                description: "The home planet of the human, or null if unknown.")
            ] },
        interfaces: [characterInterface])
    humanType = humanTypeDefinition

    let droidTypeDefinition = SchemaObject(
        name: "Droid",
        description: "A mechanical creature in the Star Wars universe.",
        fields: { [
            SchemaObjectField(
                name: "id",
                type: NonNull(StringType()),
                description: "The id of the droid."),
            SchemaObjectField(
                name: "name",
                type: StringType(),
                description: "The name of the droid."),
            SchemaObjectField(
                name: "friends",
                type: List(characterInterface),
                description: "The friends of the droid, or an empty list if they have none.",
                resolve: { toResolve in
                    let droid = toResolve as! Droid
                    return droid.getFriends()
            }),
            SchemaObjectField(
                name: "appearsIn",
                type: List(episodeEnum),
                description: "Which movies they appear in."),
            SchemaObjectField(
                name: "primaryFunction",
                type: StringType(),
                description: "The primary function of the droid."),
            ] },

        interfaces: [characterInterface])
    droidType = droidTypeDefinition

    let queryType = SchemaObject(
        name: "Query",
        fields: { [
            SchemaObjectField(
                name: "hero",
                type: characterInterface,
                arguments: [
                    SchemaInputValue(
                        name: "episode",
                        type: episodeEnum,
                        description: "If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode."
                    ),
                ],
                resolve: { toResolve in
                    let episode = toResolve as! Episode
                    return episode.getHero()
                }
            ),
            SchemaObjectField(
                name: "human",
                type: humanType,
                arguments: [
                    SchemaInputValue(
                        name: "id",
                        type: NonNull(StringType()),
                        description: "id of the human"),
                ],
                resolve: { toResolve in
                    let id = toResolve as! String
                    return Human.getById(id)
                }
            ),
            SchemaObjectField(
                name: "droid",
                type: droidType,
                arguments: [
                    SchemaInputValue(
                        name: "id",
                        type: NonNull(StringType()),
                        description: "id of the droid"),
                ],
                resolve: { toResolve in
                    let id = toResolve as! String
                    return Droid.getById(id)
                }
            ),
            ] })

    return Schema(queryType: queryType)
}()
