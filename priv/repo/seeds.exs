# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FantasyBb.Repo.insert!(%FantasyBb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FantasyBb.Repo
alias FantasyBb.Data.Schema.DraftPick
alias FantasyBb.Data.Schema.Event
alias FantasyBb.Data.Schema.EventType
alias FantasyBb.Data.Schema.EvictionCeremony
alias FantasyBb.Data.Schema.EvictionVote
alias FantasyBb.Data.Schema.Houseguest
alias FantasyBb.Data.Schema.JuryVote
alias FantasyBb.Data.Schema.League
alias FantasyBb.Data.Schema.Player
alias FantasyBb.Data.Schema.Rule
alias FantasyBb.Data.Schema.Scorable
alias FantasyBb.Data.Schema.Season
alias FantasyBb.Data.Schema.Team
alias FantasyBb.Data.Schema.User
alias FantasyBb.Data.Schema.Week

defmodule Seeds do
  def create_scorable(name, description, default_point_value \\ 0) do
    IO.puts("Creating scorable: #{name}")

    scorable =
      Scorable.changeset(%Scorable{}, %{
        name: name,
        description: description,
        default_point_value: default_point_value
      })

    Repo.insert!(scorable)
  end

  def create_event_type(name) do
    IO.puts("Creating event type: #{name}")

    event_type = EventType.changeset(%EventType{}, %{name: name})

    Repo.insert!(event_type)
  end

  def build_season(start, title, houseguests, week_count) do
    IO.puts("Creating season: #{title}")

    season = Season.changeset(%Season{}, %{start: start, title: title})

    season = Repo.insert!(season)

    {
      season,
      Enum.map(houseguests, &add_houseguest(&1, season.id)),
      Enum.map(1..week_count, &add_week(&1, season.id))
    }
  end

  defp add_houseguest(houseguest, season_id) do
    player =
      create_player(
        houseguest.first_name,
        houseguest.last_name,
        houseguest.nickname,
        houseguest.hometown,
        houseguest.birthday
      )

    IO.puts("Creating houseguest: #{houseguest.first_name} #{houseguest.last_name}")

    hg =
      Houseguest.changeset(%Houseguest{}, %{
        season_id: season_id,
        player_id: player.id
      })

    Repo.insert!(hg)
  end

  defp add_week(week_number, season_id) do
    IO.puts("Creating week #{week_number}")

    week = Week.changeset(%Week{}, %{season_id: season_id, week_number: week_number})

    Repo.insert!(week)
  end

  def create_player(first_name, last_name, nickname, hometown, birthday) do
    IO.puts("Creating player: #{first_name} #{last_name}")

    player =
      Player.changeset(%Player{}, %{
        first_name: first_name,
        last_name: last_name,
        nickname: nickname,
        hometown: hometown,
        birthday: birthday
      })

    Repo.insert!(player)
  end

  def create_event(event_type_id, houseguest_id, eviction_ceremony_id, additional_info \\ nil) do
    event =
      Event.changeset(%Event{}, %{
        event_type_id: event_type_id,
        houseguest_id: houseguest_id,
        eviction_ceremony_id: eviction_ceremony_id,
        additional_info: additional_info
      })

    Repo.insert!(event)
  end

  def create_eviction_ceremony(week_id, order) do
    eviction_ceremony =
      EvictionCeremony.changeset(%EvictionCeremony{}, %{week_id: week_id, order: order})

    Repo.insert!(eviction_ceremony)
  end

  def create_vote(eviction_ceremony_id, voter_id, candidate_id) do
    vote =
      EvictionVote.changeset(%EvictionVote{}, %{
        eviction_ceremony_id: eviction_ceremony_id,
        voter_id: voter_id,
        candidate_id: candidate_id
      })

    Repo.insert!(vote)
  end

  def create_jury_vote(season_id, voter_id, candidate_id) do
    vote =
      JuryVote.changeset(%JuryVote{}, %{
        season_id: season_id,
        voter_id: voter_id,
        candidate_id: candidate_id
      })

    Repo.insert!(vote)
  end

  def create_user(first_name, last_name, email) do
    user =
      User.changeset(%User{}, %{
        first_name: first_name,
        last_name: last_name,
        email: email
      })

    Repo.insert!(user)
  end

  def create_league(season_id, commissioner_id, name) do
    league =
      League.changeset(%League{}, %{
        season_id: season_id,
        commissioner_id: commissioner_id,
        name: name
      })

    Repo.insert!(league)
  end

  def create_rule(league_id, scorable_id, point_value) do
    rule =
      Rule.changeset(%Rule{}, %{
        league_id: league_id,
        scorable_id: scorable_id,
        point_value: point_value
      })

    Repo.insert!(rule)
  end

  def create_team(league_id, owner_id, name) do
    team =
      Team.changeset(%Team{}, %{
        league_id: league_id,
        user_id: owner_id,
        name: name
      })

    Repo.insert!(team)
  end

  def draft(team_id, houseguest_id, order) do
    draft_pick =
      DraftPick.changeset(%DraftPick{}, %{
        team_id: team_id,
        houseguest_id: houseguest_id,
        draft_order: order
      })

    Repo.insert!(draft_pick)
  end
end

IO.puts("Seeding database")

IO.puts("Creating scorables")

