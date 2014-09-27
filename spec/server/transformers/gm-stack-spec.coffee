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
transform = require "../../../src/server/transformers/gm-stack"
$ = null

describe "gm-stack transformation", ->
  beforeEach ->
    $ = cheerio.load """
      <gm-stack id="stack">
        <p id="item1">Item 1</p>
        <p id="item2">Item 2</p>
        <p id="item3">Item 3</p>
      </gm-stack>
    """
    transform $, "template-name", {}, (err, $$$) =>
      @table = $$$("> table")

  it "replaces the gm-stack with a table", ->
    expect(@table.length).toEqual 1
    expect($("gm-stack").length).toEqual 0

  it "copies gm-stack attributes to the table", ->
    expect(@table.attr "id").toEqual "stack"

  it "wraps each child item in a td", ->
    ids = @table.find("td > p").map -> $(this).attr("id")
    expect(ids[0]).toEqual "item1"
    expect(ids[1]).toEqual "item2"
    expect(ids[2]).toEqual "item3"
