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
transform = require "../../../src/server/transformers/gm-box"
$ = null

renderBox = (markup) ->
  table = null
  $ = cheerio.load markup
  transform $, "template-name", {}, (err, $$$) ->
    table = $$$("> table")
  table

describe "gm-box transforms", ->
  describe "with one padding", ->
    beforeEach ->
      @table = renderBox """
        <gm-box padding='5px'>
          <div id='content'></div>
        </gm-box>
      """

    it "adds a top row for padding", ->
      tr = @table.find("tr").eq 0
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a right row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(2)
        expect(td.attr "width").toEqual "5"

    it "adds a bottom row for padding", ->
      tr = @table.find("tr").eq 2
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a left row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(0)
        expect(td.attr "width").toEqual "5"

  describe "with two paddings", ->
    beforeEach ->
      @table = renderBox """
        <gm-box padding='5px 10px'>
          <div id='content'></div>
        </gm-box>
      """

    it "adds a top row for padding", ->
      tr = @table.find("tr").eq 0
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a right row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(2)
        expect(td.attr "width").toEqual "10"

    it "adds a bottom row for padding", ->
      tr = @table.find("tr").eq 2
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a left row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(0)
        expect(td.attr "width").toEqual "10"

  describe "with 3 paddings", ->
    beforeEach ->
      @table = renderBox """
        <gm-box padding='5px 6px 7px'>
          <div id='content'></div>
        </gm-box>
      """

    it "adds a top row for padding", ->
      tr = @table.find("tr").eq 0
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a right row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(2)
        expect(td.attr "width").toEqual "6"

    it "adds a bottom row for padding", ->
      tr = @table.find("tr").eq 2
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "7"

    it "adds a left row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(0)
        expect(td.attr "width").toEqual "6"

  describe "with all 4 paddings", ->
    beforeEach ->
      @table = renderBox """
        <gm-box padding='5px 6px 7px 8px'>
          <div id='content'></div>
        </gm-box>
      """

    it "adds a top row for padding", ->
      tr = @table.find("tr").eq 0
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a right row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(2)
        expect(td.attr "width").toEqual "6"

    it "adds a bottom row for padding", ->
      tr = @table.find("tr").eq 2
      tds = tr.find("> td")
      expect(tds.length).toEqual 3
      tds.each ->
        expect($(this).attr "height").toEqual "7"

    it "adds a left row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 3
      trs.each ->
        td = $(this).find("> td").eq(0)
        expect(td.attr "width").toEqual "8"

  describe "with some zero paddings", ->
    beforeEach ->
      @table = renderBox """
        <gm-box padding='5px 6px 0px 0px'>
          <div id='content'></div>
        </gm-box>
      """

    it "adds a top row for padding", ->
      tr = @table.find("tr").eq 0
      tds = tr.find("> td")
      expect(tds.length).toEqual 2
      tds.each ->
        expect($(this).attr "height").toEqual "5"

    it "adds a right row for padding", ->
      trs = @table.find("tr")
      expect(trs.length).toEqual 2
      trs.each ->
        td = $(this).find("> td").eq(1)
        expect(td.attr "width").toEqual "6"
