#---------#
# Firefox #
#---------#

firefoxUpdate() (
  archiveName='FirefoxSetup.tar.bz2'
  installationPath='/opt/firefox-dev-edition'
  
  cd /tmp
  wget \
    --output-document "${archiveName}" \
    'https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US'
  sudo tar --extract --verbose --file "${archiveName}"
  sudo rm -rf "${installationPath}"
  sudo mv 'firefox' "${installationPath}"
  rm "/tmp/${archiveName}"
)
