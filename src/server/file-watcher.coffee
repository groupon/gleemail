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
EventEmitter = require("events").EventEmitter
config = require "./config"
templates = require "./templates"
instance = null

module.exports = class FileWatcher extends EventEmitter
  init: ->
    templates.all (err, templates) =>
      return console.error err if err
      templates.forEach (template) => @watchTemplate template.name

  watchTemplate: (templateName) ->
    templateDir = "#{config.root}/templates/#{templateName}"
    fs.readdir templateDir, (err, filenames) =>
      return console.error err if err
      filenames.forEach (filename) =>
        path = "#{config.root}/templates/#{templateName}/#{filename}"
        fs.watchFile path, {persistent: yes, interval: 500}, (curr, prev) =>
          unless curr.mtime == prev.mtime
            console.log "Updated", templateName
            @emit "template-updated", name: templateName

FileWatcher.instance = ->
  instance ?= new FileWatcher()

