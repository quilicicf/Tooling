#!/usr/bin/env node

const { homedir } = require('os');
const { resolve } = require('path')
const { readFileSync } = require('fs');

const MAX_ICONS_TO_DISPLAY = 25;

const main = () => {
  const [ iconsPath, searchTerm ] = process.argv.splice(2);
  const iconsContent = readFileSync(iconsPath, 'utf8');
  const icons = JSON.parse(iconsContent);

  const matchingIcons = Object.keys(icons)
    .map(key => ({
      name: key,
      icon: icons[ key ],
    }))
    .filter(({ icon, name }) => (
      icon.search.terms.some(term => term.includes(searchTerm))
        || name.includes(searchTerm)
    ));

  process.stdout.write(`Found ${matchingIcons.length} icons:\n`);
  if (matchingIcons.length > MAX_ICONS_TO_DISPLAY) {
    process.stdout.write('More than 10 icons matched, please narrow down your search\n');
    process.exit(1);
  }

  matchingIcons.forEach(({ icon, name }) => {
    const character = String.fromCharCode(parseInt(icon.unicode, 16));
    process.stdout.write(` ${character}\t${name}\n`);
  });
};

main();