scorables = %{
  win_hoh:
    Seeds.create_scorable("Win Head of Household", "Win a standard Head of Household.", 10),
  win_hoh_de:
    Seeds.create_scorable(
      "Win Head of Household (double eviction)",
      "Win Head of Household during a double eviction event.",
      15
    ),
  win_hoh_final_round_one:
    Seeds.create_scorable(
      "Win Final Head of Household prelim (Round 1)",
      "Win the first round of the final Head of Household competition."
    ),
  win_hoh_final_round_two:
    Seeds.create_scorable(
      "Win Final Head of Household prelim (Round 2)",
      "Win the second round of the final head of Household competition."
    ),
  win_hoh_final:
    Seeds.create_scorable("Win Final Head of Household", "Win the final Head of Household.", 10),
  win_pov: Seeds.create_scorable("Win Power of Veto", "Win a standard Power of Veto.", 5),
  win_pov_de:
    Seeds.create_scorable(
      "Win Power of Veto (double eviction)",
      "Win Power of Veto during a double eviction event.",
      8
    ),
  win_pov_final:
    Seeds.create_scorable("Win Final Power of Veto", "Win the final Power of Veto.", 5),
  nominated:
    Seeds.create_scorable(
      "Nominated for eviction",
      "Nominated for eviction by the Head of Household (not a replacement nominee).",
      -5
    ),
  nominated_de:
    Seeds.create_scorable(
      "Nominated for eviction (double eviction)",
      "Nominated for eviction by the Head of Household during a double eviction event (not a replacement nominee).",
      -5
    ),
  otb:
    Seeds.create_scorable(
      "Placed on the block",
      "Placed on the block by some means other than nomination.",
      -5
    ),
  veto_self:
    Seeds.create_scorable("Veto self", "Take oneself off the block using Power of Veto."),
  veto_self_de:
    Seeds.create_scorable(
      "Veto self (double eviction)",
      "Take oneself off the block using Power of Veto during a double eviction event."
    ),
  veto_another:
    Seeds.create_scorable(
      "Veto another",
      "Take another houseguest off the block using Power of Veto. The Power of Veto winner was not on the block themself."
    ),
  veto_another_de:
    Seeds.create_scorable(
      "Veto another (double eviction)",
      "Take another houseguest off the block using Power of Veto during a double eviction event. The Power of Veto winner was not on the block themself."
    ),
  veto_another_otb:
    Seeds.create_scorable(
      "Veto another whilst on the block",
      "Take another houseguest off the block using Power of Veto. The Power of Veto winner was on the block themself."
    ),
  veto_another_otb_de:
    Seeds.create_scorable(
      "Veto another whilst on the block (double eviction)",
      "Take another houseguest off the block using Power of Veto during a double eviction event. The Power of Veto winner was on the block themself."
    ),
  veto_none:
    Seeds.create_scorable(
      "Abstain from veto",
      "Power of Veto holder does not take anyone off the block. The Power of Veto winner was not on the block themself."
    ),
  veto_none_de:
    Seeds.create_scorable(
      "Abstain from veto (double eviction)",
      "Power of Veto holder does not take anyone off the block during a double eviction event. The Power of Veto winner was not on the block themself."
    ),
  veto_none_otb:
    Seeds.create_scorable(
      "Abstain from veto whilst on the block",
      "Power of Veto holder does not take anyone off the block. The Power of Veto winner was on the block themself."
    ),
  veto_none_otb_de:
    Seeds.create_scorable(
      "Abstain from veto whilst on the block (double eviction)",
      "Power of Veto holder does not take anyone off the block during a double eviction event. The Power of Veto winner was on the block themself."
    ),
  taken_off:
    Seeds.create_scorable("Taken off the block", "Houseguest has Power of Veto used on them.", 10),
  taken_off_de:
    Seeds.create_scorable(
      "Taken off the block (double eviction)",
      "Houseguest has Power of Veto used on them during a double eviction event.",
      10
    ),
  nominated_as_replacement:
    Seeds.create_scorable(
      "Nominated for eviction as a replacement",
      "Nominated for eviction by the Head of Household as a replacement for a vetoed houseguest.",
      -5
    ),
  nominated_as_replacement_de:
    Seeds.create_scorable(
      "Nominated for eviction as a replacement (double eviction)",
      "Nominated for eviction by the Head of Household as a replacement for a vetoed houseguest during a double eviction event.",
      -5
    ),
  dodge_eviction:
    Seeds.create_scorable("Dodge eviction", "Dodge eviction whilst on the block.", 2),
  dodge_eviction_de:
    Seeds.create_scorable(
      "Dodge eviction (double eviction)",
      "Dodge eviction whilst on the block during a double eviction event.",
      2
    ),
  vote_for_evictee:
    Seeds.create_scorable(
      "Vote for evicted houseguest",
      "Vote for the houseguest that ended up being evicted."
    ),
  vote_for_other:
    Seeds.create_scorable(
      "Vote for non-evicted houseguest",
      "Vote for a houseguest that did not end up being evicted."
    ),
  sole_vote_against_the_house:
    Seeds.create_scorable(
      "Sole vote against the house",
      "Provide the only vote for a non-evicted houseguest when all other votes were for the evicted houseguest.",
      5
    ),
  reenter:
    Seeds.create_scorable("Return to the house", "Return to the house after being evicted.", 20),
  americas_choice:
    Seeds.create_scorable("Win America's choice", "Win an America's choice vote.", 2),
  survive_the_week:
    Seeds.create_scorable(
      "Survive the week",
      "Remain in the house at the conclusion of the week.",
      2
    ),
  win_comp:
    Seeds.create_scorable(
      "Win miscellaneous competition.",
      "Win a competition that does not fall under any other category."
    ),
  win_bb:
    Seeds.create_scorable(
      "Win Big Brother",
      "Win the Big Brother game at the conclusion of the season.",
      45
    ),
  place_bb:
    Seeds.create_scorable(
      "Second place finish",
      "Come in second place at the conclusion of the season.",
      30
    ),
  show_bb:
    Seeds.create_scorable(
      "Third place finish",
      "Be the final jury member at the conclusion of the season.",
      20
    ),
  win_afp:
    Seeds.create_scorable(
      "Win America's favorite player",
      "Win the vote for America's favorite player at the conclusion of the season."
    ),
  evict_self: Seeds.create_scorable("Self-evicted", "Evict oneself from the house."),
  removed:
    Seeds.create_scorable(
      "Removed from the house",
      "Removed by Big Brother production for any reason."
    ),
  evicted: Seeds.create_scorable("Evicted", "Voted out of the house by fellow houseguests."),
  evicted_de:
    Seeds.create_scorable(
      "Evicted (double eviction)",
      "Voted out of the house by fellow houseguests during a double eviction event."
    ),
  make_jury:
    Seeds.create_scorable(
      "Make jury",
      "Vote in the final jury or be one of the houseguests being voted on.",
      10
    ),
  vote_for_winner:
    Seeds.create_scorable("Vote for winner", "Cast one's jury vote for the Big Brother winner."),
  vote_for_loser:
    Seeds.create_scorable("Vote for loser", "Cast one's jury vote for the Big Brother loser."),
  survive_eviction:
    Seeds.create_scorable("Survive eviction", "Remain in the house after an eviction ceremony.")
}

IO.puts("Creating event types")
hoh = Seeds.create_event_type("HeadOfHousehold")
final_hoh_1 = Seeds.create_event_type("FinalHeadOfHouseholdRound1")
final_hoh_2 = Seeds.create_event_type("FinalHeadOfHouseholdRound2")
pov = Seeds.create_event_type("PowerOfVeto")
nom = Seeds.create_event_type("Nomination")
otb = Seeds.create_event_type("OnTheBlock")
taken_off = Seeds.create_event_type("OffTheBlock")
replacement_nom = Seeds.create_event_type("ReplacementNomination")
return_to_house = Seeds.create_event_type("Return")
americas_choice = Seeds.create_event_type("AmericasChoice")
win_comp = Seeds.create_event_type("CompetitionWinner")
win_afp = Seeds.create_event_type("AmericasFavoritePlayer")
evict_self = Seeds.create_event_type("SelfEviction")
removed = Seeds.create_event_type("Removal")

season_19_houseguests = [
  %{
    first_name: "Alexandra",
    last_name: "Ow",
    nickname: "Alex",
    birthday: ~D[1988-12-20],
    hometown: "Thousand Oaks, CA"
  },
  %{
    first_name: "Cameron",
    last_name: "Heard",
    nickname: nil,
    birthday: ~D[1992-08-27],
    hometown: "North Aurora, IL"
  },
  %{
    first_name: "Christmas",
    last_name: "Abbott",
    nickname: nil,
    birthday: ~D[1981-12-20],
    hometown: "Lynchburg, VA"
  },
  %{
    first_name: "Cody",
    last_name: "Nickson",
    nickname: nil,
    birthday: ~D[1985-04-13],
    hometown: "Lake Mills, IA"
  },
  %{
    first_name: "Dominique",
    last_name: "Cooper",
    nickname: nil,
    birthday: ~D[1986-07-11],
    hometown: "Tuskegee, AL"
  },
  %{
    first_name: "Elena",
    last_name: "Davies",
    nickname: nil,
    birthday: ~D[1990-08-19],
    hometown: "Fort Worth, TX"
  },
  %{
    first_name: "Jason",
    last_name: "Dent",
    nickname: nil,
    birthday: ~D[1979-07-12],
    hometown: "Humeston, IA"
  },
  %{
    first_name: "Jessica",
    last_name: "Graf",
    nickname: nil,
    birthday: ~D[1990-12-11],
    hometown: "Cranston, RI"
  },
  %{
    first_name: "Jillian",
    last_name: "Parker",
    nickname: nil,
    birthday: ~D[1993-05-12],
    hometown: "Celebration, FL"
  },
  %{
    first_name: "Joshua",
    last_name: "Martinez",
    nickname: "Josh",
    birthday: ~D[1994-01-04],
    hometown: "Miami, FL"
  },
  %{
    first_name: "Kevin",
    last_name: "Schlehuber",
    nickname: nil,
    birthday: ~D[1961-08-07],
    hometown: "Boston, MA"
  },
  %{
    first_name: "Mark",
    last_name: "Jansen",
    nickname: nil,
    birthday: ~D[1991-06-13],
    hometown: "Grand Island, NY"
  },
  %{
    first_name: "Matthew",
    last_name: "Clines",
    nickname: "Matt",
    birthday: nil,
    hometown: "Arlington, VA"
  },
  %{
    first_name: "Megan",
    last_name: "Lowder",
    nickname: nil,
    birthday: ~D[1989-03-07],
    hometown: "Cathedral City, CA"
  },
  %{
    first_name: "Paul",
    last_name: "Abrahamian",
    nickname: nil,
    birthday: ~D[1993-06-13],
    hometown: "Tarzana, CA"
  },
  %{
    first_name: "Ramses",
    last_name: "Soto",
    nickname: nil,
    birthday: ~D[1995-12-18],
    hometown: "Grand Rapids, MI"
  },
  %{
    first_name: "Raven",
    last_name: "Walton",
    nickname: nil,
    birthday: ~D[1994-06-10],
    hometown: "DeValls Bluff, AR"
  }
]

