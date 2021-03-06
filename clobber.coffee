request = require "request"
async = require "async"

REPO = "iangreenleaf/github-delete-branches"
BASE_URL = "https://api.github.com/repos/#{REPO}"

headers =
  "Content-Type": "application/json"
  "Authorization": "token #{process.env.GITHUB_TOKEN}"

displayStatus = (obj) ->
  ("#{k} (#{v})" for k,v of obj).join " "

countBranches = (done) ->
  request.get "#{BASE_URL}/branches", (err, res) ->
    console.log "We have #{JSON.parse(res.body).length} branches"
    done(err)

creates = []
deletes = []
create_res = {}
delete_res = {}
for i in [1..50]
  do (i) ->
    creates.push (done) ->
      request
        method: "post"
        url: "#{BASE_URL}/git/refs"
        body: JSON.stringify { ref: "refs/heads/foo_#{i}", sha: "ba653d879041afcd4789fcecf2785d0cccddf4c3" }
        headers: headers
        (err, res) ->
          create_res[res.statusCode] ||= 0
          create_res[res.statusCode]++
          done()
    deletes.push (done) ->
      request.del url: "#{BASE_URL}/git/refs/heads/foo_#{i}", headers: headers, (err, res) ->
        delete_res[res.statusCode] ||= 0
        delete_res[res.statusCode]++
        done()

async.series [
  countBranches
  (done) ->
    async.parallel creates, (err) ->
      console.log "Created branches: #{displayStatus create_res}"
      done(err)
  countBranches
  (done) ->
    async.parallel deletes, (err) ->
      console.log "Deleted branches: #{displayStatus delete_res}"
      done(err)
  countBranches
]
