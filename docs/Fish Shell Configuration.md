# Fish Shell Configuration

## Editor
Without quotes:
`set -Ux EDITOR subl -w`

## iTerm 2 Integration
Install this from iTerm2 --> Install Shell Integration
Now you must edit the iterm2_fish_prompt instead of fish_prompt.
`funced iterm2_fish_prompt`

## Python Virtual Environments in Fish Shell with pipenv
```sh
brew install pipenv
echo 'set pipenv_fish_fancy yes' >> ~/.config/fish/config.fish
```

## Node Virtual Environment in Fish Shell with fish-nvm
[Fish NVM](https://github.com/jorgebucaran/fish-nvm)
```sh
brew install nvm
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config

for i in conf.d functions completions
  curl https://git.io/$i.nvm.fish --create-dirs -sLo $XDG_CONFIG_HOME/fish/$i/nvm.fish
end
```

## RVM Ruby Virtual Environments in Fish Shell with rvm
[RVM](https://rvm.io/integration/fish)
```sh
curl -L --create-dirs -o ~/.config/fish/functions/rvm.fish https://raw.github.com/lunks/fish-nuggets/master/functions/rvm.fish
echo "rvm default" >> ~/.config/fish/config.fish
```
