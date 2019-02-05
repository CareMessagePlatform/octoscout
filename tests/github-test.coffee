Helper = require("hubot-test-helper")
chai = require("chai")
crypto = require("crypto")
http = require("http")
nock = require("nock")
request = require("request")

expect = chai.expect

helper = new Helper("../scripts/github.coffee")

process.env.EXPRESS_PORT = 8080
process.env.GITHUB_WEBHOOK_SECRET = "SECRET"

describe "github script", ->

  room = null

  beforeEach ->
    room = helper.createRoom({ name: 'bob' })
    do nock.disableNetConnect

  afterEach ->
    room.destroy()
    nock.cleanAll()

  context "command prs user:<user>", ->
    prResponse = require("./fixtures/pr-user-response.json")

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

  context "command prs team:<team>", ->
    prResponse = require("./fixtures/pr-team-response.json")

    beforeEach (done) ->
      nock("https://api.github.com/graphql")
        .post("")
        .reply 200, prResponse
        room.user.say("bob", "@hubot prs team:test-team")
        setTimeout(done, 100)

    it "returns pull requests titles and urls", ->
      expect(room.messages[1][1]).to.have.string("<https://github.com/test-org/test-repo/pull/100|My PR 1>")
      expect(room.messages[2][1]).to.have.string("<https://github.com/test-org/test-repo/pull/200|My PR 2>")
      expect(room.messages[3][1]).to.have.string("<https://github.com/test-org/test-repo/pull/300|My PR 3>")

    it "returns pull requests projects", ->
      expect(room.messages[1][1]).to.have.string("real-test-repo")
      expect(room.messages[2][1]).to.have.string("real-test-repo")
      expect(room.messages[3][1]).to.have.string("real-test-repo")

    it "returns pull requests checks states", ->
      expect(room.messages[1][1]).to.have.string("Checks state is SUCCESS")
      expect(room.messages[2][1]).to.have.string("Checks state is FAILURE")
      expect(room.messages[3][1]).to.have.string("Checks state is FAILURE")

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
      room.user.say("bob", "@hubot set user:bobGithub")

    it "sets value on brain so we can find slack user from github user", ->
      expect(room.robot.brain.get("github-users-bobGithub")).to.equal("bob")

  context "post /hook/gh", ->
    doRequest = (eventType, secret, jsonModifier, cb) ->
      bodyJson = require("./fixtures/gh-webhooks/#{eventType}.json")
      bodyJson = jsonModifier?(bodyJson) || bodyJson
      signature = "sha1=" + crypto.createHmac("sha1", secret).update(JSON.stringify(bodyJson)).digest("hex")
      request({
        method: "POST",
        uri: "http://localhost:8080/hubot/gh",
        headers: {
          "x-github-event": eventType
          "x-hub-signature": signature
        }
        body: bodyJson
        json: true
      }, (_error, response) => cb(response))

    beforeEach ->
      nock.enableNetConnect("localhost")

    context "status update", ->
      doStatusRequest = (status, cb) ->
        doRequest(
          "status",
          "SECRET",
          (json) => json["state"] = status; json
          (response) => cb(response)
        )

      beforeEach ->
        room.user.say("bob", "@hubot set user:username")

      for status in ["failure", "error"]
        do (status) ->
          context "when status is #{status}", ->
            beforeEach (done) ->
              doStatusRequest(status, (@response) => done())

            it "sends status update message", ->
              lastMessage = room.messages[-1..][0]
              expect(lastMessage[1]).have.string("Status update for commit")
              expect(lastMessage[1]).have.string(status.toUpperCase())

      for status in ["pending", "success"]
        do (status) ->
          context "when status is #{status}", ->
            beforeEach (done) ->
              doStatusRequest(status, (@response) => done())

            it "does not send status update message", ->
              # There's already 2 messages in room when setting the user
              expect(room.messages.length).to.equal(2)

    context "invalid github signature", ->
      beforeEach (done) ->
        room.user.say("bob", "@hubot set user:username")
        doRequest(
          "status",
          "WRONG_SECRET",
          null
          (@response) => done()
        )

      it "does not send message", ->
        # There's already 2 messages in room when setting the user
        expect(room.messages.length).to.equal(2)

      it "responds with error", ->
        expect(@response.statusCode).to.equal(500)


