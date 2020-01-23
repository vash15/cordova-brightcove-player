var exec = require('cordova/exec');

exports.init = function(policyKey, accountId, success, error) {
    exec(success, error, 'BrightcovePlayer', 'initAccount', [policyKey, accountId])
};

exports.play = function(videoId, success, error) {
    exec(success, error, 'BrightcovePlayer', 'play', [videoId]);
};

exports.getPoster = function(videoId, success, error) {
    exec(success, error, 'BrightcovePlayer', 'getPoster', [videoId]);
};
