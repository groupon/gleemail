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
Hogan = require "hogan.js"
config = require "../config"

module.exports = (text, templateName, options, cb) ->
  renderWithData(text, templateName, options, cb)

add = module.exports.add = (klass) ->
  throw "Renderers must respond to #key" unless klass.key
  renderers[klass.key] = klass

renderers = module.exports.renderers = {}

renderWithData = (text, templateName, options, cb) ->
  rendererClass = renderers[options.renderer] || renderers.data
  renderer = new rendererClass templateName, options, (err) ->
    return cb(err) if err
    try
      renderTree = (tree) ->
        output = ""
        for node in tree
          key = node.n
          renderContents = -> renderTree node.nodes
          switch node.tag
            when "_v"
              output += renderer.value(key)
            when "#"
              output += renderer.section(key, renderContents)
            when "^"
              output += renderer.inverseSection(key, renderContents)
            when "\n"
              output += "\n"
            else
              output += Array.prototype.join.call node, ""
        output

      tree = Hogan.parse Hogan.scan(text)
      output = renderTree(tree)
      output = output.replace /&#x26;/g, "&"
      output = output.replace /&#xA0;/g, "&nbsp;"
      output = output.replace /&#x2019;/g, "'"
      output = output.replace /&apos;/g, "'"
      cb(null, output)
    catch e
      console.error e
      cb(e)

add require("../renderers/data")
add require("../renderers/eloqua")
add require("../renderers/freemarker")
add require("../renderers/mailchimp")
add require("../renderers/mustache")

