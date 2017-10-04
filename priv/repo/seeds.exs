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
alias FantasyBb.Schema.EventType

defmodule Seeds do
	def create_event_type(name, description) do
		IO.puts("Creating ruleset: #{name}")
		event_type = %EventType{}
		|> EventType.changeset(%{name: name, description: description})

		Repo.insert!(event_type)
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

IO.puts("Done!")