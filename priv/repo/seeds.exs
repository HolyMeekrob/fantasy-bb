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
alias FantasyBb.Schema.Event
alias FantasyBb.Schema.EventType
alias FantasyBb.Schema.Houseguest
alias FantasyBb.Schema.Player
alias FantasyBb.Schema.Season
alias FantasyBb.Schema.Week

defmodule Seeds do
	def create_event_type(name, description) do
		IO.puts("Creating ruleset: #{name}")

		event_type = EventType.changeset(%EventType{},
			%{name: name, description: description})

		Repo.insert!(event_type)
	end

	def build_season(start, title, houseguests, week_count) do
		IO.puts("Creating season: #{title}")

		season = Season.changeset(%Season{}, %{start: start, title: title})

		season = Repo.insert!(season)

		{
			season,
			Enum.map(houseguests, &(add_houseguest(&1, season.id))),
			Enum.map(1..week_count, &(add_week(&1, season.id)))
		}
	end

	def add_houseguest(houseguest, season_id) do
		player = create_player(houseguest.first_name, houseguest.last_name,
			houseguest.nick_name, houseguest.birthday)

		IO.puts("Creating houseguest: #{houseguest.first_name} #{houseguest.last_name}")

		# TODO: Create houseguest
		hg = Houseguest.changeset(%Houseguest{},
			%{season_id: season_id, player_id: player.id, hometown: houseguest.hometown})

		Repo.insert!(hg)
	end

	def add_week(week_number, season_id) do
		IO.puts("Creating week #{week_number}")

		week = Week.changeset(%Week{},
			%{season_id: season_id, week_number: week_number})

		Repo.insert!(week)
	end

	def create_player(first_name, last_name, nick_name, birthday) do
		IO.puts("Creating player: #{first_name} #{last_name}")

		player = Player.changeset(%Player{},
			%{first_name: first_name, last_name: last_name, nick_name: nick_name,
				birthday: birthday})
		
		Repo.insert!(player)
	end

	def create_event(event_type_id, houseguest_id, week_id, additional_info) do
		event = Event.changeset(%Event{},
			%{event_type_id: event_type_id, houseguest_id: houseguest_id,
				week_id: week_id, additional_info: additional_info})

			Repo.insert!(event)
	end
end

IO.puts("Seeding database")

IO.puts("Creating event types")
Seeds.create_event_type("Win Head of Household", "Win a standard Head of Household.")
Seeds.create_event_type("Win Head of Household (double eviction)", "Win Head of Household during a double eviction event.")
Seeds.create_event_type("Win Final Head of Household (Round 1)", "Win the first round of the final Head of Household competition.")
Seeds.create_event_type("Win Final Head of Household (Round 2)", "Win the second round of the final head of Household competition.")
Seeds.create_event_type("Win Final Head of Household", "Win the final Head of Household.")
Seeds.create_event_type("Win Power of Veto", "Win a standard Power of Veto.")
Seeds.create_event_type("Win Power of Veto (double eviction)", "Win Power of Veto during a double eviction event.")
Seeds.create_event_type("Win Final Power of Veto", "Win the final Power of Veto.")
Seeds.create_event_type("Nominated for eviction", "Nominated for eviction by the Head of Household (not a replacement nominee).")
Seeds.create_event_type("Nominated for eviction (double eviction)", "Nominated for eviction by the Head of Household during a double eviction event (not a replacement nominee).")
Seeds.create_event_type("Placed on the block", "Placed on the block by some means other than nomination.")
Seeds.create_event_type("Veto self", "Take oneself off the block using Power of Veto.")
Seeds.create_event_type("Veto self (double eviction)", "Take oneself off the block using Power of Veto during a double eviction event.")
Seeds.create_event_type("Veto another", "Take another houseguest off the block using Power of Veto. The Power of Veto winner was not on the block themself.")
Seeds.create_event_type("Veto another (double eviction)", "Take another houseguest off the block using Power of Veto during a double eviction event. The Power of Veto winner was not on the block themself.")
Seeds.create_event_type("Veto another whilst on the block", "Take another houseguest off the block using Power of Veto. The Power of Veto winner was on the block themself.")
Seeds.create_event_type("Veto another whilst on the block (double eviction)", "Take another houseguest off the block using Power of Veto during a double eviction evnet. The Power of Veto winner was on the block themself.")
Seeds.create_event_type("Abstain from veto", "Power of Veto holder does not take anyone off the block.")
Seeds.create_event_type("Abstain from veto (double eviction)", "Power of Veto holder does not take anyone off the block during a double eviction event.")
Seeds.create_event_type("Taken off the block", "Houseguest has Power of Veto used on them.")
Seeds.create_event_type("Taken off the block (double eviction", "Houseguest has Power of Veto used on them during a double veiction event.")
Seeds.create_event_type("Nominated for eviction as a replacement", "Nominated for eviction by the Head of Household as a replacement for a vetoed houseguest.")
Seeds.create_event_type("Nominated for eviction as a replacement (double eviction)", "Nominated for eviction by the Head of Household as a replacement for a vetoed houseguest during a double eviction event.")
Seeds.create_event_type("Dodge eviction", "Dodge eviction whilst on the block.")
Seeds.create_event_type("Dodge eviction (double eviction)", "Dodge eviction whilst on the block during a double eviction event.")
Seeds.create_event_type("Vote for evicted houseguest", "Vote for the houseguest that ended up being evicted.")
Seeds.create_event_type("Vote for non-evicted houseguest", "Vote for a houseguest that did not end up being evicted.")
Seeds.create_event_type("Sole vote against the house", "Provide the only vote for a non-evicted houseguest when all other votes were for the evicted houseguest.")
Seeds.create_event_type("Return to the house", "Return to the house after being evicted.")
Seeds.create_event_type("Win America's choice", "Win an America's choice vote.")
Seeds.create_event_type("Survive the week", "Remain in the house at the conclusion of the week.")
Seeds.create_event_type("Win miscellaneous competition", "Win a competition that does not fall under any other category.")
Seeds.create_event_type("Win Big Brother", "Win the Big Brother game at the conclusion of the season.")
Seeds.create_event_type("Win America's favorite player", "Win the vote for America's favorite player at the conclusion of the season.")
Seeds.create_event_type("Self-evicted", "Evict oneself from the house.")
Seeds.create_event_type("Removed from the house", "Removed by Big Brother production for any reason.")
Seeds.create_event_type("Evicted", "Voted out of the house by fellow houseguests.")
Seeds.create_event_type("Evicted (double eviction", "Voted out of the house by fellow houseguests during a double eviction event.")
IO.puts("Event types created")


