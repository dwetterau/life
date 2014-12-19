life
=============

Work in Progress: Privately record your life

### Installation Instructions

Clone the repo and run `npm install` in the default directory.

After setting up MySQL on your machine (with the proper credentials in `configs/config.json`),
you need to compile all the Coffeescript to run the script that builds the MySQL tables.

First run `./scripts/build.sh` and then run `node ./bin/oneoff/init_db.js`.

`npm start` then starts the server.
