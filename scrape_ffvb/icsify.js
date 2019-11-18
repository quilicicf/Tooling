#!/usr/bin/env node

/*
* This is a bit of code I use to scrape the French volleyball's federation website to get the calendar of my matches.
* It then uses an nodeJS package I've written to create an iCal calendar with all the matches of the year in it.
* This is a WIP, the package is not published to NPM yet but already available at https://github.com/quilicicf/js2ics
* The scraping is done via http://webscraper.io/. If you are a french volleyball player you can import sitemap.json
* into web scraper and change it to match your division.
*
* $1: Team name
* $2: Input file path
* $3: Output file path
*/

const _ = require('lodash');
const { existsSync } = require('fs');
const moment = require('moment');
const { tz } = require('moment-timezone');
const { prompt, registerPrompt } = require('inquirer');
registerPrompt('autocomplete', require('inquirer-autocomplete-prompt'));

const parseCsv = require('./parseCsv');
const writeFile = require('./writeFile');
const replaceExtension = require('./replaceExtension');

const { getCalendar } = require('../../js2ics/index.js');

const INPUT_DATE_FORMAT = 'YYYY-MM-DD'; // TODO: guess or prompt
const INPUT_TIME_FORMAT = 'HH:mm'; // TODO: guess or prompt

const GUESSED_TIME_ZONE = tz.guess();
const TIME_ZONES = [
  { name: `${GUESSED_TIME_ZONE} (guessed)`, value: GUESSED_TIME_ZONE },
  ..._.map(tz.names(), name => ({ name, value: name }))
];

const ANSWERS = {
  CSV_PATH: 'csvPath',
  JSON_CONTENT: 'jsonContent',
  YOUR_TEAM: 'yourTeam',
  TIME_ZONE: 'timeZone',

  FIELD_TEAM_A: 'fieldTeamA',
  FIELD_TEAM_B: 'fieldTeamB',
  FIELD_DATE: 'fieldDate',
  FIELD_TIME: 'fieldTime',

  SHOULD_ADD_LOCATION: 'shouldAddLocation',
  FIELD_LOCATION: 'fieldLocation',
};

const FIELD_ANSWER_FIELDS = _(ANSWERS)
  .values()
  .filter(value => /^field[A-Z]/.test(value))
  .value();

const reformatEntry = (answers, entry) => {
  const {
    [ ANSWERS.YOUR_TEAM ]: teamName,
    [ ANSWERS.FIELD_TEAM_A ]: fieldTeamA,
    [ ANSWERS.FIELD_TEAM_B ]: fieldTeamB,
    [ ANSWERS.FIELD_DATE ]: fieldDate,
    [ ANSWERS.FIELD_TIME ]: fieldTime,
    [ ANSWERS.SHOULD_ADD_LOCATION ]: hasLocation,
    [ ANSWERS.FIELD_LOCATION ]: fieldLocation,
  } = answers;

  const enemyTeam = entry[ fieldTeamA ] === teamName ? entry[ fieldTeamB ] : entry[ fieldTeamA ];
  const date = moment(entry[ fieldDate ], INPUT_DATE_FORMAT);
  const time = moment(entry[ fieldTime ], INPUT_TIME_FORMAT);
  const startTime = moment(date)
    .hours(time.get('hour'))
    .minutes(time.get('minute'));
  const endTime = moment(startTime).add(3, 'hours');

  return {
    eventName: `Match contre ${enemyTeam}`,
    dtstart: startTime.format(),
    dtend: endTime.format(),
    location: hasLocation ? entry[ fieldLocation ] : '',
  };
};

