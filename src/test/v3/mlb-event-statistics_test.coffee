'use strict'
should = require 'should'
nock = require 'nock'

MLB = require '../../lib/v3/mlb.js'

describe 'V3 MLB', ->
  mlb = new MLB 'api-key', 't'
  badMlb = new MLB 'bad-key', 't'

  describe '#getEventStatistics()', ->
    scope = undefined
    before ->
      scope = nock('http://api.sportsdatallc.org')
        .get('/mlb-t3/statistics/c8457f5d-d8ed-4949-8c92-b341e5b37fa4.xml?api_key=bad-key')
        .replyWithFile(403, __dirname + '/replies/api-key-error.txt')
        .get('/mlb-t3/statistics/bad-event-id.xml?api_key=api-key')
        .replyWithFile(412, __dirname + '/replies/event-id-error.txt')
        .get('/mlb-t3/statistics/c8457f5d-d8ed-4949-8c92-b341e5b37fa4.xml?api_key=api-key')
        .replyWithFile(200, __dirname + '/replies/event-statistics-200.txt')
        .get('/mlb-t3/statistics/c8457f5d-d8ed-4949-8c92-b341e5b37fa4.xml?api_key=api-key')
        .replyWithFile(200, __dirname + '/replies/event-statistics-200.txt')

    it 'should be a function', ->
      mlb.getEventStatistics.should.be.a('function')

    it 'should should throw error without eventId', ->
      (->
        mlb.getEventStatistics()
      ).should.throwError(/required/)

    it 'should pass error and no result with bad api key', (done) ->
      badMlb.getEventStatistics 'c8457f5d-d8ed-4949-8c92-b341e5b37fa4', (err, result) ->
        err.should.match /HTTP 403/
        should.not.exist result
        done()

    it 'should pass error and not result with bad eventId', (done) ->
      mlb.getEventStatistics 'bad-event-id', (err, result) ->
        err.should.match /HTTP 412/
        should.not.exist result
        done()

    it 'should pass no error and teams as result on 200', (done) ->
      mlb.getEventStatistics 'c8457f5d-d8ed-4949-8c92-b341e5b37fa4', (err, result) ->
        should.not.exist err
        result.should.be.a 'object'
        result.statistics.should.be.a 'object'
        result.statistics.visitor.should.be.a 'object'
        result.statistics.home.should.be.a 'object'
        result.statistics.visitor.hitting.should.be.a 'object'
        result.statistics.home.hitting.should.be.a 'object'
        result.statistics.visitor.pitching.should.be.a 'object'
        result.statistics.home.pitching.should.be.a 'object'
        done()

    it 'should support object literal as param', (done) ->
      params = { eventId: 'c8457f5d-d8ed-4949-8c92-b341e5b37fa4' }
      mlb.getEventStatistics params, (err, result) ->
        should.not.exist err
        result.should.be.a 'object'
        result.statistics.should.be.a 'object'
        result.statistics.visitor.should.be.a 'object'
        result.statistics.home.should.be.a 'object'
        result.statistics.visitor.hitting.should.be.a 'object'
        result.statistics.home.hitting.should.be.a 'object'
        result.statistics.visitor.pitching.should.be.a 'object'
        result.statistics.home.pitching.should.be.a 'object'
        done()

    after ->
      scope.done()
