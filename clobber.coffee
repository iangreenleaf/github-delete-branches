request = require "request"

REPO = "iangreenleaf/github-delete-branches"
BASE_URL = "https://api.github.com/repos/#{REPO}"

headers =
  "Content-Type": "application/json"
  "Authorization": "token #{process.env.GITHUB_TOKEN}"

request
  method: "post"
  url: "#{BASE_URL}/git/refs"
  body: JSON.stringify { ref: "refs/heads/foo", sha: "ba653d879041afcd4789fcecf2785d0cccddf4c3" }
  headers: headers
  (err, res) ->
    console.log "Created a branch: #{res.statusCode}"
    request.get "#{BASE_URL}/branches", (err, res) ->
      console.log "We now have #{JSON.parse(res.body).length} branches"
      request.del url: "#{BASE_URL}/git/refs/heads/foo", headers: headers, (err, res) ->
        console.log "Deleted a branch: #{res.statusCode}"
        request.get "#{BASE_URL}/branches", (err, res) ->
          console.log "We now have #{JSON.parse(res.body).length} branches"
