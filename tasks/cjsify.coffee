###
grunt-cjsify
https://github.com/hdmessaging/grunt-cjsify
Copyright (c) 2013 HDmessaging
Licensed under the MIT license.
###

path = require 'path'

CoffeeScript = require 'coffee-script'
eco = require 'eco'
{SourceMapConsumer} = require 'source-map'
{cjsify} = require 'commonjs-everywhere'
{parse} = require 'esprima'
{traverse} = require 'estraverse'
{generate} = require 'escodegen'

module.exports = (grunt) ->
  grunt.registerMultiTask 'cjsify', 'CommonJS Everywhere', () ->
    options = @options
      root: process.cwd()
      export: null
      aliases: {}
      handlers:
        '.eco': (source, filename) ->
          try
            content = eco.precompile source
          catch err
            try
              code = eco.preprocess source
              message = CoffeeScript.helpers.prettyErrorMessage(err, filename, code, true)
            catch
              message = err.message
            grunt.warn(message)
          parse "module.exports = #{content}", loc: true
      node: false
      ignoreMissing: false
      useCoffeeScriptV1: false
      useGlobalContext: false
      sourceMapRoot: null
      sourceMap: false

    createOutputPaths = (dest) ->
      {
        dest: dest
        mapDest: dest + '.map'
        mapFileName: path.basename(dest) + '.map'
      }

    if options.useCoffeeScriptV1
      options.handlers['.coffee'] = (source, filename) ->
        try
          result = CoffeeScript.compile source,
                                        filename: filename,
                                        bare: true,
                                        sourceMap: options.sourceMap
        catch err
          message = CoffeeScript.helpers.prettyErrorMessage(err, filename, source, true)
          grunt.warn(message)
        if options.sourceMap
          {js, v3SourceMap} = result
          sourceMap = new SourceMapConsumer v3SourceMap
          ast = parse js, loc: true
          traverse ast,
            enter: (node) ->
              node.loc.start = sourceMap.originalPositionFor node.loc.start
              node.loc.start.source = filename
              node.loc.end = sourceMap.originalPositionFor node.loc.end
              node.loc.end.source = filename
        else
          ast = parse result
        ast

    if options.useGlobalContext
      options.handlers['.js'] = (source) ->
        "(function(global){\n#{source}\n}).call(global, global);"

    @files.forEach (f) ->
      unless f.src.length == 1
        throw new Error 'exactly one file should be defined as the entry point'
        return

      entryPoint = f.src[0]

      unless grunt.file.exists entryPoint
        throw new Error "Source file #{entryPoint} not found."
        return

      paths = createOutputPaths f.dest

      ast = cjsify entryPoint, options.root, options

      if options.sourceMap
        {map, code} = generate ast,
          sourceMap: true
          sourceMapRoot: options.sourceMapRoot
          sourceMapWithCode: true
          file: paths.dest
        js = "#{code}\n\n//@ sourceMappingURL=#{paths.mapFileName}\n"
        grunt.file.write paths.mapDest, map
        grunt.log.writeln "File #{paths.mapDest} created."
      else
        js = generate ast, file: paths.dest
      grunt.file.write paths.dest, js
      grunt.log.writeln "File #{paths.dest} created."
