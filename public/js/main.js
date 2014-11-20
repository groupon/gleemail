// Generated by CommonJS Everywhere 0.9.7
(function (global) {
  function require(file, parentModule) {
    if ({}.hasOwnProperty.call(require.cache, file))
      return require.cache[file];
    var resolved = require.resolve(file);
    if (!resolved)
      throw new Error('Failed to resolve module ' + file);
    var module$ = {
        id: file,
        require: require,
        filename: file,
        exports: {},
        loaded: false,
        parent: parentModule,
        children: []
      };
    if (parentModule)
      parentModule.children.push(module$);
    var dirname = file.slice(0, file.lastIndexOf('/') + 1);
    require.cache[file] = module$.exports;
    resolved.call(module$.exports, module$, module$.exports, dirname, file);
    module$.loaded = true;
    return require.cache[file] = module$.exports;
  }
  require.modules = {};
  require.cache = {};
  require.resolve = function (file) {
    return {}.hasOwnProperty.call(require.modules, file) ? require.modules[file] : void 0;
  };
  require.define = function (file, fn) {
    require.modules[file] = fn;
  };
  var process = function () {
      var cwd = '/';
      return {
        title: 'browser',
        version: 'v0.10.33',
        browser: true,
        env: {},
        argv: [],
        nextTick: global.setImmediate || function (fn) {
          setTimeout(fn, 0);
        },
        cwd: function () {
          return cwd;
        },
        chdir: function (dir) {
          cwd = dir;
        }
      };
    }();
  require.define('/src/client/gleemail.coffee', function (module, exports, __dirname, __filename) {
    angular.module('Gleemail', [
      'ng',
      'ngResource'
    ]);
    require('/src/client/routes.coffee', module);
    require('/src/client/controllers/main.coffee', module);
    require('/src/client/controllers/config-form.coffee', module);
  });
  require.define('/src/client/controllers/config-form.coffee', function (module, exports, __dirname, __filename) {
    angular.module('Gleemail').controller('ConfigForm', function ($scope) {
      return $scope.onSubmit = function () {
        if ($scope.config)
          configResource.save({ id: $scope.displayedTemplate.name }, $scope.config);
        return $scope.showConfig = false;
      };
    });
  });
  require.define('/src/client/controllers/main.coffee', function (module, exports, __dirname, __filename) {
    var app;
    app = angular.module('Gleemail');
    app.service('$config', function ($http) {
      var r;
      r = {};
      $http.get('/config.json').success(function (data) {
        var k, v;
        return function (accum$) {
          for (k in data) {
            v = data[k];
            accum$.push(r[k] = v);
          }
          return accum$;
        }.call(this, []);
      });
      return r;
    });
    app.controller('Main', function ($scope, $config, $resource, $location) {
      var configResource, displayTemplate, match, rendererResource, socket, templateListResource;
      templateListResource = $resource('/templates.json');
      rendererResource = $resource('/renderers');
      configResource = $resource('/templates/:id/config');
      $scope.$config = $config;
      $scope.renderers = rendererResource.query();
      $scope.templateList = templateListResource.query();
      $scope.textContent = null;
      $scope.displayedTemplate = null;
      $scope.exportedTemplate = null;
      $scope.dataIndex = 0;
      $scope.chosenRenderer = null;
      $scope.iframeSrc = '';
      if (match = $location.url().match(/^\/templates\/([^\/]+)$/))
        $scope.displayedTemplate = { name: match[1] };
      $scope.$watch('chosenRenderer', function (renderer) {
        if (renderer) {
          $.get('/templates/' + $scope.displayedTemplate.name + '.html?useAbsoluteUrls=true&renderer=' + renderer.key + '&dataIndex=' + $scope.dataIndex, function (html) {
            return $scope.$apply(function () {
              return $scope.exportedTemplate = html;
            });
          });
          return setTimeout(function () {
            return $scope.$apply(function () {
              return $scope.chosenRenderer = null;
            });
          });
        }
      });
      $scope.$watch('displayedTemplate', function (template) {
        var name;
        if (!template)
          return;
        if (name = null != $scope.displayedTemplate ? $scope.displayedTemplate.name : void 0) {
          $scope.config = configResource.get({ id: name });
          $scope.dataIndex = 0;
          return $location.url('/templates/' + name);
        }
      });
      $scope.renderHTML = function (renderer) {
        return $scope.chosenRenderer = renderer;
      };
      $scope.renderText = function (renderer) {
        return $.get('/templates/' + $scope.displayedTemplate.name + '.txt?renderer=' + renderer.key + '&dataIndex=' + $scope.dataIndex, function (data) {
          return $scope.$apply(function () {
            return $scope.textContent = data;
          });
        });
      };
      $scope.previewPrevData = function () {
        return $scope.dataIndex -= 1;
      };
      $scope.previewNextData = function () {
        return $scope.dataIndex += 1;
      };
      $scope.onNewEmailClicked = function () {
        var templateName;
        templateName = prompt('Project Name:');
        if (!templateName)
          return;
        return $.ajax({
          type: 'POST',
          dataType: 'json',
          url: '/templates',
          data: { templateName: templateName },
          error: function () {
            return console.error(arguments);
          },
          success: function () {
            return $scope.$apply(function () {
              var newTemplate;
              newTemplate = { name: templateName };
              $scope.templateList = $scope.templateList.concat([newTemplate]);
              return $scope.displayedTemplate = newTemplate;
            });
          }
        });
      };
      $scope.onLitmusClicked = function () {
        if (!confirm('Are you sure you want to send this to Litmus?'))
          return;
        return $.ajax({
          type: 'POST',
          dataType: 'json',
          url: '/templates/' + $scope.displayedTemplate.name + '/litmus?useAbsoluteUrls=true&dataIndex=' + $scope.dataIndex,
          success: function (data) {
            return console.log('Litmus Results', data);
          },
          error: function (err) {
            return console.error(err);
          }
        });
      };
      $scope.mailToMeClicked = function () {
        var email;
        return function (accum$) {
          for (var i$ = 0, length$ = $config.myemails.length; i$ < length$; ++i$) {
            email = $config.myemails[i$];
            accum$.push($.ajax({
              type: 'POST',
              dataType: 'json',
              data: { email: email },
              url: '/templates/' + $scope.displayedTemplate.name + '/email?useAbsoluteUrls=true&dataIndex=' + $scope.dataIndex,
              error: function (err) {
                return console.error(err);
              }
            }));
          }
          return accum$;
        }.call(this, []);
      };
      $scope.onEmailClicked = function () {
        var email;
        email = prompt('Send to email:');
        if (!email)
          return;
        return $.ajax({
          type: 'POST',
          dataType: 'json',
          data: { email: email },
          url: '/templates/' + $scope.displayedTemplate.name + '/email?useAbsoluteUrls=true&dataIndex=' + $scope.dataIndex,
          error: function (err) {
            return console.error(err);
          }
        });
      };
      $scope.onShipToEloquaClicked = function () {
        if (!confirm('Are you sure you want to send this to Eloqua?'))
          return;
        return $.ajax({
          type: 'POST',
          dataType: 'json',
          url: '/templates/' + $scope.displayedTemplate.name + '/eloqua',
          error: function (err) {
            return console.error(err);
          }
        });
      };
      displayTemplate = function (template) {
        var cacheBuster;
        cacheBuster = new Date().getTime();
        return $scope.iframeSrc = '/templates/' + template.name + '.html?cache-buster=' + cacheBuster + '&dataIndex=' + $scope.dataIndex;
      };
      $scope.$watch('displayedTemplate', function (template) {
        if (template)
          return displayTemplate(template);
      });
      $scope.$watch('dataIndex', function (index) {
        if ($scope.displayedTemplate)
          return displayTemplate($scope.displayedTemplate);
      });
      socket = io('http://localhost');
      return socket.on('connect', function () {
        return socket.on('template-updated', function (template) {
          if (template.name === (null != $scope.displayedTemplate ? $scope.displayedTemplate.name : void 0)) {
            displayTemplate($scope.displayedTemplate);
            return $scope.$apply();
          }
        });
      });
    });
  });
  require.define('/src/client/routes.coffee', function (module, exports, __dirname, __filename) {
    angular.module('Gleemail').config(function ($routeProvider, $locationProvider) {
      $routeProvider.when('/', { templateUrl: '/templates/preview.html' });
      $routeProvider.when('/templates/:id', { templateUrl: '/templates/preview.html' });
      return $locationProvider.html5Mode(true);
    });
  });
  require('/src/client/gleemail.coffee');
}.call(this, this));