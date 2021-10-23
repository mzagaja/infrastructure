# Fish Shell Configuration

## Editor
Without quotes:
`set -Ux EDITOR nova -w`

## iTerm 2 Integration
Install this from iTerm2 --> Install Shell Integration

## Python Virtual Environments in Fish Shell with pipenv
```sh
brew install pipenv
echo 'set pipenv_fish_fancy yes' >> ~/.config/fish/config.fish
```
## Fisher
Install fisher to manage plug-ins for fish.
```
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
```

## Node Virtual Environment in Fish Shell with fish-nvm
[Fish NVM](https://github.com/jorgebucaran/fish-nvm)
```sh
fisher install jorgebucaran/nvm.fish
```

## RVM Ruby Virtual Environments in Fish Shell with rvm
[RVM](https://rvm.io/integration/fish)
```sh
curl -L --create-dirs -o ~/.config/fish/functions/rvm.fish https://raw.github.com/lunks/fish-nuggets/master/functions/rvm.fish
echo "rvm default" >> ~/.config/fish/config.fish
```

# Fix Husky and Tower Issue
Following [these instructions](https://www.git-tower.com/help/guides/integration/environment/mac) you should drop-in a file that adds a directory with node into the $PATH for Tower.

# Get Alt Keyboard Shortcuts to Work in iTerm2
Follow [this Stackoverflow post advice](https://stackoverflow.com/a/48000819/2149359) to set the left ⌥ (option) key to an Esc+ key:
<img width="1128" alt="image" src="https://user-images.githubusercontent.com/565647/138564899-03607920-60f7-441b-9088-830ef52cb60c.png">

