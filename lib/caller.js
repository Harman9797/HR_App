var request = require("request")

module.exports = async function getBody(url, method) {
    const options = {
      url, method
    };
  
    // Return new promise
    return new Promise(function(resolve, reject) {
      // Do async job
      request.get(options, function(err, resp, body) {
        if (err) {
          reject(err);
        } else {
          resolve(body);
        }
      })
    })
  }