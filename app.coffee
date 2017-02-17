#!/usr/bin/env coffee
#
# Copyright 2015 Artillery Games, Inc.
# Licensed under the MIT license.
#
# Author: Ian Langworth

http = require 'http'
express = require 'express'
fs = require 'fs'
pathlib = require 'path'
request = require 'request'

# Copy env from ./env
env = pathlib.join __dirname, '.env'
if fs.existsSync env
  lines = fs.readFileSync(env, 'utf8').split '\n'
  for line in lines
    continue unless line
    [key, value] = line.split '='
    unless key and value
      console.warn "Ignoring env line: '#{ line }'"
      continue
    process.env[key] = value
    console.log "Read from #{ env }: #{ key }=#{ value }"

port = process.env.PORT or 8000

requireEnv = (name) ->
  value = process.env[name]
  if not value?
    console.error "Need to specify #{ name } env var"
    process.exit(1)
  return value

app = express()

app.configure ->
  app.set 'port', port
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.send 200, 'OK'

maxVal = requireEnv 'NUM_OF_ALERTS'
for alertNum in [1..maxVal]
  app.post '/', (req, res) ->
    return res.send 400, 'No payload' unless req.body.payload?
    {build_url, branch, status} = req.body.payload

    console.log('//////// NUM_OF_ALERTS', maxVal)

    branchEnvVar = (alertNum) ->
      "GIT_BRANCH_#{alertNum}"
    console.log('////////// branchEnvVar ', branchEnvVar(alertNum))
    if branch != requireEnv branchEnvVar(alertNum)
      console.log('//////// here 1')
      return res.send 200, 'Ignored (wrong git branch)'

    slackChannelEnvVar = (alertNum) ->
      "SLACK_CHANNEL_#{alertNum}"
    console.log('//////////////// slackChannelEnvVar ', slackChannelEnvVar(alertNum))
    payload =
      channel: requireEnv slackChannelEnvVar(alertNum)
      username: 'CircleCI build status'
    if status == 'failed'
      console.log('//////// here 2')
      payload.icon_emoji = ':red_circle:'
      payload.text = "@channel #{ branch } build FAILED for #{ build_url }! <#{ build_url }|See details...>"
      #payload.text = "@channel #{ branch } build FAILED! <#{ build_url }|See details...>\nhttp://i.imgur.com/TVVFOhS.gif"
    else if status == 'fixed'
      console.log('//////// here 3')
      payload.icon_emoji = ':white_check_mark:'
      payload.text = "@channel #{ branch } build fixed for #{ build_url }. <#{ build_url }|See details...>"
      #payload.text = "@channel #{ branch } build failed! <#{ build_url }|See details...>\nhttp://i.imgur.com/TVVFOhS.gif"
    else
      console.log('//////// here 4')
      return res.send 200, 'Ignored (only want fixed/failed status)'

    slackWebhookEnvVar = (alertNum) ->
      "SLACK_WEBHOOK_URL_#{alertNum}"
    console.log('//////////// slackWebhookEnvVar ', slackWebhookEnvVar(alertNum))
    request.post(
      requireEnv(slackWebhookEnvVar(alertNum)),
      { form: { payload: JSON.stringify payload } },
      (err, _, body) ->
        if err
          console.error "Slack returned an error: #{ err }"
        else
          console.log "Slack responded: #{ body }"
    )
    console.log('////////// here')
    res.send 200, "OK, sent #{ JSON.stringify payload }"

http.createServer(app).listen port, ->
  console.log "Server listening on http://localhost:#{ port }"
