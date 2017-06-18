# Tooling
My everyday automation

## What is it ?

A set of bash scripts I use in my day-to-day life. They are separated in modules in different folder/files but a script creates a single bashrc file at the end. 
I chose to generate the file by hand because I can [shellcheck](https://www.shellcheck.net/) it before and therefore avoid breaking my terminal when I do something wrong.

:warning: It is developped on linux mint 18.1 with no attention given to compatibility on other systems. Parts of this might not work on your system!

## How to make it work ?

### Machine-specific settings

All the machine-specific things you might need are available in `0_Machine_Specific.example`. 
Just copy that file and change its extension to `.sh` then update all the fields to match your machine's configuration.

### Build

All the `*.sh` can be compiled into one file in `~/.bashrc` by the java parser in `bashrcUtils`. 

> Why writing a parser in Java ? I was young and foolish, and only knew Java at the time. I don't see any reason to re-write it know, it's been working for ages and I simply don't have the time.

To do that the first time, run:

```shell
mvn clean assembly:assembly "-Drevision=$current_version"
java -jar "$BASHRC_UTILS/target/bashrcUtils-$current_version-jar-with-dependencies.jar" -p "$BASHRC" build rtfm "$@"
``` 

Where:
- current_revision can be found in `$BASHRC_UTILS/version.txt`
- BASHRC_UTILS is the absolute path to `./bashrcUtils`
- BASHRC_UTILS is the absolute path to `./bashrc`

The next time, just call `brcBuild`.

## Prompt

I created my own bash prompt, based on `bash-git-prompt`. It looks like that:

![prompt](https://github.com/quilicicf/Tooling/raw/master/bash-prompt/wow.png)

If that looks good to you, you can use it: 

- Clone [my fork of bash-git-prompt](https://github.com/quilicicf/bash-git-prompt) in `$FORGE`
- Switch to branch `master_adjusted` which disables color changes in the prompt, applies a custom theme of mine and puts the git prompt in `$PS12` rather than directly in `$PS1`
- If you want to customize it, modify the file `./bash-prompt/ps1_config` which contains one line for each fragment of the prompt (fontSize, fontColor, backgroundColor, content, displayCondition)
- Launch `promptBuild` which will build the `$PS1`'s value in `~/.config/bash-prompt`
- Open a new terminal to see the result
- Enjoy
