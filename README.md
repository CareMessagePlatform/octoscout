# octoscout

octoscout is a slack chat bot that sends pull requests and review information upon request.
It is built on the [Hubot][hubot] framework using the [hubot-slack][hubot-slack] adapter.

### Available commands

    prs user:<github-login>

Query given user open Pull Requests and sends a message with each pull request summary, containing check and review status

  prs team:<github-slug>

Query given team's open Pull Requests and sends a message with each pull request summary, containing check and review status

    reviews user:<github-login>

Query given user pending Pull Request reviews.

### Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CareMessagePlatform/octoscout)

### Configuration

Some enviroment variables are required for octoscout to run properly

    GITHUB_ORGANIZATION: The name of the organization to query for pending reviews
    GITHUB_API_TOKEN: The Github API token used to query Github API
    HUBOT_SLACK_TOKEN: The Slack bot token

You can create a github API token at [Github settings page][github-token]

Instructions to create a Slack token can be found at [hubot-slack page][hubot-slack] under Requirements and Installation

[hubot]: http://hubot.github.com
[hubot-slack]: https://slackapi.github.io/hubot-slack/
[github-token]: https://github.com/settings/tokens
