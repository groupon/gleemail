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
config = require "../config"

module.exports = class EloquaRenderer
  @key: "eloqua"
  @label: "Eloqua"

  constructor: (templateName, options={}, onReady=->) ->
    @keyMap = {}
    path = "#{config.root}/templates/#{templateName}/eloqua-map.json"
    fs.exists path, (exists) =>
      return onReady() unless exists
      fs.readFile path, (err, buffer) =>
        return onReady(err) if err
        try
          @keyMap = JSON.parse buffer.toString()
          onReady()
        catch e
          return onReady(e)

  value: (key) ->
    "<span class='eloquaemail'>#{@_mapKey key}</span>"

  section: (key) ->
    throw new Error("Eloqua does not support conditionals")

  inverseSection: (key) ->
    throw new Error("Eloqua does not support conditionals")

  _mapKey: (key) ->
    @keyMap[key] || key
