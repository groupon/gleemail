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
transform = require "../../../src/server/transformers/img"
config = require "../../../src/server/config"
$ = null

describe "img tag transformation", ->
  describe "using relative URLs", ->
    describe "with leading /", ->
      beforeEach ->
        $ = cheerio.load '<img src="/images/pic.png" />'
        transform $, "myTemplate", useAbsoluteUrls: false, (err, $$$) =>
          @img = $$$("img")

      it "prefixes the src attribute with template name", ->
        expect(@img.attr "src").toEqual "/templates/myTemplate/images/pic.png"

    describe "without leading /", ->
      beforeEach ->
        $ = cheerio.load '<img src="images/pic.png" />'
        transform $, "myTemplate", useAbsoluteUrls: false, (err, $$$) =>
          @img = $$$("img")

      it "prefixes the src attribute with template name", ->
        expect(@img.attr "src").toEqual "/templates/myTemplate/images/pic.png"

    describe "with an external URL", ->
      beforeEach ->
        $ = cheerio.load '<img src="http://mydomain.com/images/pic.png" />'
        transform $, "myTemplate", useAbsoluteUrls: false, (err, $$$) =>
          @img = $$$("img")

      it "leaves the URL as is", ->
        expect(@img.attr "src").toEqual "http://mydomain.com/images/pic.png"

  describe "using absolute URLs", ->
    beforeEach ->
      config.s3 =
        bucket: "myBucket"

    describe "with leading /", ->
      beforeEach ->
        $ = cheerio.load '<img src="/images/pic.png" />'
        transform $, "myTemplate", useAbsoluteUrls: true, (err, $$$) =>
          @img = $$$("img")

      it "prefixes the src attribute with template name", ->
        expect(@img.attr "src").toEqual "https://myBucket.s3.amazonaws.com/myTemplate/images/pic.png"

    describe "without leading /", ->
      beforeEach ->
        $ = cheerio.load '<img src="images/pic.png" />'
        transform $, "myTemplate", useAbsoluteUrls: true, (err, $$$) =>
          @img = $$$("img")

      it "prefixes the src attribute with template name", ->
        expect(@img.attr "src").toEqual "https://myBucket.s3.amazonaws.com/myTemplate/images/pic.png"

    describe "with an external URL", ->
      beforeEach ->
        $ = cheerio.load '<img src="http://mydomain.com/images/pic.png" />'
        transform $, "myTemplate", useAbsoluteUrls: true, (err, $$$) =>
          @img = $$$("img")

      it "leaves the URL as is", ->
        expect(@img.attr "src").toEqual "http://mydomain.com/images/pic.png"
