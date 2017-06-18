#! /usr/bin/env python
# -*- coding: utf-8 -*-
# Checks wheter the given organization's members have sufficiently long SSH keys.
# Github recommends a length of 4096 bytes although experts seem divided about 2048 keys being sufficient.
# I've set the limit at 4096, it's up to you to change it via the
# Example: python ./checkOrganizationsSshKeys.py -o myorg -f /home/toto/creds/github -l 2048

import argparse
import requests
import json
import yaml
import os
from subprocess import check_output
import shutil

# Configuration variables
def main():
    parser = argparse.ArgumentParser(description='Switches packaged issues to testing.')
    parser.add_argument("-o", dest='organization', type=str, help='Organization you want to know the members of.')
    parser.add_argument("-f", dest='credentialsFile', type=str, help='Path to a yaml file with github login and password (generate an Oauth token! https://github.com/settings/tokens).')
    parser.add_argument("-l", dest='minLength', default=4096, type=str, help='The minimum SSH key length in your organization (defaults to 4096).')

    args = parser.parse_args()
    organization = args.organization
    credentialsFile = args.credentialsFile
    minLength = args.minLength

    stream = open(credentialsFile, "r")
    credentials = yaml.load(stream)
    login = credentials['login']
    password = credentials['password']

    members = requests.get("https://api.github.com/orgs/{0}/members".format(organization), auth=(login, password)).json()

    directory = "/tmp/{0}".format(organization)
    if os.path.exists(directory):
        shutil.rmtree(directory)
        os.makedirs(directory)

    for member in members:
        memberId = member['login']
        keysAsString = requests.get("https://github.com/{0}.keys".format(memberId), auth=(login, password)).text

        keys = keysAsString.splitlines()
        for index, key in enumerate(keys):
            filePath = "{0}/{1}.{2}".format(directory, memberId, index)
            file = open(filePath, 'w')
            file.write(key)
            file.close()
            output = check_output(["ssh-keygen", "-lf", filePath])
            length = int(output.split(' ')[0])

            if length < minLength:
                print "User {0} has an invalid key of length {1}".format(memberId, length)

if __name__ == "__main__":
    main()
