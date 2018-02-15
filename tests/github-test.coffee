Helper = require("hubot-test-helper")
chai = require("chai")
nock = require("nock")

expect = chai.expect

helper = new Helper("../scripts/github.coffee")

describe "github script", ->

  room = null

  beforeEach ->
    room = helper.createRoom()
    do nock.disableNetConnect

  afterEach ->
    room.destroy()
    nock.cleanAll()

  context "command prs user:<user>", ->
    prResponse = require("./fixtures/pr-response.json")

    beforeEach (done) ->
      nock("https://api.github.com/graphql")
        .post("")
        .reply 200, prResponse
        room.user.say("bob", "@hubot prs user:test-user")
        setTimeout(done, 100)

    it "returns pull requests titles and urls", ->
      expect(room.messages[1][1]).to.have.string("<https://github.com/test-org/test-repo/pull/100|My PR 1>")
      expect(room.messages[2][1]).to.have.string("<https://github.com/test-org/test-repo/pull/200|My PR 2>")

    it "returns pull requests projects", ->
      expect(room.messages[1][1]).to.have.string("real-test-repo")
      expect(room.messages[2][1]).to.have.string("real-test-repo")

    it "returns pull requests checks states", ->
      expect(room.messages[1][1]).to.have.string("Checks state is SUCCESS")
      expect(room.messages[2][1]).to.have.string("Checks state is FAILURE")

    it "returns pull requests reviews states", ->
      expect(room.messages[1][1]).to.have.string("test-reviewer-1: CHANGES_REQUESTED")
      expect(room.messages[1][1]).to.have.string("test-reviewer-2: DISMISSED")
      expect(room.messages[1][1]).to.have.string("test-reviewer-3: PENDING")

  context "command reviews user:<user>", ->
    reviewResponse = require("./fixtures/review-response.json")

    beforeEach (done) ->
      nock("https://api.github.com/graphql")
        .post("")
        .reply 200, reviewResponse
        room.user.say("bob", "@hubot reviews user:test-reviewer-1")
        setTimeout(done, 100)

    it "returns pull requests that need user review titles and urls", ->
      expect(room.messages[1][1]).to.have.string("<https://github.com/test-org/test-repo/pull/300|PR to review 3>")
      expect(room.messages[2][1]).to.have.string("<https://github.com/test-org/test-repo/pull/400|PR to review 4>")
      expect(room.messages[3][1]).to.have.string("<https://github.com/test-org/test-repo/pull/500|PR to review 5>")

    it "returns pull requests projects", ->
      expect(room.messages[1][1]).to.have.string("real-test-repo")
      expect(room.messages[2][1]).to.have.string("real-test-repo")
      expect(room.messages[3][1]).to.have.string("real-test-repo")

    it "returns review statuses", ->
      expect(room.messages[1][1]).to.have.string("PENDING")
      expect(room.messages[2][1]).to.have.string("DISMISSED")
      expect(room.messages[3][1]).to.have.string("PENDING")

  context "command set user:<user>", ->
    beforeEach ->
      room.user.say("bob", "@hubot set user:test-user")

    it "replies to the command", ->
      expect(room.messages[1][1]).to.have.string("You are test-user on GitHub")

    it "sets the user", ->
      console.log(room.robot.brain)
      # expect(room.robot.brain.data.users[0].githubLogin).to.eql("test-user")
