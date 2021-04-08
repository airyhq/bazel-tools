// Run from the workspace root
process.chdir(process.env.BUILD_WORKSPACE_DIRECTORY);

const path = require('path');
const argv = require('minimist')(process.argv.slice(2));
const configGenerator = require(path.resolve(argv.config));

const config = configGenerator(process.env, argv);
const webpackDevServer = require('webpack-dev-server');
const webpack = require('webpack');

const options = {
  // TODO
  contentBase: false,
  hot: true,
  host: 'localhost',
  historyApiFallback: true,
};

webpackDevServer.addDevServerEntrypoints(config, options);
const compiler = webpack(config);
const server = new webpackDevServer(compiler, options);

const port = process.env.PORT || 8080;

server.listen(port, 'localhost', () => {
  console.log(`dev server listening on port ${port}`);
});
