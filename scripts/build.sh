#!/usr/bin/env bash

# Stop if any process returns non-zero exit code
set -e

echo "Removing existing build..."
rm -rf ./bin && mkdir ./bin
cp -r ./src/lib ./bin/lib
cp -r ./src/oneoff ./bin/oneoff
cp -r ./src/public ./bin/public
cp -r ./src/routes ./bin/routes
cp -r ./src/tests ./bin/tests
cp -r ./src/views ./bin/views
cp -r ./src/integrations ./bin/integrations

cp -r ./node_modules/material-design-icons/sprites/svg-sprite ./bin/public/stylesheets/external

# Compile all coffeescript to js
echo "Compiling Coffeescript to JS..."
cjsx --output ./bin/ --compile ./src/

./node_modules/.bin/browserify -t coffee-reactify --extension=".cjsx" --extension=".coffee" --debug  \
./src/public/javascripts/index.coffee > ./bin/public/javascripts/bundle.js
#./src/public/javascripts/index.coffee | uglifyjs > ./bin/public/javascripts/bundle.js

echo "Linting..."
find ./src -name "*.coffee" -print0 | xargs -0 ./node_modules/.bin/coffeelint -f ./coffeelint.json

# Compile less files
lessc ./bin/public/stylesheets/external/less/main.less > ./bin/public/stylesheets/less_main.css

echo "Build successful!"
