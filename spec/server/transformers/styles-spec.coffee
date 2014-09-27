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

inlineStyles = require "../../../src/server/transformers/styles"

describe "inlining styles", ->
  html = """
    <p class="red"></p>
    <p class="green"></p>
    <p class="blue"></p>
  """

  it "applies styles from style.styl file (in this case .red)", (done) ->
    inlineStyles html, "test-example", {}, (err, $) ->
      expect($("p").eq(0).attr "style").toEqual "color: #f00;"
      done()

  it "applies styles from shared styl files (in this case .green)", (done) ->
    inlineStyles html, "test-example", {}, (err, $) ->
      expect($("p").eq(1).attr "style").toEqual "color: #0f0;"
      done()

  it "applies styles from nested styl files (in this case .blue)", (done) ->
    inlineStyles html, "test-example", {}, (err, $) ->
      expect($("p").eq(2).attr "style").toEqual "color: #00f;"
      done()
