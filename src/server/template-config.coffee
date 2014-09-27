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
config = require "./config"
isArray = require("underscore").isArray

class Config
  constructor: (@templateName, data={}) ->
    this[k] = v for own k, v of data

  load: (cb=->) ->
    fs.readFile @path(), (err, buffer) =>
      if err && err.code != "ENOENT"
        return cb(err)

      try
        data = if buffer then JSON.parse buffer.toString() else {}
        this[k] = v for own k, v of data
        @loadData (err, data) =>
          this.dataLength = data.length
          cb null, this
      catch e
        cb(e)

  loadData: (cb=->) ->
    fs.readFile @dataPath(), (err, buffer) ->
      return cb(err) if err && err.code != "ENOENT"
      try
        data = if buffer then JSON.parse buffer.toString() else {}
        data = [data] if !isArray(data)
        cb null, data
      catch e
        cb e

  save: (cb=->) ->
    out = {}
    out[k] = v for own k,v of this when k != "templateName"
    try
      text = JSON.stringify out
    catch e
      return cb(e)
    fs.writeFile @path(), text, (err) ->
      cb(err)

  path: ->
    "#{config.root}/templates/#{@templateName}/.config.json"

  dataPath: ->
    "#{config.root}/templates/#{@templateName}/data.json"

module.exports = (templateName, data, cb) ->
  unless cb
    cb = data
    data = null
  tconfig = new Config(templateName, data)
  if data
    cb(null, tconfig)
  else
    tconfig.load cb
