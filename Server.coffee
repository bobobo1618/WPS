# PubSubHubbub test server.

# 02/02/2012 - Lucas Cooper

fs = require 'fs'
express = require 'express'
coffee = require 'coffee-script'
http = require 'http'
https = require 'https'
querystring = require 'querystring'
nowjs = require 'now'
xml2js = require 'xml2js'
crypto = require 'crypto'
config = require('./Config').config

# Used to parse the XML from Atom items.
parser = new xml2js.Parser

app = express.createServer()

# A function to extend two hased lists.
extend = (a1, a2)->
    out = a2
    out[key] = value for key, value of a1
    return out

# Configures Express.
app.configure ()->
    app.use '/static', express.static __dirname + '/Static'
    app.use express.logger()
    app.use express.bodyParser {uploadDir: './Uploads', keepExtensions: true}
    app.set setting, value for setting, value of config.esettings

# App will use Now.js to communicate real-time data to clients.
everyone = nowjs.initialize(app)

# Renders index page.
app.get '/', (req, res)->
    res.render 'index'

# Subscribe function. Presents the subscribe page to clients.
app.get '/subscribe', (req, res)->
    res.render 'subscribe'

# Subscribe POST function. Handles subscription requests sent by clients.
app.post '/subscribe', (req, res)->
    if req.body['hub.mode'] and req.body['hub.topic']
        postdata = querystring.stringify {
            'hub.mode': req.body['hub.mode'],
            'hub.topic': req.body['hub.topic'],
            'hub.verify': 'async',
            'hub.callback': config.callback_url,
            #'secret': config.secret,
            'auth': config.auth
        }

        croptions = {
            host: 'superfeedr.com',
            port: 80,
            path: '/hubbub',
            method: 'POST',
            headers: {
                'Accept:': 'application/json',
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': postdata.length
            }
        }

        creq = http.request croptions, (cres)->
            console.log 'CRES CODE: '+cres.statusCode
            console.log 'CRES HEADERS: '
            console.dir cres.headers
            cres.setEncoding 'utf8'
            cres.on 'data', (chunk)->
                console.log 'Response: '+chunk

        creq.on 'error', (e)->
            console.log 'Problem with request: '+e.message
        creq.write postdata
        creq.end
        res.render 'subscribed'

# Subscriptions page where items are displayed.
app.get '/subscriptions', (req, res)->
    res.render 'subscriptions'

# Tries to conform to the PubSubHubbub standard. Accepts all subscriptions.
app.get '/sub', (req, res)->
    if req.query['hub.challenge']
        body = req.query['hub.challenge']
        res.writeHead 200, {'Content-Length':body.length, 'Content-Type':'text/plain'}
        res.end body
    else
        console.log 'Bad subscribe request.'

# Handles new PubSubHubbub data.
app.post '/sub', (req, res)->
    #console.dir req
    res.writeHead 200
    console.dir req.body
    res.end 'Success'
    #vh = crypto.createHmac 'sha1', config.secret
    #vh.update req.body
    #digest = vh.digest 'hex'
    everyone.now.newData req.body

# Utility function to test bodyparser.
app.post '/posttest', (req, res)->
    console.log req.body
    console.log req.files
    res.end

app.listen config.port, config.host

console.log 'Listening on ' + config.host + ':' + config.port.toString()
