const path = require('path');
const CleanWebpackPlugin = require('clean-webpack-plugin');

const outputDir = path.resolve(__dirname, '../priv/static/')
module.exports = {
	entry: {
		app: './js/app.js',
	},
	plugins: [
		new CleanWebpackPlugin([outputDir])
	],
	output: {
		filename: 'app.js',
		path: outputDir
	},
}