season_20_houseguests = [
  %{
    first_name: "Angela",
    last_name: "Rummans",
    nickname: nil,
    birthday: ~D[1992-03-23],
    hometown: "Hilton Head, CA"
  },
  %{
    first_name: "Angie",
    last_name: "Lantry",
    nickname: "Rockstar",
    birthday: ~D[1983-06-22],
    hometown: "Columbia, MD"
  },
  %{
    first_name: "Bayleigh",
    last_name: "Dayton",
    nickname: nil,
    birthday: ~D[1993-05-25],
    hometown: "Lee's Summit, MO"
  },
  %{
    first_name: "Brett",
    last_name: "Robinson",
    nickname: nil,
    birthday: nil,
    hometown: "Oakdale, CT"
  },
  %{
    first_name: "Christopher",
    last_name: "Williams",
    nickname: "Swaggy C",
    birthday: ~D[1995-02-17],
    hometown: "Bridgeport, CT"
  },
  %{
    first_name: "Faysal",
    last_name: "Shafaat",
    nickname: nil,
    birthday: ~D[1991-10-17],
    hometown: "Orlando, FL"
  },
  %{
    first_name: "Haleigh",
    last_name: "Broucher",
    nickname: nil,
    birthday: ~D[1997-01-23],
    hometown: "Village Mills, TX"
  },
  %{
    first_name: "Joseph",
    last_name: "Mounduix",
    nickname: "JC",
    birthday: ~D[1990-02-06],
    hometown: "Miami, FL"
  },
  %{
    first_name: "Kaitlyn",
    last_name: "Herman",
    nickname: nil,
    birthday: ~D[1994-04-24],
    hometown: "Plainview, NY"
  },
  %{
    first_name: "Kaycee",
    last_name: "Clark",
    nickname: nil,
    birthday: ~D[1987-12-26],
    hometown: "San Diego, CA"
  },
  %{
    first_name: "Rachel",
    last_name: "Swindler",
    nickname: nil,
    birthday: ~D[1988-07-15],
    hometown: "Myrtle Beach, SC"
  },
  %{
    first_name: "Samantha",
    last_name: "Bledsoe",
    nickname: "Sam",
    birthday: nil,
    hometown: "Stuarts Draft, VA"
  },
  %{
    first_name: "Scottie",
    last_name: "Salton",
    nickname: nil,
    birthday: ~D[1992-01-10],
    hometown: "Shorewood, IL"
  },
  %{
    first_name: "Stephen",
    last_name: "Arienta",
    nickname: "Steve",
    birthday: ~D[1978-05-02],
    hometown: "Parsippany, NJ"
  },
  %{
    first_name: "Tyler",
    last_name: "Crispen",
    nickname: nil,
    birthday: ~D[1995-02-18],
    hometown: "Rossford, OH"
  },
  %{
    first_name: "Winston",
    last_name: "Hines",
    nickname: nil,
    birthday: nil,
    hometown: "Somerset, KY"
  }
]

{season_19, houseguests_19, weeks_19} =
  Seeds.build_season(~D[2017-06-28], "Big Brother 19", season_19_houseguests, 14)

{season_20, houseguests_20, weeks_20} =
  Seeds.build_season(~D[2018-06-27], "Big Brother 20", season_20_houseguests, 10)

[
  alex,
  cameron,
  christmas,
  cody,
  dom,
  elena,
  jason,
  jessica,
  jillian,
  josh,
  kevin,
  mark,
  matt,
  megan,
  paul,
  ramses,
  raven
] = houseguests_19

[
  angela,
  rockstar,
  bayleigh,
  brett,
  swaggy,
  faysal,
  haleigh,
  jc,
  kaitlyn,
  kaycee,
  rachel,
  sam,
  scottie,
  steve,
  tyler,
  winston
] = houseguests_20

eviction_ceremonies_19 = Enum.map(weeks_19, &Seeds.create_eviction_ceremony(&1.id, 1))
eviction_ceremonies_20 = Enum.map(weeks_20, &Seeds.create_eviction_ceremony(&1.id, 1))

get_ceremony_19 = fn week ->
  Enum.fetch!(eviction_ceremonies_19, week)
end

get_ceremony_20 = fn week ->
  Enum.fetch!(eviction_ceremonies_20, week)
end

# Season 19
IO.puts("Seeding season 19")

# Week 1
IO.puts("Seeding week 1")

Seeds.create_event(
  win_comp.id,
  kevin.id,
  get_ceremony_19.(0).id,
  "Garden of Temptation. Kevin won $25,000 by being the first to press the button. This allowed Paul to enter the house and triggered the Tempted by the Fruit competition which, in turn, resulted in the first eviction ceremony. Also, Kevin became ineligible to win the first Head of Household."
)

Seeds.create_event(
  win_comp.id,
  cody.id,
  get_ceremony_19.(0).id,
  "Tempted by the Fruit. Cody was the last houseguest standing."
)

Seeds.create_event(nom.id, christmas.id, get_ceremony_19.(0).id)
Seeds.create_event(nom.id, cameron.id, get_ceremony_19.(0).id)
Seeds.create_event(nom.id, jillian.id, get_ceremony_19.(0).id)

Seeds.create_vote(get_ceremony_19.(0).id, josh.id, christmas.id)
Seeds.create_vote(get_ceremony_19.(0).id, kevin.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, alex.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, raven.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, jason.id, christmas.id)
Seeds.create_vote(get_ceremony_19.(0).id, matt.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(0).id, mark.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(0).id, elena.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, cody.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(0).id, jessica.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, ramses.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, dom.id, cameron.id)
Seeds.create_vote(get_ceremony_19.(0).id, megan.id, cameron.id)

# Week 2
IO.puts("Seeding week 2")

Seeds.create_event(
  hoh.id,
  cody.id,
  get_ceremony_19.(1).id,
  "Hangs in the Balance competition. Josh took the golden apple and earned safety for the week, but in doing so eliminated his team from this competition."
)

Seeds.create_event(
  americas_choice.id,
  paul.id,
  get_ceremony_19.(1).id,
  "Paul took the Pendant of Protection inside the Den of Temptation. Ramses was consequently bitten and must place himself on the block as a special third nominee once within the next three eviction ceremonies."
)

Seeds.create_event(nom.id, jillian.id, get_ceremony_19.(1).id)
Seeds.create_event(nom.id, megan.id, get_ceremony_19.(1).id)
Seeds.create_event(evict_self.id, megan.id, get_ceremony_19.(1).id)

Seeds.create_event(
  replacement_nom.id,
  alex.id,
  get_ceremony_19.(1).id,
  "Replacement for Megan's self-eviction."
)

