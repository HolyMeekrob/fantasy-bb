defmodule FantasyBbWeb.AccountView do
	use FantasyBbWeb, :view

	def render("user.json", user) do
		%{
			firstName: user.first_name,
			lastName: user.last_name,
			email: user.email,
			bio: user.bio
		}
	end
end
