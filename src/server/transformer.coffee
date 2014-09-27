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

cheerio = require "cheerio"

module.exports = class Transformer
  constructor: ->
    @_transformers = []

  append: (f) =>
    @_transformers.push @_wrap(f)

  prepend: (f) =>
    @_transformers.unshift @_wrap(f)

  transform: (templateName, html, options, cb) ->
    i = 0
    run = ($) =>
      t = @_transformers[i]
      t $, templateName, options, (err, $$$) =>
        return cb(err) if err
        i++
        if @_transformers.length <= i
          cb(null, $$$.html())
        else
          run($$$)
    run cheerio.load(html)

  _wrap: (f) ->
    switch f.length
      when 1
        ($, templateName, options, cb) ->
          try
            f($)
            cb null, $
          catch e
            cb e
      when 2
        ($, templateName, options, cb) ->
          f($, cb)
      when 4
        f
      else
        throw "Transformer functions must use ($), ($, cb) or ($, name, opts, cb) signatures"

