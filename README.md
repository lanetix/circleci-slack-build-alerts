# CircleCI-Slack Build Alerts

This application notifies a specific Slack channel when a specific Git branch fails to test on CircleCI.

![](http://i.imgur.com/TVVFOhS.gif)

![](http://i.imgur.com/c4YZSV5.png)

**But can't you do this with a Slack integration already?** Currently, the CircleCI integration will show fixed/failed messages for _all_ branches, which is much too verbose for a large team. Also, we want to make sure that a broken-master alert gets everyone's attention.

## Getting started

1. Follow the [Heroku Getting Started guide](https://devcenter.heroku.com/articles/quickstart) if you haven't already.
1. Clone this repo and `cd` to it.
1. Run `npm install` and then `npm install -g nodemon coffee-script`
1. Create a `.env` file that looks like the sample below.
1. Run `npm run dev`

### Sample `.env` file
Slackbot can have multiple notifications set up.

Each notification requires 4 var settings:
  1. REPO_#
  2. GIT_BRANCH_#
  3. SLACK_CHANNEL_#
  4. SLACK_WEBHOOK_URL_#
```
    REPO_1=ui
    GIT_BRANCH_1=master
    SLACK_CHANNEL_1=#eng
    SLACK_WEBHOOK_URL_1=https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    REPO_2=records
    GIT_BRANCH_2=master
    SLACK_CHANNEL_2=#squad-records
    SLACK_WEBHOOK_URL_2=https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```
Then, you need to send an env var for the number of alerts:
```
    NUM_OF_ALERTS=2
```

### Deploying to Heroku

1. If creating a new app, run `heroku create` and then set each config var using `heroku config` (read docs [here](https://devcenter.heroku.com/articles/config-vars)]
1. Use `heroku config:set` to set environment variables on the Heroku app.
1. Make sure the app runs locally with Foreman: `foreman start web`
1. To deploy, run `git push heroku`

### Setting up Circle

Set up a notify webhook to the Heroku URL as described [here](https://circleci.com/docs/configuration#notify).

--------------------------------------------------------------------
Copyright 2015 Artillery Games, Inc. Licensed under the MIT license.
