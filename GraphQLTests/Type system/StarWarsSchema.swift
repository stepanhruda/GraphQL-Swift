import GraphQL

let starWarsSchema = { () -> Schema in
    var characterInterface: SchemaInterface!
    var droidType: SchemaObjectType!
    var humanType: SchemaObjectType!

    let episodeEnum = SchemaEnum(
        name: "Episode",
        description: "One of the films in the Star Wars Trilogy",
        values: [
            SchemaEnumValue(
                value: Movie.NewHope.rawValue,
                description: "Released in 1977."),
            SchemaEnumValue(
                value: Movie.EmpireStrikesBack.rawValue,
                description: "Released in 1980."),
            SchemaEnumValue(
                value: Movie.ReturnOfTheJedi.rawValue,
                description: "Released in 1983."),
        ])

    let characterInterfaceDefinition = SchemaInterface(
        name: "Character",
        description: "A character in the Star Wars Trilogy",
        fields: { [
            SchemaObjectField(
                name: "id",
                type: .NonNull(.Scalar(.String)),
                description: "The id of the character."),
            SchemaObjectField(
                name: "name",
                type: .Scalar(.String),
                description: "The name of the character."),
            SchemaObjectField(
                name: "friends",
                type: .List(.Interface(characterInterface)),
                description: "The friends of the character, or an empty list if they have none."),
            SchemaObjectField(
                name: "appearsIn",
                type: .Enum(episodeEnum),
                description: "Which movies they appear in."),
            ] },
        resolveType: { toResolve in
            let character = toResolve as! Character
            return Human.getById(character.id) != nil ? humanType : droidType })
    characterInterface = characterInterfaceDefinition

    let humanTypeDefinition = SchemaObjectType(
        name: "Human",
        description: "A humanoid creature in the Star Wars universe.",
        fields: { [
            SchemaObjectField(
                name: "id",
                type: .NonNull(.Scalar(.String)),
                description: "The id of the human."),
            SchemaObjectField(
                name: "name",
                type: .Scalar(.String),
                description: "The name of the human."),
            SchemaObjectField(
                name: "friends",
                type: .List(.Interface(characterInterface)),
                description: "The friends of the human, or an empty list if they have none.",
                resolve: { toResolve in
                    let human = toResolve as! Human
                    return human.getFriends() }),
            SchemaObjectField(
                name: "appearsIn",
                type: .List(.Enum(episodeEnum)),
                description: "Which movies they appear in."),
            SchemaObjectField(
                name: "homePlanet",
                type: .Scalar(.String),
                description: "The home planet of the human, or null if unknown.")
            ] },
        interfaces: [characterInterface])
    humanType = humanTypeDefinition

    let droidTypeDefinition = SchemaObjectType(
        name: "Droid",
        description: "A mechanical creature in the Star Wars universe.",
        fields: { [
            SchemaObjectField(
                name: "id",
                type: .NonNull(.Scalar(.String)),
                description: "The id of the droid."),
            SchemaObjectField(
                name: "name",
                type: .Scalar(.String),
                description: "The name of the droid."),
            SchemaObjectField(
                name: "friends",
                type: .List(.Interface(characterInterface)),
                description: "The friends of the droid, or an empty list if they have none.",
                resolve: { toResolve in
                    let droid = toResolve as! Droid
                    return droid.getFriends()
            }),
            SchemaObjectField(
                name: "appearsIn",
                type: .List(.Enum(episodeEnum)),
                description: "Which movies they appear in."),
            SchemaObjectField(
                name: "primaryFunction",
                type: .Scalar(.String),
                description: "The primary function of the droid."),
            ] },
        
        interfaces: [characterInterface])
    droidType = droidTypeDefinition

    let queryType = SchemaObjectType(
        name: "Query",
        fields: { [
            SchemaObjectField(
                name: "hero",
                type: .Interface(characterInterface),
                arguments: [
                    SchemaInputValue(
                        name: "episode",
                        type: .Enum(episodeEnum),
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
                type: .Object(humanType),
                arguments: [
                    SchemaInputValue(
                        name: "id",
                        type: .NonNull(.Scalar(.String)),
                        description: "id of the human"),
                ],
                resolve: { toResolve in
                    let id = toResolve as! String
                    return Human.getById(id)
                }
            ),
            SchemaObjectField(
                name: "droid",
                type: .Object(droidType),
                arguments: [
                    SchemaInputValue(
                        name: "id",
                        type: .NonNull(.Scalar(.String)),
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
