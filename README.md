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

    set user:<github-login>

Links the slack user to his github login. This should be set if the user wants to receive octoscout notifications

### Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CareMessagePlatform/octoscout)

Redis is needed for set user command and webhooks to work properly.

### Configuration

Some enviroment variables are required for octoscout to run properly

    GITHUB_ORGANIZATION: The name of the organization to query for pending reviews
    GITHUB_API_TOKEN: The Github API token used to query Github API
    HUBOT_SLACK_TOKEN: The Slack bot token
    GITHUB_WEBHOOK_SECRET: The github webhooks secret

You can create a github API token at [Github settings page][github-token]. The token permissions should include the full `repo` scope and the `read:org` permission to the `admin:org` scope.

Instructions to create a Slack token can be found at [hubot-slack page][hubot-slack] under Requirements and Installation

[hubot]: http://hubot.github.com
[hubot-slack]: https://slackapi.github.io/hubot-slack/
[github-token]: https://github.com/settings/tokens

### Webhooks

Octoscout relies on Github webhooks to send real time notifications on slack. Webhooks should be configured in each
reposity that is going to trigger notifications through octoscout. These are the steps to configure those:

- On the Github repo, go to Settings -> Webhooks
- Click the Add webhook button
- The payload URL should be your octoscout app address with the suffix /hubot/gh
- Content type should be application/json
- Secret should be the same as your server env GITHUB_WEBHOOK_SECRET value
- If you want to select individual events, until now we only support `Status`

That's it. After that you should start receiving notifications from octoscout
