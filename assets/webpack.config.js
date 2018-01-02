const path = require('path');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const rootDir = path.resolve(__dirname, '../')
const outputDir = path.resolve(rootDir, 'priv/static/')
const elmSource = path.resolve(__dirname, 'elm');

const env = process.env.MIX_ENV || "dev";
const isProduction = env === "prod";

module.exports = {
	entry: {
		app: ['./css/app.scss', './js/app.js', './elm/Home/Home.elm']
	},
	devtool: 'source-map',
	plugins: [
		new CleanWebpackPlugin(['priv/static'], { root: rootDir }),
		new ExtractTextPlugin("css/app.css"),
		new CopyWebpackPlugin([{
			from: "./static",
			ignore: ["favicon/*.*"]
		}, {
			from: "./static/favicon",
			to: outputDir
		}])],
	output: {
		filename: 'js/app.js',
		path: outputDir
	},
	resolve: {
		extensions: [".css", ".scss", ".js", ".elm"],
		alias: {
			phoenix: rootDir + '/deps/phoenix/assets/js/phoenix.js'
		}
	},
	module: {
		rules: [{
			test: /\.scss$/,
			include: /css/,
			use: ExtractTextPlugin.extract({
				fallback: 'style-loader',
				use: [{
						loader: 'css-loader'
					}, {
						loader: 'sass-loader',
						options: {
							sourceComments: !isProduction
						}
					}
				]
			})
		}, {
			test: /\.js$/,
			include: /js/,
			use: {
				loader: "babel-loader"
			}
		}, {
			test: /\.elm$/,
			exclude: ['/elm-stuff', '/node_modules'],
			loader: 'elm-webpack-loader',
			options: { cwd: elmSource, debug: true }
		}],
		noParse: [/\.elm$/]
	}
}