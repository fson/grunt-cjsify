# grunt-cjsify

A Grunt plugin for using
[CommonJS Everywhere](https://github.com/michaelficarra/commonjs-everywhere)
browser bundler.

## Getting Started
This plugin requires Grunt `~0.4.1`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-cjsify --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-cjsify');
```

## The "cjsify" task

### Overview
In your project's Gruntfile, add a section named `cjsify` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  cjsify: {
    options: {
      // Task-specific options go here.
    },
    your_target: {
      // Target-specific file lists and/or options go here.
    },
  },
})
```

The file passed to the the target is treated as the entry point module.
Note that you may only pass one file per target.

### Options

#### options.root
Type: `String`
Default value: `process.cwd()`

The directory to which unqualified requires are relative.

#### options.export
Type: `String`
Default value: `null`

A variable name to add to the global scope; assigned the exported
object from the entry point module.

#### options.aliases
Type: `object`
Default value: `{}`

An object whose keys and values are root-rooted paths (/src/file.js),
representing values that will replace requires that resolve to the
associated keys.

#### options.handlers
Type: `object`
Default value: `{}`

An object whose keys are file extensions ('.roy') and whose values are
functions from the file contents to either a Spidermonkey-format
JS AST like the one esprima produces or a string of JS. Handlers for
CoffeeScript and JSON are included by default. If no handler is
defined for a file extension, it is assumed to be JavaScript.

#### options.node
Type: `Boolean`
Default value: `false`

Setting this to `true` adds a process stub that emulates a node
environment.

#### options.ignoreMissing
Type: `Boolean`
Default value: `false`

Continue without error when dependency resolution fails.

#### options.useCoffeeScriptV1
Type: `Boolean`
Default value: `false`

Setting this flag to `true` will use
[CoffeeScript 1.x](https://github.com/jashkenas/coffee-script)
instead if CoffeeScriptRedux.

#### options.useGlobalContext
Type: `Boolean`
Default value: `false`

Setting this to `true` adds wrapper to JS files that binds `this`
on the top level to global object. This can be used for supporting
legacy non-CommonJS scripts that define variables on the global scope.

#### options.sourceMapRoot
Type: `String`
Default value: `null`

The source root for the source map, i.e.
the URL root from which all sources are relative.
For the source mapping to work the original sources need to be served on the
web server. Set this to the URL where the sources are located.
