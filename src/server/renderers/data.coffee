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
isArray = require("underscore").isArray
isObject = require("underscore").isObject

module.exports = class DataRenderer
  @key: "data"
  @label: "Data Preview"

  constructor: (templateName, options={}, onReady=->) ->
    @scopes = []
    fs.readFile "#{config.root}/templates/#{templateName}/data.json", (err, buffer) =>
      return onReady(err) if err
      try
        data = JSON.parse buffer.toString()
        if isArray(data)
          data = data[options.dataIndex || 0]
        @scopes.push data
        onReady()
      catch e
        onReady(e)

  value: (key) ->
    for scope in @scopes
      val = scope[key]
      return val if val?
    undefined

  section: (key, renderContents) ->
    val = @value(key)
    if isArray(val)
      @_renderList(val, renderContents)
    else if isObject(val)
      @_renderList([val], renderContents)
    else
      return "" if !val
      renderContents()

  inverseSection: (key, renderContents) ->
    val = @value key
    if isArray(val)
      renderContents() if val.length == 0
    else
      if !val then renderContents() else ""

  _renderList: (val, renderContents) ->
    out = ""
    val.forEach (item) =>
      scope = {}
      scope[k] = v for k,v of item
      scope["."] = item
      @scopes.unshift scope
      out += renderContents()
      @scopes.shift()
    out
