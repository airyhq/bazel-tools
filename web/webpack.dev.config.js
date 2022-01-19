const path = require('path');
const cwdRequire = id => require(require.resolve(id, { paths: [process.cwd()] }));

const webpack = cwdRequire('webpack');
const HtmlWebpackPlugin = cwdRequire("html-webpack-plugin");
const CopyWebpackPlugin = cwdRequire('copy-webpack-plugin');

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

module.exports = (env, argv) => {
    const output = {
        publicPath: '/',
        filename: 'js/[name].[chunkhash:8].js',
        ...JSON.parse(argv.outputDict || "{}"),
    };

    return {
        context: env.BUILD_WORKSPACE_DIRECTORY,

        mode: 'development',
        target: 'web',
        bail: false,

        entry: ['react-hot-loader/patch', path.resolve(argv.entry)],

        output,

        optimization: {
            minimize: false,
        },

        resolve: {
            alias: {
                ...resolveTsconfigPathsToAlias({
                    tsconfigPath: path.resolve(argv.tsconfig),
                    basePath: process.cwd(),
                }),
                ...JSON.parse(argv.aliases || "{}")
            },
            extensions: ['.tsx', '.ts', '.js'],
            fallback: {
                "assert": false
            }
        },

        devtool: 'eval-cheap-module-source-map',

        module: {
            rules: [
                {
                    test: /\.tsx?$/,
                    exclude: /node_modules/,
                    loader: 'babel-loader',
                    options: {
                        cacheDirectory: true,
                        presets: [
                            [
                                '@babel/preset-env',
                                {
                                    useBuiltIns: 'entry',
                                    modules: false,
                                    corejs: 3,
                                    targets: ['>0.2%', 'not dead', 'not op_mini all'],
                                },
                            ],
                            '@babel/preset-react',
                            ['@babel/preset-typescript', {isTSX: true, allExtensions: true}],
                        ],
                        plugins: [
                            '@babel/plugin-transform-spread',
                            '@babel/plugin-proposal-object-rest-spread',
                            '@babel/plugin-proposal-class-properties',
                        ],
                    },
                },
                {
                    test: /\.(scss|css)$/,
                    use: [
                        'style-loader',
                        {
                            loader: 'css-loader',
                            options: {
                                importLoaders: 1,
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
                'process.env.NODE_ENV': `"development"`,
                'process.env.PUBLIC_PATH': `'${output.publicPath}'`,
                ...JSON.parse(argv.defines || '{}'),
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
                template: argv.index,
                inject: true,
                filename: 'index.html',
            }),
        ],
    };
};
