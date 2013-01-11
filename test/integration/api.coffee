request = require 'request'
should = require 'should'
settings = require '../settings.json'

describe 'API', ->
  context "When I'm logged in", ->
    before (done) ->
      @token = '339231725782156'
      @user = 'ickletest'
      @password = 'toottoot'
      @fullName = 'Mr Ickle Test'

      # Set password & login
      request.post
        uri: "#{settings.serverURL}/api/token/#{@token}"
        form:
          password: @password
      , (err, res) =>
        @loginURL = "#{settings.serverURL}/login"
        request.get @loginURL, =>
          request.post
            uri: @loginURL
            form:
              username: @user
              password: @password
          , (err, res) =>
              @loginResponse = res
              done(err)

    it 'managed to log in', ->
      should.exist @loginResponse
      # check we're being redirected to /, as opposed to /login
      @loginResponse.body.should.include 'Redirecting to /'
      @loginResponse.body.should.not.include 'Redirecting to /login'

    describe 'Tools', ->
      context 'POST /api/tools', ->
        context 'when I create a tool', ->
          response = null
          dataset = null

          before (done) ->
            @toolName = "int-test-#{String(Math.random()*Math.pow(2,32))[0..6]}"
            request.post
              uri: "#{settings.serverURL}/api/tools"
              form:
                name: @toolName
                type: 'view'
                gitUrl: 'git://github.com/scraperwiki/spreadsheet-tool.git'
            , (err, res) =>
              response = res
              @tool = JSON.parse res.body
              done()

          it 'creates a new tool', ->
            response.should.have.status 201

          it 'returns the newly created tool', ->
            should.exist @tool.name
            @tool.name.should.equal @toolName

      context 'GET /api/tools', ->
        before (done) ->
          request.get "#{settings.serverURL}/api/tools", (err, res) =>
            @body = res.body
            done()

        it 'returns a list of tools', ->
          tools = JSON.parse @body
          tools.length.should.be.above 0

        it 'returns the right fields', ->
          tools = JSON.parse @body
          should.exist tools[0].name
          should.exist tools[0].gitUrl
          should.exist tools[0].type

    describe 'Datasets', ->
      context 'when I create a dataset', ->
        response = null
        dataset = null

        before (done) ->
          request.post
            uri: "#{settings.serverURL}/api/#{@user}/datasets"
            form:
              displayName: 'Biscuit'
              box: String(Math.random() * Math.pow(2, 32))
          , (err, res) ->
            response = res
            dataset = JSON.parse res.body
            done()

        context 'POST /api/:user/datasets', ->
          it 'creates a new dataset', ->
            response.should.have.status 200

          it 'returns the newly created dataset', ->
            should.exist dataset.box
            dataset.displayName.should.equal 'Biscuit'

        context 'GET /api/:user/datasets/:id', ->
          it 'returns a single dataset', (done)  ->
            request.get "#{settings.serverURL}/api/#{@user}/datasets/#{dataset.box}", (err, res) ->
              dataset = JSON.parse res.body
              should.exist dataset.box
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.get "#{settings.serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

          it "403 errors if the user doesn't exist", (done) ->
            request.get "#{settings.serverURL}/api/MRINVISIBLE/datasets/#{dataset.box}", (err, res) ->
              res.should.have.status 403
              done()

        context 'PUT /api/:user/datasets/:id', ->
          it 'changes the display name of a single dataset', (done) ->
            request.put
              uri: "#{settings.serverURL}/api/#{@user}/datasets/#{dataset.box}"
              form:
                displayName: 'Cheese'
            , (err, res) =>
              res.should.have.status 200
              request.get "#{settings.serverURL}/api/#{@user}/datasets/#{dataset.box}", (err, res) ->
                dataset = JSON.parse res.body
                dataset.displayName.should.equal 'Cheese'
                done(err)

          it 'changes the owner of a single dataset', (done) ->
            @newowner = 'ehg'
            request.put
              uri: "#{settings.serverURL}/api/#{@user}/datasets/#{dataset.box}"
              form:
                user: @newowner
            , (err, res) =>
              res.should.have.status 200
              done(err)

          it "that dataset doesn't appear in my list of datasets any more", (done) ->
            request.get "#{settings.serverURL}/api/#{@user}/datasets", (err, res) ->
              res.body.should.not.include "#{dataset.box}"
              done()

          it "404 errors if the dataset doesn't exist", (done) ->
            request.put "#{settings.serverURL}/api/#{@user}/datasets/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

      context 'GET: /api/:user/datasets', ->
        it 'returns a list of datasets', (done) ->
          request.get "#{settings.serverURL}/api/#{@user}/datasets", (err, res) ->
            datasets = JSON.parse res.body
            datasets.length.should.be.above 1
            done(err)

    describe 'Views', ->
      context 'when I create a view', ->
        response = null
        view = null

        before (done) ->
          request.post
            uri: "#{settings.serverURL}/api/#{@user}/views"
            form:
              displayName: 'Tea'
              box: String(Math.random() * Math.pow(2, 32))
          , (err, res) ->
            response = res
            view = JSON.parse res.body
            done()

        context 'POST /api/:user/views', ->
          it 'creates a new view', ->
            response.should.have.status 200

          it 'returns the newly created view', ->
            should.exist view.box
            view.displayName.should.equal 'Tea'

        context 'GET /api/:user/views/:id', ->
          it 'returns a single view', (done)  ->
            request.get "#{settings.serverURL}/api/#{@user}/views/#{view.box}", (err, res) ->
              view = JSON.parse res.body
              should.exist view.box
              done()

          it "404 errors if the view doesn't exist", (done) ->
            request.get "#{settings.serverURL}/api/#{@user}/views/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

          it "403 errors if the user doesn't exist", (done) ->
            request.get "#{settings.serverURL}/api/MRINVISIBLE/views/#{view.box}", (err, res) ->
              res.should.have.status 403
              done()

        context 'PUT /api/:user/views/:id', ->
          it 'changes the display name of a single view', (done) ->
            request.put
              uri: "#{settings.serverURL}/api/#{@user}/views/#{view.box}"
              form:
                displayName: 'Cheese'
            , (err, res) =>
              res.should.have.status 200
              request.get "#{settings.serverURL}/api/#{@user}/views/#{view.box}", (err, res) ->
                view = JSON.parse res.body
                view.displayName.should.equal 'Cheese'
                done(err)

          xit 'changes the owner of a single view', (done) ->
            @newowner = 'ehg'
            request.put
              uri: "#{settings.serverURL}/api/#{@user}/views/#{view.box}"
              form:
                user: @newowner
            , (err, res) =>
              res.should.have.status 200
              done(err)

          xit "that view doesn't appear in my list of views any more", (done) ->
            request.get "#{settings.serverURL}/api/#{@user}/views", (err, res) ->
              res.body.should.not.include "#{view.box}"
              done()

          it "404 errors if the view doesn't exist", (done) ->
            request.put "#{settings.serverURL}/api/#{@user}/views/NOTEXIST", (err, res) ->
              res.should.have.status 404
              done()

      context 'GET: /api/:user/views', ->
        it 'returns a list of views', (done) ->
          request.get "#{settings.serverURL}/api/#{@user}/views", (err, res) ->
            views = JSON.parse res.body
            views.length.should.be.above 1
            done(err)

    describe 'Users', ->
      context "When I'm a staff member", ->
        before (done) ->
          # logout
          request.get "#{settings.serverURL}/logout", done
        before (done) ->
          @loginURL = "#{settings.serverURL}/login"
          @user = "teststaff"
          @password = process.env.CU_TEST_STAFF_PASSWORD
          request.get @loginURL, =>
            request.post
              uri: @loginURL
              form:
                username: @user
                password: @password
            , (err, res) =>
                @loginResponse = res
                done(err)
        it 'allows me to create a new profile', (done) ->
          @newUser = "new-#{String(Math.random()*Math.pow(2,32))[0..6]}"
          @newPassword = "newpass"
          request.post
            uri: "#{settings.serverURL}/api/#{@newUser}"
            form:
              email: 'random@example.com'
              displayName: 'Ran Dom Test'
          , (err, resp, body) =>
            obj = JSON.parse body
            @token = obj.token
            resp.should.have.status 201
            done(err)
        it '... and I can set the password', (done) ->
          request.post
            uri: "#{settings.serverURL}/api/token/#{@token}"
            form:
              password: @newPassword
          , (err, resp, body) ->
             resp.should.have.status 200
             done(err)

