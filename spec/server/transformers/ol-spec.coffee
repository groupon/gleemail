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
transform = require "../../../src/server/transformers/ol"

describe "transforming ol elements", ->
  beforeEach ->
    @$ = cheerio.load """
      <ol id="my-ol" class="my-class">
        <li id="li1">Number 1</li>
        <li id="li2">Number 2</li>
        <li id="li3">Number 3</li>
      </ol>
    """
    transform @$
    @table = @$("table")

  it "replaces the ol with a table", ->
    expect(@$("ol").length).toEqual 0
    expect(@table.length).toEqual 1

  it "maintains attributes from the ol", ->
    expect(@table.attr "id").toEqual "my-ol"
    expect(@table.hasClass "my-class").toBeTruthy()

  it "adds the 'ol' class to the table", ->
    expect(@table.hasClass "ol").toBeTruthy()

  it "adds a tr for each original li", ->
    expect(@table.find("tr").length).toEqual 3

  it "copies attributes from li to tr", ->
    trs = @table.find("tr")
    expect(@$(trs[0]).attr "id").toEqual "li1"
    expect(@$(trs[1]).attr "id").toEqual "li2"
    expect(@$(trs[2]).attr "id").toEqual "li3"

  it "adds the number to the first td in each row", ->
    tds = @table.find("tr > td")
    expect(@$(tds[0]).html()).toEqual "1.&#xA0;"
    expect(@$(tds[2]).html()).toEqual "2.&#xA0;"
    expect(@$(tds[4]).html()).toEqual "3.&#xA0;"

  it "sets valign=top on the number tds", ->
    tds = @table.find("tr > td")
    expect(@$(tds[0]).attr "valign").toEqual "top"
    expect(@$(tds[2]).attr "valign").toEqual "top"
    expect(@$(tds[4]).attr "valign").toEqual "top"

  it "moves the li contents into the second tds", ->
    tds = @table.find("tr > td")
    expect(@$(tds[1]).html()).toEqual "Number 1"
    expect(@$(tds[3]).html()).toEqual "Number 2"
    expect(@$(tds[5]).html()).toEqual "Number 3"