const icsify = async (answers) => {
  const {
    [ ANSWERS.YOUR_TEAM ]: teamName,
    [ ANSWERS.TIME_ZONE ]: timeZone,
    [ ANSWERS.FIELD_TEAM_A ]: fieldTeamA,
    [ ANSWERS.FIELD_TEAM_B ]: fieldTeamB,
    [ ANSWERS.CSV_PATH ]: inputFilePath,
  } = answers;

  const events = _(answers[ ANSWERS.JSON_CONTENT ].lines)
    .filter(entry => [ entry[ fieldTeamA ], entry[ fieldTeamB ] ].includes(teamName))
    .map(entry => reformatEntry(answers, entry))
    .value();

  const calendar = getCalendar({ events, timeZone });
  const outputFilePath = replaceExtension(inputFilePath, '.ics');
  await writeFile(outputFilePath, calendar);
};

const findInHeaders = async (answers, search = '') => Promise.resolve(
  _(answers[ ANSWERS.JSON_CONTENT ].headers)
    .filter(header => { // Filter out fields that were already selected
        const hasAlreadyBeenAnswered = _(FIELD_ANSWER_FIELDS)
          .map(fieldAnswerField => answers[ fieldAnswerField ])
          .filter(answerForField => !!answerForField)
          .includes(header);
        return !hasAlreadyBeenAnswered;
      }
    )
    .filter(header => !_.isEmpty(header))
    .filter(header => header.toLocaleLowerCase().includes(search.toLocaleLowerCase()))
    .value(),
);

const questions = [
  {
    type: 'input',
    name: ANSWERS.CSV_PATH,
    message: 'Where is your CSV file?',
    async validate (userInput, answers) {
      if (!existsSync(userInput)) {
        return `Path ${userInput} does not exist`;
      }

      try {
        const jsonContent = await parseCsv(userInput);
        _.set(answers, ANSWERS.JSON_CONTENT, jsonContent);
        return true;
      } catch (error) {
        return `Can't read the file ${userInput}, is it valid CSV?`;
      }
    }
  },
  {
    type: 'autocomplete',
    name: ANSWERS.FIELD_TEAM_A,
    message: 'What is the field name for team A?',
    source: findInHeaders,
    pageSize: 10,
  },
  {
    type: 'autocomplete',
    name: ANSWERS.FIELD_TEAM_B,
    message: 'What is the field name for team B?',
    source: findInHeaders,
    pageSize: 10,
  },
  {
    type: 'autocomplete',
    name: ANSWERS.FIELD_DATE,
    message: 'What is the field name for the date?',
    source: findInHeaders,
    pageSize: 10,
  },
  {
    type: 'autocomplete',
    name: ANSWERS.FIELD_TIME,
    message: 'What is the field name for the time?',
    source: findInHeaders,
    pageSize: 10,
  },
  {
    type: 'confirm',
    name: ANSWERS.SHOULD_ADD_LOCATION,
    message: 'Are the locations where the matches happen in your file?',
    default: false,
  },
  {
    type: 'autocomplete',
    name: ANSWERS.FIELD_LOCATION,
    message: 'What is the field name for the location?',
    source: findInHeaders,
    pageSize: 10,
  },
  {
    type: 'autocomplete',
    name: ANSWERS.YOUR_TEAM,
    message: 'What is your team?',
    async source (answers, search = '') {
      return Promise.resolve(
        _(answers[ ANSWERS.JSON_CONTENT ].lines)
          .map(line => line[ answers[ ANSWERS.FIELD_TEAM_A ] ])
          .uniq()
          .filter(teamName => teamName.toLocaleLowerCase().includes(search.toLocaleLowerCase()))
          .value(),
      );

    },
    pageSize: 10,
  },
  {
    type: 'autocomplete',
    name: ANSWERS.TIME_ZONE,
    message: 'What is your time-zone?',
    async source (answers, search = '') {
      return Promise.resolve(
        _(TIME_ZONES)
          .filter(tz => tz.name.toLocaleLowerCase().includes(search.toLocaleLowerCase()))
          .value(),
      );

    },
    pageSize: 10,
  },
];

const main = async () => {
  try {
    const answers = await prompt(questions);
    await icsify(answers);
  } catch (error) {
    throw error;
  }
};

main();
