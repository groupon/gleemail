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
appConfig = require "./config"
templateConfig = require "./template-config"
renderEmailTemplate = require "./render-email-template"

module.exports = class EloquaClient
  constructor: (@templateName) ->

  save: (cb) ->
    @_loadTemplateConfig (err, config) =>
      options =
        useAbsoluteUrls: true
        renderer: "eloqua"
      renderEmailTemplate @templateName, "text", options, (err, plainText) =>
        return cb(err) if err
        renderEmailTemplate @templateName, "html", options, (err, html) =>
          return cb(err) if err
          payload =
            bouncebackEmail: null
            emailFooterId: null
            emailGroupId: null
            emailHeaderId: null
            encodingId: null
            folderId: null
            htmlContent:
              type: "RawHtmlContent"
              html: html
            isPlainTextEditable: false
            name: @templateName
            plainText: plainText
            replyToEmail: config.replyTo?.email
            replyToName: config.replyTo?.name
            senderEmail: config.sender?.email
            senderName: config.sender?.name
            sendPlainTextOnly: false
            subject: config.subject || ""

          if config.eloquaId
            payload.id = config.eloquaId
            # Project already exists, so set the Updated timestamps
            payload.updatedAt = new Date().toISOString()
            payload.updatedBy = appConfig.eloqua.username
          else
            # New project, so set the Created timestamps
            payload.createdAt = new Date().toISOString()
            payload.createdBy = appConfig.eloqua.username

          @deliver payload, cb

  deliver: (payload, cb) ->
    @_withEloquaHost (err, host) =>
      return cb(err) if err
      opts =
        method: "POST"
        url: "#{host}/API/REST/1.0/assets/email"
        headers:
          Authorization: @_auth()
        json: payload
      request opts, (err, response, body) =>
        return cb(err) if err
        unless @config.eloquaId
          @config.eloquaId = body.id
          @config.save()
        cb(null, body)

  _withEloquaHost: (cb) ->
    opts =
      method: "GET"
      url: "https://login.eloqua.com/id"
      headers:
        Authorization: @_auth()
    request opts, (err, response, body) ->
      return cb(err) if err
      try
        parsed = JSON.parse body
        cb null, body.urls.base
      catch e
        cb e

  _loadTemplateConfig: (cb) ->
    return cb null, @config if @config
    templateConfig @templateName, (err, config) =>
      console.error "Error loading template config for '#{@templateName}'", err if err
      @config = config
      cb null, (@config || {})

  _auth: ->
    pair = "#{appConfig.eloqua.company}\\#{appConfig.eloqua.username}:#{appConfig.eloqua.password}"
    encoded = new Buffer(pair).toString("base64")
    "Basic #{encoded}"
