# Tooling
My everyday automation

## What is it ?

It started as a challenge to become self-taught in bash as it's IMO a talent a software engineer MUST have in his toolbox. It's now become a important part of my comfy dev setup and the bash part is not a requirement anymore
so new languages are going to appear in this project!

This project is a set of bash scripts I use in my day-to-day life. They are separated in modules in different folder/files but a script creates a single bashrc file at the end. 
I chose to generate the file by hand because I can [shellcheck](https://www.shellcheck.net/) it before and therefore avoid breaking my terminal when I do something wrong.

:warning: It is developped on linux mint 18.1 with no attention given to compatibility on other systems. Parts of this might not work on your system! :warning:

## How to make it work ?

### Machine-specific settings

The machine-specific things you might need are available in `0_Machine_Specific.example`. 
Just copy that file and change its extension to `.sh` then update all the fields to match your machine's configuration.

You might also want to go have a look at `4_Path.sh` which I haven't git-ignored/templated yet.

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

## Private methods and repositories

As lots of scripts can contain information about a dev's company that should not get public, there's a way to put all your private files in a private repository and still include them in the final file.

To do that, export a variable `PRIVATE_TOOLING` in the file `0_Machine_Specific.sh` set to the path of your private repository. Put all the files that should be added to your bashrc in a folder `bashrc` in that repository and launch `brcbuild` again. 

To add private repositories to the list of your public ones, add them by copying the structure of the file in `bashrc/Git/repos.json` into your private repository: `$PRIVATE_TOOLING/bashrc/Git/repos.json`. 

## Roadmap

- A lot of my git flow is implemented already but I find myself limited by bash. I intend to build something much better in a more powerful language.
- The previous item should keep me busy for a long time so I haven't come up with a second yet

## Contributions 

If this inspires you and you have ideas, find bugs, want more customization to use it on your system or whatever, please contact me via issues.
