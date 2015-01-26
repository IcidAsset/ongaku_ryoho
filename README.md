# Ongaku Ryoho
A music player / library (without the storage option)

## So where's my music supposed to come from?
+ Ongaku Ryoho Servers ([gem](https://github.com/icidasset/ongaku_ryoho_server))
+ Amazon S3
+ Dropbox

## Specs
+ Postgresql
+ Redis
+ Sidekiq
+ ffprobe
+ Rails 3.2.*
+ Backbone.js / Zepto.js
+ Web Audio API

## How?
Boot it up like so:

    cd wherever_you_cloned_this_project_to
    foreman start
    open http://localhost:5000
