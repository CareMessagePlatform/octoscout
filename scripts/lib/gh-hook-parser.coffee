crypto = require("crypto")

GITHUB_WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET

ghHookParser =
  parseHookRequest: (request) ->
    eventType = request.headers["x-github-event"]
    this[eventType]?(request.body) if this.hasValidSignature(request)

  hasValidSignature: (request) ->
    github_signature = request.headers["x-hub-signature"]
    payload = JSON.stringify(request.body)
    sig = "sha1=" + crypto.createHmac("sha1", GITHUB_WEBHOOK_SECRET).update(payload).digest("hex")
    if github_signature is sig
      true
    else
      throw "Invalid signature: #{github_signature} / #{sig}"

  status: (data) ->
    {
      eventType: "status"
      user: data["commit"]["author"]["login"]
      data: {
        description: data["description"]
        commit: {
          message: data["commit"]["commit"]["message"]
          url: data["commit"]["html_url"]
        }
        context: data["context"]
        state: data["state"]
        target_url: data["target_url"]
      }
    }

module.exports = ghHookParser
