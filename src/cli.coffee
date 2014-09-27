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
exec = require("child_process").exec
renderEmailTemplate = require "./server/render-email-template"
config = require "./server/config"

exports.run = (command, options...) ->
  if commands[command]
    commands[command](options...)
  else
    commands.help()

commands =
  help: (commandName) ->
    switch commandName
      when "render"
        console.log """
          Usage:
            gleemail render <templateName> [-ort]
              -i <index>    :: Render template with data in position <index> in the data file
              -o <filepath> :: Write output to the specified file (defaults to stdout)
              -r <renderer> :: Use the specified renderer (defaults to "data")
              -t <type>     :: Render either "html" or "text" versions (defaults to "html")
        """
      else
        console.log """
          Usage:
            gleemail project <dirname>       :: Bootstrap an email project directory structure
            gleemail template <templateName> :: Bootstrap an email template in the current directory
            gleemail start                   :: Starts the development server on port 4343
            gleemail render <templateName>   :: Outputs the rendered HTML to stdout
            gleemail help <command>          :: See documentation for a particular command
        """

  project: (dirname) ->
    targetDir = "#{config.root}/#{dirname}"
    exec "cp -r #{__dirname}/../project-template #{targetDir}", (err, stdout, stderr) ->
      if err
        console.error err
        console.error stderr
      else
        console.log "Created project #{targetDir}"
        # Update the root path to be the newly created dir,
        # otherwise the `template` command will choke
        config.root = targetDir
        commands.template "example"

  template: (templateName) ->
    createTemplate = require "./server/create-template"
    createTemplate templateName, (err, path) ->
      if err
        console.error err
      else
        console.log "Created #{path}"

  start: ->
    require "./server"
    port = process.env.PORT || 4433
    exec "open http://localhost:#{port}"

  dev: ->
    require "coffee-script-redux/register"
    require "#{__dirname}/../src/server"

  render: (templateName, opts...) ->
    opts = parseOpts(opts)
    type = "html"
    options =
      useAbsoluteUrls: true
      renderer: opts.r
      dataIndex: parseInt(opts.i, 10) if opts.i
    renderEmailTemplate templateName, opts.t || "html", options, (err, contents) ->
      if opts.o
        fs.writeFileSync pathLib.resolve(opts.o), contents
      else
        console.log contents

parseOpts = (opts) ->
  out = {}
  key = null
  for val in opts
    if m = val.match /^-(\w)$/
      key = m[1]
    else
      out[key] = val
      key = null
  out
