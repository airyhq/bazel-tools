require(require.resolve('html-webpack-plugin', {paths: [process.cwd()]}));

const path = require('path');
const argv = require('minimist')(process.argv.slice(2));
const configGenerator = require(path.resolve(argv.config));

const config = configGenerator(process.env, argv);
const webpackDevServer = require('webpack-dev-server');
const webpack = require('webpack');

const publicPath = JSON.parse(argv.outputDict || "{}").publicPath || '/';

const options = {
    // TODO If we ever want to serve static assets for the devserver
    contentBase: false,
    hot: true,
    host: 'localhost',
    historyApiFallback: {
        rewrites: [
            {
                from: new RegExp(config.output.publicPath + '[^.]*$'),
                to: config.output.publicPath + "index.html",
            }
        ],
    },
    publicPath
};

webpackDevServer.addDevServerEntrypoints(config, options);
const compiler = webpack(config);
const server = new webpackDevServer(compiler, options);

const port = process.env.PORT || 8080;

server.listen(port, 'localhost', () => {
    console.log(`dev server listening on port ${port}`);
});
