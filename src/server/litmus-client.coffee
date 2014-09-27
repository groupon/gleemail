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

request = require "request"
mail = require("nodemailer").mail
cheerio = require "cheerio"
_ = require "underscore"

module.exports = class Litmus
  constructor: (options) ->
    @html = options.html
    @title = options.title
    @baseUrl = options.url
    @clients = options.clients
    @auth =
      user: options.username
      pass: options.password

  run: (cb) ->
    @litmusId (err, id) =>
      return cb(err) if err
      if id
        @updateTest id, cb
      else
        @createTest cb

  litmusId: (cb) ->
    opts =
      auth: @auth
      url: "#{@baseUrl}/tests.xml"
    request.get opts, (err, res, body) ->
      return cb(err) if err
      try
        id = null
        $ = cheerio.load body, xmlMode: true
        title = @title

        $name = $("name").filter ->
          $nameTag = $(this)
          $nameTag.text() == title

        id = $matchedName.parent().children("id").text() if $name.length
        cb(null, id)
      catch e
        cb(e)

  parseStatus: (body) ->
    $ = cheerio.load body, xmlMode: true
    statuses = $("status")
    delayed = []
    unavailable = []
    seconds = 0

    avgTimes = $("average_time_to_process")
    avgTimes.each (i, el) ->
      seconds += parseInt($(this).text(), 10)
    seconds = Math.round(seconds / avgTimes.length)

    statuses.each (i, el) ->
      $this = $(this)
      statusCode = parseInt($this.text(), 10)
      appName = $this.parent().children("application_long_name").text()

      switch statusCode
        when 1
          delayed.push(appName)
        when 2
          unavailable.push(appName)

    time: seconds
    delayed: delayed
    unavailable: unavailable

  createTest: (cb) ->
    opts =
      auth: @auth
      headers:
        "Content-type": "application/xml"
        "Accept": "application/xml"
      body: @xml()
      url: "#{@baseUrl}/emails.xml"

    request.post opts, (err, res, body) =>
      return cb(err) if err
      try
        status = res.headers.status
        unless /^2/.test status
          return cb(status)
        status = @parseStatus body
        cb(null, status)
      catch e
        cb(e)

  updateTest: (id, cb) ->
    opts =
      auth: @auth
      headers:
        "Content-type": "application/xml"
        "Accept": "application/xml"
      body: @xml()
      url: "#{@baseUrl}/tests/#{id}/versions.xml"

    request.post opts, (err, res, body) =>
      return cb(err) if err
      @mailNewVersion body, (err) =>
        return cb(err) if err
        try
          status = @parseStatus body
          cb(null, status)
        catch e
          cb(e)

  mailNewVersion: (body, cb) ->
    try
      $ = cheerio.load(body)
      guid = $("url_or_guid").text()

      mail
        from: "no-reply@test.com"
        to: guid
        subject: @title
        text: ""
        html: @html
      cb()
    catch e
      cb(e)

  xml: ->
    xml = """
      <?xml version="1.0"?>
      <test_set>
        <save_defaults>false</save_defaults>
        <use_defaults>false</use_defaults>
        <email_source>
          <body>
            <![CDATA[#{@html}]]>
          </body>
          <subject>#{@title}</subject>
        </email_source>
        <applications type="array">
    """
    for client in @clients
      xml += """
        <application>
          <code>#{client}</code>
        </application>
      """
    xml += """
      </applications>
    </test_set>
    """
    xml
