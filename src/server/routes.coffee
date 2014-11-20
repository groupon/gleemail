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

fs = require "fs"
pathLib = require "path"
config = require "./config"
Litmus = require "./litmus-client"
FileWatcher = require "./file-watcher"
renderEmailTemplate = require "./render-email-template"
EloquaClient = require "./eloqua-client"
deliverEmail = require "./deliver-email"
createTemplate = require "./create-template"
templateConfig = require "./template-config"
renderers = require("./transformers/template").renderers
templates = require "./templates"

LITMUS_CLIENTS = ["android22", "android4", "aolonline", "androidgmailapp", "appmail6", "iphone5s", "ipadmini", "ipad", "gmailnew", "ffgmailnew", "chromegmailnew", "iphone4", "iphone5", "ol2007", "ol2010", "ol2011", "ol2013", "outlookcom", "ffoutlookcom", "chromeoutlookcom", "plaintext", "yahoo", "ffyahoo", "chromeyahoo", "windowsphone8"]

module.exports = (app) ->
  app.get "/config.json", (req, res) ->
    res.json config

  app.get "/templates.json", (req, res) ->
    templates.all (err, templates) ->
      return res.status(500).send err if err
      res.send templates

  app.get "/templates/:templateName.html", (req, res) ->
    renderEmailTemplate req.params.templateName, "html", renderOptions(req), (err, contents) ->
      return res.status(500).send err if err
      res.send contents

  app.get "/templates/:templateName.txt", (req, res) ->
    renderEmailTemplate req.params.templateName, "text", renderOptions(req), (err, contents) ->
      return res.status(500).send err if err
      res.send contents

  app.get "/templates/:templateName/images/:path", (req, res) ->
    fs.readFile "#{config.root}/templates/#{req.params.templateName}/images/#{req.params.path}", (err, img) ->
      return res.status(500).send err if err
      res.send img

  app.post "/templates/:templateName/litmus", (req, res) ->
    renderEmailTemplate req.params.templateName, "html", renderOptions(req, useAbsoluteUrls: true), (err, contents) ->
      return res.status(500).send(err) if err
      litmusClient = new Litmus
        username: config.litmus.username
        password: config.litmus.password
        url: config.litmus.url
        clients: LITMUS_CLIENTS
        html: contents
        title: "TEST: #{req.params.templateName}"
      litmusClient.run (err, status) ->
        return res.status(500).send err if err
        res.status(200).send status

  app.post "/templates/:templateName/email", (req, res) ->
    templateName = req.params.templateName
    recipient = req.param "email"
    unless recipient
      return res.status(400).send error: "No email received"
    deliverEmail templateName, [recipient], renderOptions(req, useAbsoluteUrls: true), (err) ->
      return res.status(500).send err if err
      res.send "ok"

  app.post "/templates", (req, res) ->
    templateName = req.param "templateName"
    return res.status(404).send "not found" unless templateName
    createTemplate templateName, (err, path) ->
      return res.status(500).send err if err
      FileWatcher.instance().watchTemplate templateName
      res.send "ok"

  app.post "/templates/:templateName/eloqua", (req, res) ->
    client = new EloquaClient(req.params.templateName)
    client.save (err, payload) ->
      return res.status(500).send err if err
      res.send payload

  app.get "/templates/:templateName/config", (req, res) ->
    templateConfig req.params.templateName, (err, tconfig) ->
      return res.status(500).send err if err
      res.send tconfig

  app.post "/templates/:templateName/config", (req, res) ->
    templateConfig req.params.templateName, req.body, (err, tconfig) ->
      return res.status(500).send err if err
      tconfig.save (err) ->
        return res.status(500).send err if err
        res.send req.body

  app.get "/renderers", (req, res) ->
    keys = Object.keys(renderers)
    res.send keys.map (key) ->
      {key: key, label: renderers[key].label}

  # Send all other GET requests to the Angular app
  app.get "*", (req, res) ->
    res.sendFile pathLib.resolve("#{__dirname}/../../public/index.html")

renderOptions = (req, overrides={}) ->
  options =
    useAbsoluteUrls: req.param("useAbsoluteUrls") == "true"
    renderer: req.param("renderer")
    dataIndex: parseInt(req.param("dataIndex"), 10) if req.param("dataIndex")
  options[k] = v for k, v in overrides
  options
