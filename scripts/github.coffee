# Description:
#   Gathers data from Github and respond with a summary
#
# Commands:
#   octscout prs user:<login> - Responds with a summary of user open pull requests
#   octscout prs team:<slug> - Responds with a summary of team open pull requests
#   octscout reviews user:<login> - Responds with a summary of user requested reviews that are pending
#

ghQuery = require("./lib/gh-query.coffee")
ghParser = require("./lib/gh-parser.coffee")
prSummary = require("./lib/pr-summary.coffee")
reviewSummary = require("./lib/review-summary.coffee")

BRAIN_GITHUB_USERS_KEY = "github-users"

module.exports = (robot) ->

  organization = process.env.GITHUB_ORGANIZATION
  apiKey = process.env.GITHUB_API_TOKEN

  getGithubUser = (github_login) ->
    robot.brain.get("#{BRAIN_GITHUB_USERS_KEY}-#{github_login}")

  setGithubUser = (github_login, slack_user) ->
    robot.brain.set("#{BRAIN_GITHUB_USERS_KEY}-#{github_login}", slack_user)

  robot.respond /prs user:(.*)/, (res) ->
    login = res.match[1]
    query = ghQuery.userPullRequests(login)
    robot.http("https://api.github.com/graphql")
      .header("Authorization", "bearer #{apiKey}")
      .post(query) (err, result, body) ->
        prs = ghParser.parseUserPullRequests(body)
        res.send(prSummary.summary(pr)) for pr in prs

  robot.respond /prs team:(.*)/, (res) ->
    slug = res.match[1]
    query = ghQuery.teamPullRequests(organization, slug)
    robot.http("https://api.github.com/graphql")
      .header("Authorization", "bearer #{apiKey}")
      .post(query) (err, result, body) ->
        prs = ghParser.parseTeamPullRequests(body)
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
    login = res.match[1]
    setGithubUser(login, res.message.user.name)
    res.send "Got it! You are #{login} on GitHub."
