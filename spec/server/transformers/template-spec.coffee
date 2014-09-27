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

renderTemplate = require "../../../src/server/transformers/template"

describe "rendering template values", ->
  html = "<p>Sent email to {{ name }} at {{ email }}.</p>"

  it "defaults to rendering with data from data.json", (done) ->
    renderTemplate html, "test-example", {}, (err, rendered) ->
      expected = "<p>Sent email to John Doe at john@doe.com.</p>"
      expect(rendered).toEqual expected
      done()

  it "uses mustache renderer when renderer=mustache", (done) ->
    renderTemplate html, "test-example", renderer: "mustache", (err, rendered) ->
      expected = "<p>Sent email to {{ name }} at {{ mappedEmail }}.</p>"
      expect(rendered).toEqual expected
      done()

  it "uses eloqua renderer when renderer=eloqua", (done) ->
    renderTemplate html, "test-example", renderer: "eloqua", (err, rendered) ->
      expected = "<p>Sent email to <span class='eloquaemail'>name</span> at <span class='eloquaemail'>mappedEmail</span>.</p>"
      expect(rendered).toEqual expected
      done()

  it "uses freemarker renderer when renderer=freemarker", (done) ->
    renderTemplate html, "test-example", renderer: "freemarker", (err, rendered) ->
      expected = "<p>Sent email to ${name} at ${mappedEmail}.</p>"
      expect(rendered).toEqual expected
      done()

  it "uses mailchimp renderer when renderer=mailchimp", (done) ->
    renderTemplate html, "test-example", renderer: "mailchimp", (err, rendered) ->
      expected = "<p>Sent email to *|name|* at *|mappedEmail|*.</p>"
      expect(rendered).toEqual expected
      done()

describe "rendering conditional statements", ->
  html = "<p>Delivered: {{# delivered }}Yes{{/ delivered }}{{^ delivered }}No{{/ delivered}}.</p>"

  it "defaults to rendering with data from data.json", (done) ->
    renderTemplate html, "test-example", {}, (err, rendered) ->
      expected = "<p>Delivered: Yes.</p>"
      expect(rendered).toEqual expected
      done()

  it "throws when renderer=eloqua", (done) ->
    renderTemplate html, "test-example", renderer: "eloqua", (err, rendered) ->
      expect(err.message).toEqual "Eloqua does not support conditionals"
      done()

  it "uses mustache conditionals when renderer=mustache", (done) ->
    renderTemplate html, "test-example", renderer: "mustache", (err, rendered) ->
      expected =  "<p>Delivered: {{# delivered }}Yes{{/ delivered }}{{^ delivered }}No{{/ delivered }}.</p>"
      expect(rendered).toEqual expected
      done()

  xit "uses freemarker conditionals when renderer=freemarker", (done) ->
    renderTemplate html, "test-example", renderer: "freemarker", (err, rendered) ->
      expected = "<p>Delivered: <#if delivered?? && delivered != '' && delivered != false>Yes</#if><#if !(delivered?? && delivered != '' && delivered != false)>No</#if>.</p>"
      expect(rendered).toEqual expected
      done()

  it "uses mailchimp conditionals when renderer=mailchimp", (done) ->
    renderTemplate html, "test-example", renderer: "mailchimp", (err, rendered) ->
      expected =  "<p>Delivered: *|IF:delivered|*Yes*|END:IF|**|IFNOT:delivered|*No*|END:IF|*.</p>"
      expect(rendered).toEqual expected
      done()

describe "rendering loops", ->
  html = "<ul>{{# interests }}<li>{{ name }}</li>{{/ interests }}</ul>"

  it "defaults to rendering with data from data.json", (done) ->
    renderTemplate html, "test-example", {}, (err, rendered) ->
      expected = "<ul><li>Archery</li><li>Badminton</li><li>Cards</li></ul>"
      expect(rendered).toEqual expected
      done()

  it "works with freemarker", (done) ->
    renderTemplate html, "test-example", renderer: "freemarker", (err, rendered) ->
      expected = """
<ul><#if interests?is_enumerable>
  <#assign interests_arr = interests>
<#elseif interests?? && interests != '' && interests != false>
  <#assign interests_arr = [interests]>
<#else>
  <#assign interests_arr = []>
</#if>
<#list interests_arr as interests_arr_item>
  <li>${(interests_arr_item.name)!name}</li>
</#list></ul>
"""
      expect(rendered).toEqual expected
      done()

describe "rendering sections", ->
  html = "<p>{{# company }}{{ name }} at {{ location }}{{/ company }}</p>"

  it "defaults to rendering with data from data.json", (done) ->
    renderTemplate html, "test-example", {}, (err, rendered) ->
      expected = "<p>Acme at 123 Main</p>"
      expect(rendered).toEqual expected
      done()

  it "works with freemarker", (done) ->
    renderTemplate html, "test-example", renderer: "freemarker", (err, rendered) ->
      expected = """
<p><#if company?is_enumerable>
  <#assign company_arr = company>
<#elseif company?? && company != '' && company != false>
  <#assign company_arr = [company]>
<#else>
  <#assign company_arr = []>
</#if>
<#list company_arr as company_arr_item>
  ${(company_arr_item.name)!name} at ${(company_arr_item.location)!location}
</#list></p>
"""
      expect(rendered).toEqual expected
      done()

