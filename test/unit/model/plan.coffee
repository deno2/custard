require '../setup_teardown'

sinon = require 'sinon'
should = require 'should'
_ = require 'underscore'
request = require 'request'

{Plan} = require 'model/plan'
{Box} = require 'model/box'

describe 'Plan (Server)', ->

  describe 'Can set quota of a box', ->
    before (done) ->
      process.env.CU_QUOTA_SERVER = 'testy'
      @request = sinon.stub request, 'post', (opt, cb) ->
        cb null, null, null

      box = new Box
        users: ['freetard']
        name: 'ehaf921'

      Plan.setDiskQuota box, 'free', done

    after ->
      request.post.restore()

    it 'made the right HTTP request to change glusterfs quota', ->
      correctArgs = @request.calledWith
        uri: "#{process.env.CU_QUOTA_SERVER}/quota"
        form:
          path: 'ehaf921'
          size: 8
      correctArgs.should.be.true
