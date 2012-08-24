options = {
    port: process.env.port || 39950,
    host: '0.0.0.0',
    secret: process.env.secret,
    auth: process.env.auth
    esettings:{
        views: __dirname + '/Views',
        'view engine': 'jade',
        'case sensitive routes': true
        'view options': {layout:false}
    }
}

options.callback_url = process.env.callback_url

module.exports.config = options
