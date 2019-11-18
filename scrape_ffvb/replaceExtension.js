const { extname } = require('path');

module.exports = (filePath, newExtension) => {
  if (typeof filePath !== 'string') { return filePath; }

  if (filePath.length === 0) { return filePath; }

  const oldExtension = extname(filePath);
  return filePath.replace(new RegExp(`${oldExtension}$`), newExtension);
};
