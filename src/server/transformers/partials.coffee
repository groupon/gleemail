###
Copyright (c) 2014, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

fs = require "fs"
glob = require "glob"
async = require "async"
config = require "../config"

module.exports = (html, templateName, options, cb) ->
  withPartialsForTemplate templateName, (err, partials) ->
    return cb(err) if err
    try
      html = addPartials(html, partials)
    catch e
      return cb(e)
    cb null, html

addPartials = (html, partials) ->
  for key, partialHtml of partials
    rex = new RegExp "\\{\\{<\\s*#{key}\\s*\\}\\}", "g"
    html = html.replace rex, partialHtml
  html

withPartialsForTemplate = (templateName, cb) ->
  partials = {}
  glob "#{config.root}/{shared,templates/#{templateName}}/**/*.mustache", (err, files) ->
    return cb(err) if err
    loadFile = (filename, cb) ->
      key = filename.replace("#{config.root}/", "").replace("templates/#{templateName}/", "").replace(".mustache", "")
      fs.readFile filename, (err, buffer) ->
        return cb(err) if err
        partials[key] = buffer.toString()
        cb()
    async.each files, loadFile, (err) ->
      return cb(err) if err
      cb null, partials

