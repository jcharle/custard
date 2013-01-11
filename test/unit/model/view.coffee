sinon = require 'sinon'
should = require 'should'

class TestDb
  class Model
    constructor: (obj) ->
      for k of obj
        @[k] = obj[k]

    toObject: -> @

  save: (callback) ->
    callback null
  @find: (_args, callback) ->
    callback null, [ new Model(name: 'test'),
      new Model(name: 'test2')
    ]

View = require('model/view')(TestDb)

describe 'Server model: View', ->

  before ->
    @saveSpy = sinon.spy TestDb.prototype, 'save'
    @findSpy = sinon.spy TestDb, 'find'
    @view = new View
      user: 'ickle'
      name: 'test'
      displayName: 'Test'
      box: 'sdjfsdf'
      

  context 'when view.save is called', ->
    before (done) ->
      @view.save done

    it 'calls mongoose save method', ->
      @saveSpy.calledOnce.should.be.true

  context 'when view.findAll is called', ->
    before (done) ->
      View.findAll (err, res) =>
        @results = res
        done()

    it 'should return View results', ->
      @results[0].should.be.an.instanceOf View
      @results[0].name.should.equal 'test'
      @results.length.should.equal 2