season_19_houseguests = [
	%{
		first_name: "Alexandra",
		last_name: "Ow",
		nick_name: "Alex",
		birthday: ~D[1988-12-20],
		hometown: "Thousand Oaks, CA"
	}, %{
		first_name: "Cameron",
		last_name: "Heard",
		nick_name: nil,
		birthday: ~D[1992-08-27],
		hometown: "North Aurora, IL"
	}, %{
		first_name: "Christmas",
		last_name: "Abbott",
		nick_name: nil,
		birthday: ~D[1981-12-20],
		hometown: "Lynchburg, VA"
	}, %{
		first_name: "Cody",
		last_name: "Nickson",
		nick_name: nil,
		birthday: ~D[1985-04-13],
		hometown: "Lake Mills, IA"
	}, %{
		first_name: "Dominique",
		last_name: "Cooper",
		nick_name: nil,
		birthday: ~D[1986-07-11],
		hometown: "Tuskegee, AL"
	}, %{
		first_name: "Elena",
		last_name: "Davies",
		nick_name: nil,
		birthday: ~D[1990-08-19],
		hometown: "Fort Worth, TX"
	}, %{
		first_name: "Jason",
		last_name: "Dent",
		nick_name: nil,
		birthday: ~D[1979-07-12],
		hometown: "Humeston, IA"
	}, %{
		first_name: "Jessica",
		last_name: "Graf",
		nick_name: nil,
		birthday: ~D[1990-12-11],
		hometown: "Cranston, RI"
	}, %{
		first_name: "Jillian",
		last_name: "Parker",
		nick_name: nil,
		birthday: ~D[1993-05-12],
		hometown: "Celebration, FL"
	}, %{
		first_name: "Joshua",
		last_name: "Martinez",
		nick_name: "Josh",
		birthday: ~D[1994-01-04],
		hometown: "Miami, FL"
	}, %{
		first_name: "Kevin",
		last_name: "Schlehuber",
		nick_name: nil,
		birthday: ~D[1961-08-07],
		hometown: "Boston, MA"
	}, %{
		first_name: "Mark",
		last_name: "Jansen",
		nick_name: nil,
		birthday: ~D[1991-06-13],
		hometown: "Grand Island, NY"
	}, %{
		first_name: "Matthew",
		last_name: "Clines",
		nick_name: "Matt",
		birthday: nil,
		hometown: "Arlington, VA"
	}, %{
		first_name: "Megan",
		last_name: "Lowder",
		nick_name: nil,
		birthday: ~D[1989-03-07],
		hometown: "Cathedral City, CA"
	}, %{
		first_name: "Paul",
		last_name: "Abrahamian",
		nick_name: nil,
		birthday: ~D[1993-06-13],
		hometown: "Tarzana, CA"
	}, %{
		first_name: "Ramses",
		last_name: "Soto",
		nick_name: nil,
		birthday: ~D[1995-12-18],
		hometown: "Grand Rapids, MI"
	}, %{
		first_name: "Raven",
		last_name: "Walton",
		nick_name: nil,
		birthday: ~D[1994-06-10],
		hometown: "DeValls Bluff, AR"
	}]

Seeds.build_season(~D[2017-06-28], "Big Brother 19", season_19_houseguests, 14)

IO.puts("Done!")