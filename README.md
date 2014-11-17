base-node-app
=============

A simple website starting point using the Sequelize ORM for MySQL written in Coffeescript and using Bootstrap for styling.

### Description

This site has a simple Bootstrap themed UI to allow users to log in, an update their profile. The point of this
project is to provide a launching pad for an application without the need to rewrite user management code over and
over again.

### Installation Instructions

Clone the repo and run `npm install` in the default directory.

After setting up MySQL on your machine (with the proper credentials in `configs/config.json`),
you need to compile all the Coffeescript to run the script that builds the MySQL tables.

First run `./scripts/build.sh` and then run `node ./bin/oneoff/init_db.js` until it says the initialization has finished.

`npm start` then starts the server.
