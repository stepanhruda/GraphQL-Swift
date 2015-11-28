enum Movie: String {
    case NewHope = "NEWHOPE"
    case EmpireStrikesBack = "EMPIRE"
    case ReturnOfTheJedi = "JEDI"
}

let luke = Human(
    id: "1000",
    name: "Luke Skywalker",
    friends: ["1002", "1003", "2000", "2001"],
    appearsIn: [.NewHope, .EmpireStrikesBack, .ReturnOfTheJedi],
    homePlanet: "Tatooine"
)

let vader = Human(
    id: "1001",
    name: "Darth Vader",
    friends: ["1004"],
    appearsIn: [.NewHope, .EmpireStrikesBack, .ReturnOfTheJedi],
    homePlanet: "Tatooine"
)

let han = Human(
    id: "1002",
    name: "Han Solo",
    friends: ["1000", "1003", "2001"],
    appearsIn: [.NewHope, .EmpireStrikesBack, .ReturnOfTheJedi]
)

let leia = Human(
    id: "1003",
    name: "Leia Organa",
    friends: ["1000", "1002", "2000", "2001"],
    appearsIn: [.NewHope, .EmpireStrikesBack, .ReturnOfTheJedi],
    homePlanet: "Alderaan"
)

let tarkin = Human(
    id: "1004",
    name: "Wilhuff Tarkin",
    friends: ["1001"],
    appearsIn: [.NewHope],
    homePlanet: "Tatooine"
)

let humanTable = [
    "1000": luke,
    "1001": vader,
    "1002": han,
    "1003": leia,
    "1004": tarkin,
]

let threepio = Droid(
    id: "2000",
    name: "C-3PO",
    friends: ["1000", "1002", "1003", "2001"],
    appearsIn: [.NewHope, .EmpireStrikesBack, .ReturnOfTheJedi],
    primaryFunction: "Protocol"
)

let artoo = Droid(
    id: "2001",
    name: "R2-D2",
    friends: ["1000", "1002", "1003"],
    appearsIn: [.NewHope, .EmpireStrikesBack, .ReturnOfTheJedi],
    primaryFunction: "Astromech"
)

let droidTable = [
    "2000": threepio,
    "2001": artoo,
]