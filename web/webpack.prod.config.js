const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

function resolveTsconfigPathsToAlias({tsconfigPath, basePath}) {
    const {paths} = require(tsconfigPath).compilerOptions;
    const stripGlobs = path => path.replace('/*', '');

    return Object.keys(paths).reduce((aliases, moduleMappingKey) => {
        const key = stripGlobs(moduleMappingKey);
        const value = path.resolve(basePath, stripGlobs(paths[moduleMappingKey][1]).replace('*', ''));

        return {
            ...aliases,
            [key]: value,
        };
    }, {});
}

module.exports = (env) => {
    const output = {
        path: path.resolve(env.path),
        publicPath: '/',
        filename: 'js/[name].[chunkhash:8].js',
        ...JSON.parse(env.outputDict || "{}")
    }

    return ({
        mode: 'production',
        devtool: "source-map",
        target: 'web',
        bail: true, // stop compilation on first error
        resolve: {
            alias: {
                ...resolveTsconfigPathsToAlias({
                    tsconfigPath: path.resolve(env.tsconfig),
                    basePath: process.cwd(),
                }),
                ...JSON.parse(env.aliases || "{}")
            }
        },
        output,

        optimization: {
            minimize: true,
            minimizer: [
                new TerserPlugin(),
            ],
        },

        stats: {
            children: true,
            errorDetails: true,
        },

        module: {
            rules: [
                {
                    test: /\.(mjs|js)$/,
                    exclude: /node_modules/,
                    loader: 'babel-loader',
                    options: {
                        cacheDirectory: false,
                        presets: [
                            [
                                '@babel/preset-env',
                                {
                                    useBuiltIns: 'entry',
                                    corejs: 3,
                                    modules: false,
                                    targets: ['>0.2%', 'not dead', 'not op_mini all'],
                                },
                            ],
                        ],
                    },
                },
                {
                    test: /\.module\.scss$/,
                    use: [
                        'style-loader',
                        {
                            loader: 'css-loader',
                            options: {
                                importLoaders: 1,
                                modules: {
                                    localIdentName: '[name]__[local]--[hash:base64:5]',
                                },
                            },
                        },
                        'sass-loader',
                    ],
                },
                {
                    test: /(?<!\.module)\.(scss|css)$/,
                    use: [
                        'style-loader',
                        {
                            loader: 'css-loader',
                            options: {
                                importLoaders: 1,
                            },
                        },
                        'sass-loader',
                    ],
                },
                {
                    test: /\.(ico|jpg|jpeg|png|gif|eot|otf|webp|ttf|woff|woff2)(\?.*)?$/,
                    loader: 'file-loader',
                    options: {
                        name: 'media/[name].[hash:8].[ext]',
                    },
                },
                {
                    test: /\.svg$/,
                    use: [
                        {
                            loader: '@svgr/webpack',
                            options: {
                                titleProp: true,
                                svgoConfig: {
                                    plugins: {
                                        removeViewBox: false,
                                    },
                                },
                                template: ({template}, opts, {imports, interfaces, componentName, props, jsx, exports}) => {
                                    const plugins = ['jsx'];
                                    if (opts.typescript) {
                                        plugins.push('typescript');
                                    }
                                    const typeScriptTpl = template.smart({plugins});
                                    return typeScriptTpl.ast`
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
                'process.env.PUBLIC_PATH': `'${output.publicPath}'`,
            }),
            new CopyWebpackPlugin({
                    patterns: [
                        {
                            from: '**/public/**/*',
                            to: "[name][ext]",
                            noErrorOnMissing: true,
                            globOptions: {
                                ignore: ['**/node_modules/**'],
                            }
                        }
                    ]
                }
            ),
            new HtmlWebpackPlugin({
                template: path.resolve(env.index),
                inject: true,
                filename: 'index.html',
                minify: {removeComments: true, collapseWhitespace: true},
            }),
        ].concat(
            env.show_bundle_report === true ? [
                new (require('webpack-bundle-analyzer').BundleAnalyzerPlugin)({
                    analyzerMode: "static"
                })
            ] : []
        ),
    });
};
