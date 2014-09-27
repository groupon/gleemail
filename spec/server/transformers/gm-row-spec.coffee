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
transform = require "../../../src/server/transformers/gm-row"
$ = null

describe "gm-row transformation", ->
  beforeEach ->
    $ = cheerio.load """
      <gm-row id="row">
        <gm-col width="50"><span id="item1">Item 1</span></gm-col>
        <gm-col width="60"><span id="item2">Item 2</span></gm-col>
      </gm-row>
    """
    transform $, "template-name", {}, (err, $$$) =>
      @box = $$$("> gm-box")

  it "builds a gm-box with a table with one row in it", ->
    expect(@box.length).toEqual 1
    expect(@box.find("table").length).toEqual 1
    expect(@box.find("table > tr").length).toEqual 1

  it "copies attributes from the row to the box", ->
    expect(@box.attr "id").toEqual "row"

  it "puts each column content in a table td", ->
    spans = @box.find("table td > span").map -> $(this)
    expect(spans[0].attr("id")).toEqual "item1"
    expect(spans[1].attr("id")).toEqual "item2"

  it "copies column attributes to each table td", ->
    tds = @box.find("table td").map -> $(this)
    expect(tds[0].attr("width")).toEqual "50"
    expect(tds[1].attr("width")).toEqual "60"

  it "removes the original gm-row", ->
    expect($("gm-row").length).toEqual 0
