# Fish Shell Configuration

## Editor
Without quotes:
`set -Ux EDITOR subl -w`

## iTerm 2 Integration
Install this from iTerm2 --> Install Shell Integration
Now you must edit the iterm2_fish_prompt instead of fish_prompt.
`funced iterm2_fish_prompt`


## Python virtualenv
Install pipenv using brew.
`brew install pipenv`

[Fish Shell Pipenv Plug-in](https://github.com/sentriz/fish-pipenv/)
Drop the file in `subl ~/.config/fish/functions/pipenv.fish`
