// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Home from '../elm/Home/Home';
import Profile from '../elm/Account/Profile/Profile';

const elmModules = {
	Home: Home,
	Profile: Profile
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
	const moduleName = moduleAttr.value;
	const app = elmModules[moduleName][moduleName].embed(elmDiv);

	// Allow Elm to redirect
	app.ports.navigate.subscribe(function (url) {
		window.location.href = url;
	});
})();