Seeds.create_event(
  pov.id,
  alex.id,
  get_ceremony_19.(1).id,
  "Fin to Win competition. Raven took the gold starfish temptation and kept herself from being a Have-Not for the rest of the season."
)

Seeds.create_event(taken_off.id, alex.id, get_ceremony_19.(1).id)

Seeds.create_event(
  replacement_nom.id,
  christmas.id,
  get_ceremony_19.(1).id,
  "Cody attempted to nominate Paul, but he was protected by the Pendant of Protection."
)

Seeds.create_vote(get_ceremony_19.(1).id, josh.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, paul.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, kevin.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, alex.id, christmas.id)
Seeds.create_vote(get_ceremony_19.(1).id, raven.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, jason.id, christmas.id)
Seeds.create_vote(get_ceremony_19.(1).id, matt.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, mark.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, elena.id, jillian.id)
Seeds.create_vote(get_ceremony_19.(1).id, jessica.id, christmas.id)
Seeds.create_vote(get_ceremony_19.(1).id, ramses.id, christmas.id)
Seeds.create_vote(get_ceremony_19.(1).id, dom.id, jillian.id)

# Week 3
IO.puts("Seeding week 3")
Seeds.create_event(hoh.id, paul.id, get_ceremony_19.(2).id, "Sugar Shot competition.")

Seeds.create_event(
  americas_choice.id,
  christmas.id,
  get_ceremony_19.(2).id,
  "Christmas accepted the Ring of Replacement and cursed Cody, Jessica, and Jason with toad suits."
)

Seeds.create_event(nom.id, alex.id, get_ceremony_19.(2).id)
Seeds.create_event(nom.id, josh.id, get_ceremony_19.(2).id)

Seeds.create_event(
  otb.id,
  ramses.id,
  get_ceremony_19.(2).id,
  "Ramses put himself on the block to fulfill his temptation curse obligation."
)

Seeds.create_event(
  pov.id,
  paul.id,
  get_ceremony_19.(2).id,
  "Path of Least Resistance competition."
)

Seeds.create_event(taken_off.id, josh.id, get_ceremony_19.(2).id)
Seeds.create_event(replacement_nom.id, cody.id, get_ceremony_19.(2).id)

Seeds.create_vote(get_ceremony_19.(2).id, josh.id, cody.id)
Seeds.create_vote(get_ceremony_19.(2).id, christmas.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(2).id, kevin.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(2).id, raven.id, cody.id)
Seeds.create_vote(get_ceremony_19.(2).id, jason.id, cody.id)
Seeds.create_vote(get_ceremony_19.(2).id, matt.id, cody.id)
Seeds.create_vote(get_ceremony_19.(2).id, mark.id, cody.id)
Seeds.create_vote(get_ceremony_19.(2).id, elena.id, cody.id)
Seeds.create_vote(get_ceremony_19.(2).id, jessica.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(2).id, dom.id, cody.id)

# Week 4
IO.puts("Seeding week 4")

Seeds.create_event(
  hoh.id,
  alex.id,
  get_ceremony_19.(3).id,
  "Space Cadets competition. Christmas did not participate due to injury."
)

Seeds.create_event(nom.id, dom.id, get_ceremony_19.(3).id)
Seeds.create_event(nom.id, jessica.id, get_ceremony_19.(3).id)

Seeds.create_event(
  pov.id,
  jason.id,
  get_ceremony_19.(3).id,
  "Temple of Temptation competition. Kevin claimed the temptation and earned $27, but eliminated himself from winning the competition."
)

Seeds.create_event(taken_off.id, nil, get_ceremony_19.(3).id)

Seeds.create_event(
  americas_choice.id,
  jessica.id,
  get_ceremony_19.(3).id,
  "Jessica accepted the Halting Hex temptation. This resulted in a Temptation Competition over each of the next three weeks."
)

Seeds.create_vote(get_ceremony_19.(3).id, josh.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, paul.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, christmas.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, kevin.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, raven.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, jason.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, matt.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, mark.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, elena.id, dom.id)
Seeds.create_vote(get_ceremony_19.(3).id, ramses.id, dom.id)

