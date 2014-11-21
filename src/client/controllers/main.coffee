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

app = angular.module("Gleemail")

app.service "$config", ($http) ->
  r = {}
  $http.get('/config.json').success (data)->
    for k,v of data
      r[k] = v
  r

app.controller "Main", ($scope, $config, $resource, $location, $http) ->
  toastr.options.positionClass = 'toast-top-left'

  templateListResource = $resource "/templates.json"
  rendererResource = $resource "/renderers"
  configResource = $resource "/templates/:id/config"

  $scope.$config = $config
  $scope.renderers = rendererResource.query()
  $scope.templateList = templateListResource.query()
  $scope.textContent = null
  $scope.displayedTemplate = null
  $scope.exportedTemplate = null
  $scope.dataIndex = 0
  $scope.chosenRenderer = null
  $scope.iframeSrc = ""

  if match = $location.url().match /^\/templates\/([^\/]+)$/
    $scope.displayedTemplate = name: match[1]

  $scope.$watch "chosenRenderer", (renderer) ->
    if renderer
      $.get "/templates/#{$scope.displayedTemplate.name}.html?useAbsoluteUrls=true&renderer=#{renderer.key}&dataIndex=#{$scope.dataIndex}", (html) ->
        $scope.$apply ->
          $scope.exportedTemplate = html
      setTimeout ->
        $scope.$apply ->
          $scope.chosenRenderer = null

  $scope.$watch "displayedTemplate", (template) ->
    return unless template
    if name = $scope.displayedTemplate?.name
      $scope.config = configResource.get(id: name)
      $scope.dataIndex = 0
      $location.url "/templates/#{name}"

  $scope.renderHTML = (renderer) ->
    $scope.chosenRenderer = renderer

  $scope.renderText = (renderer) ->
    $.get "/templates/#{$scope.displayedTemplate.name}.txt?renderer=#{renderer.key}&dataIndex=#{$scope.dataIndex}", (data) ->
      $scope.$apply ->
        $scope.textContent = data

  $scope.previewPrevData = ->
    $scope.dataIndex -= 1

  $scope.previewNextData = ->
    $scope.dataIndex += 1

  $scope.onNewEmailClicked = ->
    templateName = prompt "Project Name:"
    return unless templateName
    $.ajax
      type: "POST"
      dataType: "json"
      url: "/templates"
      data:
        templateName: templateName
      error: -> console.error arguments
      success: ->
        $scope.$apply ->
          newTemplate = name: templateName
          $scope.templateList = $scope.templateList.concat [newTemplate]
          $scope.displayedTemplate = newTemplate

  $scope.onLitmusClicked = ->
    return unless confirm "Are you sure you want to send this to Litmus?"
    $.ajax
      type: "POST"
      dataType: "json"
      url: "/templates/#{$scope.displayedTemplate.name}/litmus?useAbsoluteUrls=true&dataIndex=#{$scope.dataIndex}"
      success: (data) ->
        console.log "Litmus Results", data
      error: (err) ->
        console.error err

  sendEmail = (email)->
    url = "/templates/#{$scope.displayedTemplate.name}/email?useAbsoluteUrls=true&dataIndex=#{$scope.dataIndex}"
    r = $http.post(url, { email: email})
    r.success ()->
      toastr.success "Email to <i>#{email}</i> sended"
    r.error (err)->
      toastr.error "Error with sending to <i>#{email}</i>"
      console.error err

  $scope.mailToMeClicked = ->
    _.each $config.myemails, sendEmail

  $scope.onEmailClicked = ->
    email = prompt "Send to email:"
    sendEmail(email) if email

  # Preview

  displayTemplate = (template) ->
    cacheBuster = new Date().getTime()
    $scope.iframeSrc = "/templates/#{template.name}.html?cache-buster=#{cacheBuster}&dataIndex=#{$scope.dataIndex}"

  $scope.$watch "displayedTemplate", (template) ->
    displayTemplate(template) if template

  $scope.$watch "dataIndex", (index) ->
    displayTemplate $scope.displayedTemplate if $scope.displayedTemplate

  socket = io("http://localhost")
  socket.on "connect", ->
    socket.on "template-updated", (template) ->
      if template.name == $scope.displayedTemplate?.name
        displayTemplate($scope.displayedTemplate)
        $scope.$apply()
