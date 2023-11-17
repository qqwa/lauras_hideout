#!/bin/bash

MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.gen.release
MIX_ENV=prod mix release

# run with
# PHX_SERVER=true PHX_HOST=www.lauras-hideout.com ./_build/prod/rel/lauras_hideout/bin/lauras_hideout start