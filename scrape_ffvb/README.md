# Import FFVB calendar

## Aim

Create an ICS file to import all the matches of the season in any e-calendar by importing the CSV file from ffvbbeach.org website.

## Pre-requisites

* [NodeJS](https://nodejs.org/en/download/)

## Create ICS file

* Go on http://www.ffvbbeach.org and find your championship's schedule (full schedule of course)
* Save the calendar as Excel file (produces a CSV file)
* Update the encoding with `iconv -f ISO-8859-1 -t UTF-8 input.csv -o output.csv`
* Clone [js2ics](https://github.com/quilicicf/js2ics) in the same folder as `Tooling`
* Install both js2ics and this package (`npm install`)
* Run the script with the command below:

```shell
node ./icsify.js
```

The script will guide your through the process of selecting the fields that contain the relevant information.

## Import it

Open your e-calendar and search for the `Import ics file` option.
