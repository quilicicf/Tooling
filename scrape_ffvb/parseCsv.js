const csv = require('csv-parser');
const { createReadStream } = require('fs');

module.exports = async (filePath) => {
  const accumulator = {
    headers: [],
    lines: [],
  };
  return new Promise((resolve, reject) => {
    createReadStream(filePath)
      .pipe(csv({ separator: ';' }))
      .on('headers', headers => accumulator.headers = headers)
      .on('data', line => accumulator.lines.push(line))
      .on('end', () => resolve(accumulator))
      .on('error', error => reject(error))
  });
};
