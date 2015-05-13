extractor = require 'extract-text-webpack-plugin'
webpack = require 'webpack'
uglifyer = webpack.optimize.UglifyJsPlugin

module.exports =
  entry: './client/client.coffee'
  output:
    filename: './public/client.js'
  module:
    loaders: [
      { test: /\.coffee$/, loader: "coffee" }
      { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" }
      { test: /\.tag$/, loader: "riotjs" }
      { test: /\.css$/, loader:  extractor.extract "style", "css" }
    ]
  plugins: [
    new extractor("./public/style.css", allChunks: true)
    # new uglifyer({minimize: true})
  ]
  devtool: 'source-map'