require(require.resolve('html-webpack-plugin', {paths: [process.cwd()]}));

const path = require('path');
const argv = require('minimist')(process.argv.slice(2));
const configGenerator = require(path.resolve(argv.config));

const config = configGenerator(process.env, argv);
const WebpackDevServer = require('webpack-dev-server');
const webpack = require('webpack');

const publicPath = JSON.parse(argv.outputDict || "{}").publicPath || '/';
const options = {
    hot: true,
    static: {
        publicPath,
    },
    historyApiFallback: {
        rewrites: [
            {
                from: new RegExp(config.output.publicPath + '[^.]*$'),
                to: config.output.publicPath + "index.html",
            }
        ],
    }
};

if (argv.public) {
    options.public = argv.public
}

const compiler = webpack(config);
const server = new WebpackDevServer(options, compiler);

const port = process.env.PORT || 8080;

(async () => {
  await server.start();
  console.log(`dev server is listening on port ${port}`);
})();
