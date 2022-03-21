const path = require('path');
const webpack = require('webpack');
const TerserPlugin = require('terser-webpack-plugin');

function resolveTsconfigPathsToAlias({tsconfigPath, basePath}) {
    const {paths} = require(tsconfigPath).compilerOptions;
    const stripGlobs = path => path.replace('/*', '');

    return Object.keys(paths).reduce((aliases, moduleMappingKey) => {
        const key = stripGlobs(moduleMappingKey);
        const value = path.resolve(basePath, stripGlobs(paths[moduleMappingKey][0]).replace('*', ''));

        return {
            ...aliases,
            [key]: value,
        };
    }, {});
}


module.exports = (env) => ({
    mode: 'production',
    target: 'web',
    bail: true, // stop compilation on first error
    resolve: {
        alias: {
            ...resolveTsconfigPathsToAlias({
                tsconfigPath: path.resolve(env.tsconfig),
                basePath: path.resolve(process.cwd(), env.genDir),
            }),
            ...JSON.parse(env.aliases || "{}")
        }
    },
    output: {
        path: path.resolve(env.path),
        ...JSON.parse(env.outputDict || "{}")
    },

    optimization: {
        minimize: true,
        minimizer: [new TerserPlugin()],
    },

    externals: {
        ...JSON.parse(env.externalDict || "{}"),
    },

    module: {
        rules: [
            {
                test: /\.(mjs|js)$/,
                exclude: /node_modules/,
                loader: 'babel-loader',
                options: {
                    cacheDirectory: false
                },
            },
            {
                test: /\.(scss|css)$/,
                use: [
                    'style-loader',
                    {
                        loader: 'css-loader',
                        options: {
                            modules: {
                                auto: true,
                                localIdentName: '[name]_[local]-[hash:base64:5]',
                            },
                        },
                    },
                    'sass-loader',
                ],
            },
            {
                test: /\.(ico|jpg|jpeg|png|gif|eot|otf|webp|ttf|woff|woff2)(\?.*)?$/,
                loader: 'url-loader',
            },
            {
                test: /\.svg$/,
                use: [
                    {
                        loader: '@svgr/webpack',
                        options: {
                            titleProp: true,
                            template: ({imports, interfaces, componentName, props, jsx, exports}, {tpl}) => {
                                return tpl`
                                          ${imports}
                                          ${interfaces}
                                          function ${componentName}(${props}) {
                                            props = { title: '', ...props };
                                            return ${jsx};
                                          }
                                          ${exports}
                                          `;
                            },
                        },
                    },
                    // Use url-loader to be able to inject into img src
                    // https://www.npmjs.com/package/@svgr/webpack#using-with-url-loader-or-file-loader
                    'url-loader',
                ],
            },
        ],
    },
    plugins: [
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': `"production"`,
        }),
    ].concat(
        env.show_bundle_report === true ? [
            new (require('webpack-bundle-analyzer').BundleAnalyzerPlugin)({
                analyzerMode: "static"
            })
        ] : []
    ),
});
