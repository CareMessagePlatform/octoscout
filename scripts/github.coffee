# Description:
#   Gathers data from Github and respond with a summary
#
# Commands:
#   octscout prs user:<login> - Responds with a summary of user open pull requests
#   octscout reviews user:<login> - Responds with a summary of user requested reviews that are pending
#   octscout set user:<login> - Define your github user
#

ghQuery = require("./lib/gh-query.coffee")
ghParser = require("./lib/gh-parser.coffee")
prSummary = require("./lib/pr-summary.coffee")
reviewSummary = require("./lib/review-summary.coffee")

module.exports = (robot) ->

  organization = process.env.GITHUB_ORGANIZATION
  apiKey = process.env.GITHUB_API_TOKEN

  robot.respond /prs user:(.*)/, (res) ->
    login = res.match[1]
    query = ghQuery.userPullRequests(login)
    robot.http("https://api.github.com/graphql")
      .header("Authorization", "bearer #{apiKey}")
      .post(query) (err, result, body) ->
        prs = ghParser.parsePullRequests(body)
        res.send(prSummary.summary(pr)) for pr in prs

  robot.respond /reviews user:(.*)/, (res) ->
    login = res.match[1]
    query = ghQuery.userReviewRequests(login, organization)
    robot.http("https://api.github.com/graphql")
      .header("Authorization", "bearer #{apiKey}")
      .post(query) (err, result, body) ->
        reviews = ghParser.parseReviewRequests(body, login)
        res.send(reviewSummary.summary(review)) for review in reviews

  robot.respond /set user:(.*)/, (res) ->
    githubLogin = res.match[1]
    res.message.user.githubLogin = githubLogin
    res.send "Got it! You are #{githubLogin} on GitHub"
