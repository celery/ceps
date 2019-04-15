var glob = require('glob')
var matter = require('gray-matter')
var toml = require('toml')
var Ajv = require('ajv')
var prettyjson = require('prettyjson')

var schema = require('./schema.json')
if (process.argv[3] === 'TOML') {
  options = {
    engines: {
      toml: toml.parse.bind(toml)
    },
    language: 'toml',
    delims: [process.argv[4], process.argv[4]]
  }
} else {
  options = {
    language: process.argv[3].toLowerCase(),
    delims: [process.argv[4], process.argv[4]]
  }
}

glob(process.argv[2] + '/*.md', {}, function (er, files) {
  var ajv = new Ajv()
  files.forEach(function (file, index) {
    var fm = matter.read(file, options)
    var valid = ajv.validate(schema, fm.data)
    if (!valid) {
      console.log(prettyjson.render({'src': file, 'errors': ajv.errors}))
      return process.exit(1)
    }
  })
})
