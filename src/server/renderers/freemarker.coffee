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

module.exports = class FreemarkerRenderer
  @key: "freemarker"
  @label: "FreeMarker"

  constructor: (templateName, options={}, onReady=->) ->
    @scopes = []
    @keyMap = {}
    path = "#{config.root}/templates/#{templateName}/freemarker-map.json"
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
    if key == "."
      scope = @scopes[0]
      "${#{scope}}"
    else if @scopes.length > 0
      out = "#{@scopes[0]}.#{key}"
      n = @scopes.length - 1
      for scope in @scopes[1..n]
        out = "(#{out})!#{scope}.#{key}"
      "${(#{out})!#{@_mapKey key}}"
    else
      "${#{@_mapKey key}}"

  section: (key, renderContents) ->
    k = @_nested key
    arr = "#{key}_arr"
    item = "#{key}_arr_item"
    @scopes.unshift item
    out = """
    <#if #{k}?is_enumerable>
      <#assign #{arr} = #{k}>
    <#elseif #{k}?? && #{k} != '' && #{k} != false>
      <#assign #{arr} = [#{k}]>
    <#else>
      <#assign #{arr} = []>
    </#if>
    <#list #{arr} as #{item}>
      #{renderContents()}
    </#list>
    """
    @scopes.shift()
    out

  inverseSection: (key, renderContents) ->
    k = @_nested key
    "<#if !(#{k}?? && #{k}?has_content && #{k} != false)>#{renderContents()}</#if>"

  _mapKey: (key) ->
    @keyMap[key] || key

  _nested: (key) ->
    return key if @scopes.length == 0
    out = "#{@scopes[0]}.#{key}"
    n = @scopes.length - 1
    for scope in @scopes[1..n]
      out = "(#{out})!#{scope}.#{key}"
    "(#{out})!#{@_mapKey key}"
