import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Home from '../elm/Home/Home';
import Account_Profile from '../elm/Account/Profile/Profile';
import Seasons_Create from '../elm/Seasons/Create/Create'
import Seasons_Show from '../elm/Seasons/Show/Show'

const elmModules = {
	Home: Home.Home,
	Account_Profile: Account_Profile.Account.Profile,
	Seasons_Create: Seasons_Create.Seasons.Create,
	Seasons_Show: Seasons_Show.Seasons.Show
};

// Insert CSRF token into outgoing requests
const appendCsrfHeaders = () => {
	const send = XMLHttpRequest.prototype.send;
	const token = document
			.querySelector('meta[name=csrf-token]')
			.getAttribute('content');

	XMLHttpRequest.prototype.send = function(data) {
		this.setRequestHeader('X-CSRF-Token', token);
		return send.apply(this, arguments);
	};
};

(() => {
	const elmDiv = document.querySelector('#elm_target');

	if (!elmDiv) {
		console.error('Elm cannot be embedded. Missing div with id="elm_target"');
		return;
	}

	const moduleAttr = elmDiv.attributes.getNamedItem('data-elm-module');
	if (moduleAttr === null) {
		console.error('Elm cannot be embedded. '
		+ 'Missing div with attribute data-elm-module="<module name>"');

		return;
	}

	appendCsrfHeaders();
	const moduleName = moduleAttr.value.replace('.', '_');
	const app = elmModules[moduleName].embed(elmDiv);

	// Allow Elm to redirect
	app.ports.navigate.subscribe(function (url) {
		window.location.href = url;
	});
})();