# Week 5
IO.puts("Seeding week 5")
Seeds.create_event(return_to_house.id, cody.id, get_ceremony_19.(4).id)
Seeds.create_event(hoh.id, jessica.id, get_ceremony_19.(4).id, "What's the Hold Up? competition.")
Seeds.create_event(nom.id, josh.id, get_ceremony_19.(4).id)
Seeds.create_event(nom.id, ramses.id, get_ceremony_19.(4).id)
Seeds.create_event(pov.id, jessica.id, get_ceremony_19.(4).id, "BB Juicy Blast competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_19.(4).id)

Seeds.create_vote(get_ceremony_19.(4).id, paul.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, christmas.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, kevin.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, alex.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, raven.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, jason.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, matt.id, ramses.id)
Seeds.create_vote(get_ceremony_19.(4).id, mark.id, josh.id)
Seeds.create_vote(get_ceremony_19.(4).id, elena.id, josh.id)
Seeds.create_vote(get_ceremony_19.(4).id, cody.id, josh.id)

# Week 6
IO.puts("Seeding week 6")
Seeds.create_event(hoh.id, paul.id, get_ceremony_19.(5).id, "Inked and Evicted competition.")

Seeds.create_event(
  win_comp.id,
  mark.id,
  get_ceremony_19.(5).id,
  "Bowlerina temptation competition. Jason lost and became the third nominee."
)

Seeds.create_event(
  otb.id,
  jason.id,
  get_ceremony_19.(5).id,
  "Jason became the third nominee by losing the Bowlerina temptation competition."
)

Seeds.create_event(nom.id, cody.id, get_ceremony_19.(5).id)
Seeds.create_event(nom.id, jessica.id, get_ceremony_19.(5).id)
Seeds.create_event(pov.id, paul.id, get_ceremony_19.(5).id)
Seeds.create_event(taken_off.id, jason.id, get_ceremony_19.(5).id)

# Week 7
IO.puts("Seeding week 7")
Seeds.create_event(hoh.id, josh.id, get_ceremony_19.(6).id, "Gravestone Golf competition.")

Seeds.create_event(
  win_comp.id,
  cody.id,
  get_ceremony_19.(6).id,
  "Strangest Things temptation competition. Jessica lost and became the third nominee."
)

Seeds.create_event(
  otb.id,
  jessica.id,
  get_ceremony_19.(6).id,
  "Jessica became the third nominee by losing the Strangest Things temptation competition."
)

Seeds.create_event(nom.id, mark.id, get_ceremony_19.(6).id)
Seeds.create_event(nom.id, elena.id, get_ceremony_19.(6).id)

Seeds.create_event(
  pov.id,
  mark.id,
  get_ceremony_19.(6).id,
  "OTEV the Possessed Piglet competition."
)

Seeds.create_event(taken_off.id, mark.id, get_ceremony_19.(6).id)
Seeds.create_event(replacement_nom.id, raven.id, get_ceremony_19.(6).id)

Seeds.create_vote(get_ceremony_19.(6).id, paul.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, christmas.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, kevin.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, alex.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, jason.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, matt.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, mark.id, jessica.id)
Seeds.create_vote(get_ceremony_19.(6).id, cody.id, raven.id)

# Week 8
IO.puts("Seeding week 8")
Seeds.create_event(hoh.id, alex.id, get_ceremony_19.(7).id, "Hocus Focus competition.")

Seeds.create_event(
  win_comp.id,
  mark.id,
  get_ceremony_19.(7).id,
  "Where Were You? temptation competition. Matt lost and became the third nominee."
)

Seeds.create_event(
  otb.id,
  matt.id,
  get_ceremony_19.(7).id,
  "Matt became the third nominee by losing the Where Were You? temptation competition."
)

Seeds.create_event(nom.id, elena.id, get_ceremony_19.(7).id)
Seeds.create_event(nom.id, jason.id, get_ceremony_19.(7).id)
Seeds.create_event(pov.id, matt.id, get_ceremony_19.(7).id, "BB Adventure Tour competition.")
Seeds.create_event(taken_off.id, jason.id, get_ceremony_19.(7).id)
Seeds.create_event(replacement_nom.id, cody.id, get_ceremony_19.(7).id)

Seeds.create_vote(get_ceremony_19.(7).id, josh.id, cody.id)
Seeds.create_vote(get_ceremony_19.(7).id, paul.id, cody.id)
Seeds.create_vote(get_ceremony_19.(7).id, christmas.id, cody.id)
Seeds.create_vote(get_ceremony_19.(7).id, kevin.id, cody.id)
Seeds.create_vote(get_ceremony_19.(7).id, raven.id, cody.id)
Seeds.create_vote(get_ceremony_19.(7).id, jason.id, cody.id)
Seeds.create_vote(get_ceremony_19.(7).id, mark.id, cody.id)

week_8 = Enum.fetch!(weeks_19, 7)
week_8_de_ceremony = Seeds.create_eviction_ceremony(week_8.id, 2)

Seeds.create_event(hoh.id, jason.id, week_8_de_ceremony.id, "Let It Slide competition.")
Seeds.create_event(nom.id, mark.id, week_8_de_ceremony.id)
Seeds.create_event(nom.id, elena.id, week_8_de_ceremony.id)
Seeds.create_event(pov.id, mark.id, week_8_de_ceremony.id, "Kenya-Solve It competition.")
Seeds.create_event(taken_off.id, mark.id, week_8_de_ceremony.id)
Seeds.create_event(replacement_nom.id, matt.id, week_8_de_ceremony.id)

Seeds.create_vote(week_8_de_ceremony.id, josh.id, elena.id)
Seeds.create_vote(week_8_de_ceremony.id, paul.id, elena.id)
Seeds.create_vote(week_8_de_ceremony.id, christmas.id, elena.id)
Seeds.create_vote(week_8_de_ceremony.id, kevin.id, elena.id)
Seeds.create_vote(week_8_de_ceremony.id, alex.id, elena.id)
Seeds.create_vote(week_8_de_ceremony.id, raven.id, elena.id)
Seeds.create_vote(week_8_de_ceremony.id, mark.id, matt.id)

# Week 9
IO.puts("Seeding week 9")

Seeds.create_event(
  hoh.id,
  christmas.id,
  get_ceremony_19.(8).id,
  "Tales from Decrypt competition."
)

Seeds.create_event(nom.id, jason.id, get_ceremony_19.(8).id)
Seeds.create_event(nom.id, matt.id, get_ceremony_19.(8).id)
Seeds.create_event(pov.id, jason.id, get_ceremony_19.(8).id, "Home Zing Home competition.")
Seeds.create_event(taken_off.id, jason.id, get_ceremony_19.(8).id)
Seeds.create_event(replacement_nom.id, mark.id, get_ceremony_19.(8).id)

Seeds.create_vote(get_ceremony_19.(8).id, josh.id, mark.id)
Seeds.create_vote(get_ceremony_19.(8).id, paul.id, mark.id)
Seeds.create_vote(get_ceremony_19.(8).id, kevin.id, mark.id)
Seeds.create_vote(get_ceremony_19.(8).id, alex.id, matt.id)
Seeds.create_vote(get_ceremony_19.(8).id, raven.id, mark.id)
Seeds.create_vote(get_ceremony_19.(8).id, jason.id, matt.id)

# Week 10
IO.puts("Seeding week 10")
Seeds.create_event(hoh.id, jason.id, get_ceremony_19.(9).id, "Everyone's a Wiener competition.")
Seeds.create_event(nom.id, matt.id, get_ceremony_19.(9).id)
Seeds.create_event(nom.id, raven.id, get_ceremony_19.(9).id)
Seeds.create_event(pov.id, jason.id, get_ceremony_19.(9).id, "Hide and Go Veto competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_19.(9).id)

Seeds.create_vote(get_ceremony_19.(9).id, josh.id, matt.id)
Seeds.create_vote(get_ceremony_19.(9).id, paul.id, matt.id)
Seeds.create_vote(get_ceremony_19.(9).id, christmas.id, matt.id)
Seeds.create_vote(get_ceremony_19.(9).id, kevin.id, matt.id)
Seeds.create_vote(get_ceremony_19.(9).id, alex.id, matt.id)
# Penalty vote
Seeds.create_vote(get_ceremony_19.(9).id, nil, matt.id)

# Week 11
IO.puts("Seeding week 11")
Seeds.create_event(hoh.id, christmas.id, get_ceremony_19.(10).id, "Ready, Set, Whoa competition.")
Seeds.create_event(nom.id, alex.id, get_ceremony_19.(10).id)
Seeds.create_event(nom.id, jason.id, get_ceremony_19.(10).id)
Seeds.create_event(pov.id, paul.id, get_ceremony_19.(10).id, "Punch Slap Kick competition.")
Seeds.create_event(taken_off.id, alex.id, get_ceremony_19.(10).id)
Seeds.create_event(replacement_nom.id, kevin.id, get_ceremony_19.(10).id)

Seeds.create_vote(get_ceremony_19.(10).id, josh.id, jason.id)
Seeds.create_vote(get_ceremony_19.(10).id, paul.id, kevin.id)
Seeds.create_vote(get_ceremony_19.(10).id, christmas.id, jason.id)
Seeds.create_vote(get_ceremony_19.(10).id, alex.id, kevin.id)
Seeds.create_vote(get_ceremony_19.(10).id, raven.id, jason.id)

week_11 = Enum.fetch!(weeks_19, 10)
week_11_de_ceremony = Seeds.create_eviction_ceremony(week_11.id, 2)

Seeds.create_event(hoh.id, alex.id, week_11_de_ceremony.id, "Fake News competition.")
Seeds.create_event(nom.id, kevin.id, week_11_de_ceremony.id)
Seeds.create_event(nom.id, raven.id, week_11_de_ceremony.id)
Seeds.create_event(pov.id, josh.id, week_11_de_ceremony.id, "Lime Drop competition.")
Seeds.create_event(taken_off.id, nil, week_11_de_ceremony.id)

Seeds.create_vote(week_11_de_ceremony.id, josh.id, kevin.id)
Seeds.create_vote(week_11_de_ceremony.id, paul.id, raven.id)
Seeds.create_vote(week_11_de_ceremony.id, christmas.id, raven.id)

# Week 12
IO.puts("Seeding week 12")
Seeds.create_event(hoh.id, josh.id, get_ceremony_19.(11).id, "The Revengers competition.")
Seeds.create_event(nom.id, kevin.id, get_ceremony_19.(11).id)
Seeds.create_event(nom.id, alex.id, get_ceremony_19.(11).id)
Seeds.create_event(pov.id, paul.id, get_ceremony_19.(11).id, "BB Comics competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_19.(11).id)

Seeds.create_vote(get_ceremony_19.(11).id, josh.id, alex.id)
Seeds.create_vote(get_ceremony_19.(11).id, paul.id, kevin.id)
Seeds.create_vote(get_ceremony_19.(11).id, christmas.id, alex.id)

# Week 13
IO.puts("Seeding week 13")
Seeds.create_event(hoh.id, paul.id, get_ceremony_19.(12).id, "What the Bleep? competition.")
Seeds.create_event(nom.id, josh.id, get_ceremony_19.(12).id)
Seeds.create_event(nom.id, kevin.id, get_ceremony_19.(12).id)
Seeds.create_event(pov.id, paul.id, get_ceremony_19.(12).id, "Back to the Veto competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_19.(12).id)

Seeds.create_vote(get_ceremony_19.(12).id, christmas.id, kevin.id)

# Week 14
IO.puts("Seeding week 14")

Seeds.create_event(
  final_hoh_1.id,
  paul.id,
  get_ceremony_19.(13).id,
  "Tail of the Unicorn competition."
)

Seeds.create_event(
  final_hoh_2.id,
  josh.id,
  get_ceremony_19.(13).id,
  "Knock 'Em Down competition."
)

Seeds.create_event(
  hoh.id,
  josh.id,
  get_ceremony_19.(13).id,
  "Scales of Just-Us competition."
)

Seeds.create_event(win_afp.id, cody.id, get_ceremony_19.(13).id)
Seeds.create_vote(get_ceremony_19.(13).id, josh.id, christmas.id)

# Jury
IO.puts("Seeding jury votes")
Seeds.create_jury_vote(season_19.id, christmas.id, paul.id)
Seeds.create_jury_vote(season_19.id, kevin.id, paul.id)
Seeds.create_jury_vote(season_19.id, alex.id, josh.id)
Seeds.create_jury_vote(season_19.id, raven.id, paul.id)
Seeds.create_jury_vote(season_19.id, jason.id, josh.id)
Seeds.create_jury_vote(season_19.id, matt.id, paul.id)
Seeds.create_jury_vote(season_19.id, mark.id, josh.id)
Seeds.create_jury_vote(season_19.id, elena.id, josh.id)
Seeds.create_jury_vote(season_19.id, cody.id, josh.id)

# Season 20
IO.puts("Seeding season 20")

# Week 1
IO.puts("Seeding week 1")

Seeds.create_event(
  win_comp.id,
  swaggy.id,
  get_ceremony_20.(0).id,
  "Trash Folder / Houseguest CAPTCHA / Surfing the BB Web Competition. Swaggy beat Angela and guaranteed safety for himself and seven other houseguests."
)

Seeds.create_event(
  hoh.id,
  tyler.id,
  get_ceremony_20.(0).id,
  "Microchip Mayhem competition."
)

Seeds.create_event(nom.id, steve.id, get_ceremony_20.(0).id)
Seeds.create_event(nom.id, sam.id, get_ceremony_20.(0).id)

Seeds.create_event(
  americas_choice.id,
  sam.id,
  get_ceremony_20.(0).id,
  "Sam won Most Trending Houseguest and opted for the Bonus Life power."
)

Seeds.create_event(pov.id, faysal.id, get_ceremony_20.(0).id, "VimeBro Studios competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_20.(0).id)

Seeds.create_vote(get_ceremony_20.(0).id, scottie.id, sam.id)
Seeds.create_vote(get_ceremony_20.(0).id, jc.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, swaggy.id, sam.id)
Seeds.create_vote(get_ceremony_20.(0).id, bayleigh.id, sam.id)
Seeds.create_vote(get_ceremony_20.(0).id, rachel.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, kaycee.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, faysal.id, sam.id)
Seeds.create_vote(get_ceremony_20.(0).id, haleigh.id, sam.id)
Seeds.create_vote(get_ceremony_20.(0).id, angela.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, brett.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, winston.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, kaitlyn.id, steve.id)
Seeds.create_vote(get_ceremony_20.(0).id, rockstar.id, sam.id)

# Week 2
IO.puts("Seeding week 2")

Seeds.create_event(
  hoh.id,
  kaitlyn.id,
  get_ceremony_20.(1).id,
  "Land a Job competition."
)

Seeds.create_event(
  americas_choice.id,
  tyler.id,
  get_ceremony_20.(1).id,
  "Tyler won Most Trending Houseguest and opted for the The Cloud power."
)

Seeds.create_event(nom.id, scottie.id, get_ceremony_20.(1).id)
Seeds.create_event(nom.id, winston.id, get_ceremony_20.(1).id)
Seeds.create_event(pov.id, tyler.id, get_ceremony_20.(1).id, "Houseguestsonly.com competition.")
Seeds.create_event(taken_off.id, scottie.id, get_ceremony_20.(1).id)
Seeds.create_event(replacement_nom.id, swaggy.id, get_ceremony_20.(1).id)

Seeds.create_vote(get_ceremony_20.(1).id, bayleigh.id, winston.id)
Seeds.create_vote(get_ceremony_20.(1).id, brett.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, kaycee.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, tyler.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, rockstar.id, winston.id)
Seeds.create_vote(get_ceremony_20.(1).id, haleigh.id, winston.id)
Seeds.create_vote(get_ceremony_20.(1).id, faysal.id, winston.id)
Seeds.create_vote(get_ceremony_20.(1).id, scottie.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, jc.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, angela.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, rachel.id, swaggy.id)
Seeds.create_vote(get_ceremony_20.(1).id, sam.id, swaggy.id)

# Week 3
IO.puts("Seeding week 3")

Seeds.create_event(
  hoh.id,
  scottie.id,
  get_ceremony_20.(2).id,
  "Product launch competition."
)

Seeds.create_event(
  americas_choice.id,
  bayleigh.id,
  get_ceremony_20.(2).id,
  "Bayleigh won Most Trending Houseguest and opted for the Identity Theft power."
)

Seeds.create_event(nom.id, brett.id, get_ceremony_20.(2).id)
Seeds.create_event(nom.id, winston.id, get_ceremony_20.(2).id)
Seeds.create_event(pov.id, scottie.id, get_ceremony_20.(2).id, "Mamma Mia! Madness competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_20.(2).id)

Seeds.create_vote(get_ceremony_20.(2).id, kaitlyn.id, brett.id)
Seeds.create_vote(get_ceremony_20.(2).id, rachel.id, winston.id)
Seeds.create_vote(get_ceremony_20.(2).id, kaycee.id, winston.id)
Seeds.create_vote(get_ceremony_20.(2).id, rockstar.id, brett.id)
Seeds.create_vote(get_ceremony_20.(2).id, faysal.id, brett.id)
Seeds.create_vote(get_ceremony_20.(2).id, bayleigh.id, brett.id)
Seeds.create_vote(get_ceremony_20.(2).id, angela.id, winston.id)
Seeds.create_vote(get_ceremony_20.(2).id, haleigh.id, brett.id)
Seeds.create_vote(get_ceremony_20.(2).id, jc.id, winston.id)
Seeds.create_vote(get_ceremony_20.(2).id, tyler.id, winston.id)
Seeds.create_vote(get_ceremony_20.(2).id, sam.id, winston.id)

# Week 4
IO.puts("Seeding week 4")

Seeds.create_event(
  hoh.id,
  sam.id,
  get_ceremony_20.(3).id,
  "Out on a limb competition."
)

Seeds.create_event(nom.id, haleigh.id, get_ceremony_20.(3).id)
Seeds.create_event(nom.id, kaitlyn.id, get_ceremony_20.(3).id)
Seeds.create_event(pov.id, faysal.id, get_ceremony_20.(3).id, "Chop Bonk Spank competition.")
Seeds.create_event(taken_off.id, haleigh.id, get_ceremony_20.(3).id)
Seeds.create_event(replacement_nom.id, rockstar.id, get_ceremony_20.(3).id)

Seeds.create_vote(get_ceremony_20.(3).id, jc.id, rockstar.id)
Seeds.create_vote(get_ceremony_20.(3).id, bayleigh.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, haleigh.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, faysal.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, brett.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, tyler.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, angela.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, kaycee.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, rachel.id, kaitlyn.id)
Seeds.create_vote(get_ceremony_20.(3).id, scottie.id, kaitlyn.id)

# Week 5
IO.puts("Seeding week 5")

Seeds.create_event(
  hoh.id,
  bayleigh.id,
  get_ceremony_20.(4).id,
  "Perfect Timing competition"
)

Seeds.create_event(nom.id, brett.id, get_ceremony_20.(4).id)
Seeds.create_event(nom.id, rachel.id, get_ceremony_20.(4).id)
Seeds.create_event(pov.id, tyler.id, get_ceremony_20.(4).id, "Goober Driver competition.")
Seeds.create_event(taken_off.id, nil, get_ceremony_20.(4).id)

Seeds.create_vote(get_ceremony_20.(4).id, rockstar.id, brett.id)
Seeds.create_vote(get_ceremony_20.(4).id, angela.id, rachel.id)
Seeds.create_vote(get_ceremony_20.(4).id, kaycee.id, rachel.id)
Seeds.create_vote(get_ceremony_20.(4).id, scottie.id, brett.id)
Seeds.create_vote(get_ceremony_20.(4).id, tyler.id, rachel.id)
Seeds.create_vote(get_ceremony_20.(4).id, sam.id, rachel.id)
Seeds.create_vote(get_ceremony_20.(4).id, faysal.id, brett.id)
Seeds.create_vote(get_ceremony_20.(4).id, jc.id, rachel.id)
Seeds.create_vote(get_ceremony_20.(4).id, haleigh.id, brett.id)

# Week 6
IO.puts("Seeding week 6")

Seeds.create_event(
  hoh.id,
  angela.id,
  get_ceremony_20.(5).id,
  "Gif That Keeps On Giving competition."
)

Seeds.create_event(nom.id, scottie.id, get_ceremony_20.(5).id)
Seeds.create_event(nom.id, rockstar.id, get_ceremony_20.(5).id)

Seeds.create_event(
  win_comp.id,
  haleigh.id,
  get_ceremony_20.(5).id,
  "Haleigh won the Crack the Code competition and received the hacker power."
)

# TODO: Need a new kind of taken off (non-veto taken off)
Seeds.create_event(taken_off.id, scottie.id, get_ceremony_20.(5).id)
Seeds.create_event(otb.id, tyler.id, get_ceremony_20.(5).id)
Seeds.create_event(pov.id, angela.id, get_ceremony_20.(5).id, "Boom Power Trip competition.")
Seeds.create_event(taken_off.id, tyler.id, get_ceremony_20.(5).id)
Seeds.create_event(replacement_nom.id, bayleigh.id, get_ceremony_20.(5).id)

Seeds.create_vote(get_ceremony_20.(5).id, kaycee.id, bayleigh.id)
Seeds.create_vote(get_ceremony_20.(5).id, brett.id, bayleigh.id)
Seeds.create_vote(get_ceremony_20.(5).id, faysal.id, bayleigh.id)
Seeds.create_vote(get_ceremony_20.(5).id, scottie.id, bayleigh.id)
Seeds.create_vote(get_ceremony_20.(5).id, haleigh.id, bayleigh.id)
Seeds.create_vote(get_ceremony_20.(5).id, sam.id, rockstar.id)
Seeds.create_vote(get_ceremony_20.(5).id, jc.id, bayleigh.id)

# Week 7
IO.puts("Seeding week 7")

Seeds.create_event(
  hoh.id,
  haleigh.id,
  get_ceremony_20.(6).id,
  "#HashtagTooLong competition."
)

Seeds.create_event(nom.id, angela.id, get_ceremony_20.(6).id)
Seeds.create_event(nom.id, kaycee.id, get_ceremony_20.(6).id)

Seeds.create_event(
  win_comp.id,
  kaycee.id,
  get_ceremony_20.(6).id,
  "Kaycee won the hacker power."
)

# TODO: Need a new kind of taken off (non-veto taken off)
Seeds.create_event(taken_off.id, kaycee.id, get_ceremony_20.(6).id)
Seeds.create_event(otb.id, rockstar.id, get_ceremony_20.(6).id)
Seeds.create_event(pov.id, tyler.id, get_ceremony_20.(6).id, "Otev the Sneezy Skunk competition.")
Seeds.create_event(taken_off.id, angela.id, get_ceremony_20.(6).id)
Seeds.create_event(replacement_nom.id, kaycee.id, get_ceremony_20.(6).id)

Seeds.create_vote(get_ceremony_20.(6).id, angela.id, rockstar.id)
Seeds.create_vote(get_ceremony_20.(6).id, jc.id, rockstar.id)
Seeds.create_vote(get_ceremony_20.(6).id, sam.id, rockstar.id)
Seeds.create_vote(get_ceremony_20.(6).id, scottie.id, kaycee.id)
Seeds.create_vote(get_ceremony_20.(6).id, brett.id, rockstar.id)
Seeds.create_vote(get_ceremony_20.(6).id, tyler.id, rockstar.id)

# Week 8
IO.puts("Seeding week 8")

Seeds.create_event(
  hoh.id,
  faysal.id,
  get_ceremony_20.(7).id,
  "Glow & Flow competition."
)

Seeds.create_event(nom.id, brett.id, get_ceremony_20.(7).id)
Seeds.create_event(nom.id, scottie.id, get_ceremony_20.(7).id)
Seeds.create_event(pov.id, brett.id, get_ceremony_20.(7).id, "Hide & Go Veto competition.")
Seeds.create_event(taken_off.id, brett.id, get_ceremony_20.(7).id)
Seeds.create_event(replacement_nom.id, kaycee.id, get_ceremony_20.(7).id)

Seeds.create_vote(get_ceremony_20.(7).id, angela.id, scottie.id)
Seeds.create_vote(get_ceremony_20.(7).id, jc.id, scottie.id)
Seeds.create_vote(get_ceremony_20.(7).id, tyler.id, scottie.id)
Seeds.create_vote(get_ceremony_20.(7).id, haleigh.id, scottie.id)
Seeds.create_vote(get_ceremony_20.(7).id, sam.id, scottie.id)
Seeds.create_vote(get_ceremony_20.(7).id, brett.id, scottie.id)

# Week 9
IO.puts("Seeding week 9")

Seeds.create_event(
  hoh.id,
  angela.id,
  get_ceremony_20.(8).id,
  "Sweet Shot competition."
)

Seeds.create_event(nom.id, haleigh.id, get_ceremony_20.(8).id)
Seeds.create_event(nom.id, faysal.id, get_ceremony_20.(8).id)

Seeds.create_event(
  pov.id,
  kaycee.id,
  get_ceremony_20.(8).id,
  "Mission to Planet Veto competition."
)

Seeds.create_event(taken_off.id, nil, get_ceremony_20.(8).id)

Seeds.create_vote(get_ceremony_20.(8).id, tyler.id, faysal.id)
Seeds.create_vote(get_ceremony_20.(8).id, brett.id, faysal.id)
Seeds.create_vote(get_ceremony_20.(8).id, sam.id, haleigh.id)
Seeds.create_vote(get_ceremony_20.(8).id, jc.id, faysal.id)
Seeds.create_vote(get_ceremony_20.(8).id, kaycee.id, faysal.id)

# Week 10
IO.puts("Seeding week 10")

Seeds.create_event(
  return_to_house.id,
  scottie.id,
  get_ceremony_20.(9).id,
  "Big Top Drop competition."
)

Seeds.create_event(
  hoh.id,
  tyler.id,
  get_ceremony_20.(9).id,
  "competition."
)

Seeds.create_event(nom.id, haleigh.id, get_ceremony_20.(9).id)
Seeds.create_event(nom.id, scottie.id, get_ceremony_20.(9).id)

# Create users
IO.puts("Seeding users")
andy = Seeds.create_user("Andy", "Steinberg", "holy.meekrob@gmail.com")
erin = Seeds.create_user("Erin", "Steinberg", "erinsdavidson@gmail.com")
weston = Seeds.create_user("Weston", "Fox", "bitb1448@gmail.com")
jess = Seeds.create_user("Jessica", "Fox", "jessfalcao@gmail.com")
colin = Seeds.create_user("Colin", "Davidson", "empty@none.org")

# Create Season 19 league
IO.puts("Seeding league")
league_19 = Seeds.create_league(season_19.id, andy.id, "Stupid Paul")
Seeds.create_rule(league_19.id, scorables.survive_the_week.id, 2)
Seeds.create_rule(league_19.id, scorables.win_hoh.id, 10)
Seeds.create_rule(league_19.id, scorables.win_hoh_de.id, 15)
Seeds.create_rule(league_19.id, scorables.win_hoh_final.id, 10)
Seeds.create_rule(league_19.id, scorables.nominated.id, -5)
Seeds.create_rule(league_19.id, scorables.nominated_de.id, -5)
Seeds.create_rule(league_19.id, scorables.nominated_as_replacement.id, -5)
Seeds.create_rule(league_19.id, scorables.nominated_as_replacement_de.id, -5)
Seeds.create_rule(league_19.id, scorables.otb.id, -5)
Seeds.create_rule(league_19.id, scorables.win_pov.id, 5)
Seeds.create_rule(league_19.id, scorables.win_pov_de.id, 8)
Seeds.create_rule(league_19.id, scorables.win_pov_final.id, 5)
Seeds.create_rule(league_19.id, scorables.veto_self.id, 10)
Seeds.create_rule(league_19.id, scorables.veto_self_de.id, 10)
Seeds.create_rule(league_19.id, scorables.taken_off.id, 10)
Seeds.create_rule(league_19.id, scorables.taken_off_de.id, 10)
Seeds.create_rule(league_19.id, scorables.dodge_eviction.id, 2)
Seeds.create_rule(league_19.id, scorables.dodge_eviction_de.id, 2)
Seeds.create_rule(league_19.id, scorables.reenter.id, 20)
Seeds.create_rule(league_19.id, scorables.americas_choice.id, 2)
Seeds.create_rule(league_19.id, scorables.sole_vote_against_the_house.id, 5)
Seeds.create_rule(league_19.id, scorables.win_bb.id, 45)
Seeds.create_rule(league_19.id, scorables.place_bb.id, 30)
Seeds.create_rule(league_19.id, scorables.show_bb.id, 20)
Seeds.create_rule(league_19.id, scorables.make_jury.id, 10)

# Create Season 20 league
IO.puts("Seeding league")
league_20 = Seeds.create_league(season_20.id, andy.id, "Popping Colin's Cherry")
Seeds.create_rule(league_20.id, scorables.survive_the_week.id, 2)
Seeds.create_rule(league_20.id, scorables.win_hoh.id, 10)
Seeds.create_rule(league_20.id, scorables.win_hoh_de.id, 15)
Seeds.create_rule(league_20.id, scorables.win_hoh_final.id, 10)
Seeds.create_rule(league_20.id, scorables.nominated.id, -5)
Seeds.create_rule(league_20.id, scorables.nominated_de.id, -5)
Seeds.create_rule(league_20.id, scorables.nominated_as_replacement.id, -5)
Seeds.create_rule(league_20.id, scorables.nominated_as_replacement_de.id, -5)
Seeds.create_rule(league_20.id, scorables.otb.id, -5)
Seeds.create_rule(league_20.id, scorables.win_pov.id, 5)
Seeds.create_rule(league_20.id, scorables.win_pov_de.id, 8)
Seeds.create_rule(league_20.id, scorables.win_pov_final.id, 5)
Seeds.create_rule(league_20.id, scorables.veto_self.id, 10)
Seeds.create_rule(league_20.id, scorables.veto_self_de.id, 10)
Seeds.create_rule(league_20.id, scorables.taken_off.id, 10)
Seeds.create_rule(league_20.id, scorables.taken_off_de.id, 10)
Seeds.create_rule(league_20.id, scorables.dodge_eviction.id, 2)
Seeds.create_rule(league_20.id, scorables.dodge_eviction_de.id, 2)
Seeds.create_rule(league_20.id, scorables.reenter.id, 20)
Seeds.create_rule(league_20.id, scorables.americas_choice.id, 2)
Seeds.create_rule(league_20.id, scorables.sole_vote_against_the_house.id, 5)
Seeds.create_rule(league_20.id, scorables.win_bb.id, 45)
Seeds.create_rule(league_20.id, scorables.place_bb.id, 30)
Seeds.create_rule(league_20.id, scorables.show_bb.id, 20)
Seeds.create_rule(league_20.id, scorables.make_jury.id, 10)

# Create teams
IO.puts("Seeding season 19 league teams")
andy_team_19 = Seeds.create_team(league_19.id, andy.id, "Andy's team")
erin_team_19 = Seeds.create_team(league_19.id, erin.id, "Erin's team")
weston_team = Seeds.create_team(league_19.id, weston.id, "Weston's team")
jessica_team = Seeds.create_team(league_19.id, jess.id, "Jessica's team")

# Record draft
IO.puts("Seeding season 19 league draft")
Seeds.draft(jessica_team.id, matt.id, 1)
Seeds.draft(andy_team_19.id, mark.id, 2)
Seeds.draft(erin_team_19.id, christmas.id, 3)
Seeds.draft(weston.id, cody.id, 4)
Seeds.draft(weston.id, jessica.id, 5)
Seeds.draft(erin_team_19.id, cameron.id, 6)
Seeds.draft(andy_team_19.id, josh.id, 7)
Seeds.draft(jessica_team.id, jason.id, 8)
Seeds.draft(jessica_team.id, ramses.id, 9)
Seeds.draft(andy_team_19.id, dom.id, 10)
Seeds.draft(erin_team_19.id, alex.id, 11)
Seeds.draft(weston_team.id, megan.id, 12)
Seeds.draft(weston_team.id, elena.id, 13)
Seeds.draft(erin_team_19.id, raven.id, 14)
Seeds.draft(andy_team_19.id, kevin.id, 15)
Seeds.draft(jessica_team.id, jillian.id, 16)

# How to handle Paul?
# For now, just add a draft pick
Seeds.draft(erin_team_19.id, paul.id, 17)

# Create teams
IO.puts("Seeding season 20 league teams")
andy_team_20 = Seeds.create_team(league_20.id, andy.id, "Andy's team")
erin_team_20 = Seeds.create_team(league_20.id, erin.id, "Erin's team")
colin_team = Seeds.create_team(league_20.id, colin.id, "Colin's team")

# Record draft
IO.puts("Seeding season 20 league draft")
Seeds.draft(colin_team.id, angela.id, 1)
Seeds.draft(erin_team_20.id, winston.id, 2)
Seeds.draft(andy_team_20.id, brett.id, 3)
Seeds.draft(andy_team_20.id, swaggy.id, 4)
Seeds.draft(erin_team_20.id, sam.id, 5)
Seeds.draft(colin_team.id, rachel.id, 6)
Seeds.draft(colin_team.id, jc.id, 7)
Seeds.draft(erin_team_20.id, scottie.id, 8)
Seeds.draft(andy_team_20.id, faysal.id, 9)
Seeds.draft(andy_team_20.id, haleigh.id, 10)
Seeds.draft(erin_team_20.id, tyler.id, 11)
Seeds.draft(colin_team.id, kaycee.id, 12)
Seeds.draft(colin_team.id, steve.id, 13)
Seeds.draft(erin_team_20.id, bayleigh.id, 14)
Seeds.draft(andy_team_20.id, kaitlyn.id, 15)

IO.puts("Done!")
