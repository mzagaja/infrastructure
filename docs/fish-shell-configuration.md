# Fish Shell Configuration

## Install Fish Shell
```
brew install fish &&
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells &&
chsh -s /opt/homebrew/bin/fish &&
fish_add_path /opt/homebrew/bin &&
fish_add_path /opt/homebrew/sbin
```

## Editor
Without quotes:
`set -Ux EDITOR nova -w`

## iTerm 2 Integration
Install this from iTerm2 --> Install Shell Integration

## Fisher
Install fisher to manage plug-ins for fish.
```
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
```
## asdf Install
https://asdf-vm.com/guide/getting-started.html

## Set 1Password as Default SSH Client
https://developer.1password.com/docs/ssh/agent/compatibility#configure-ssh_auth_sock-globally-for-every-client

# Fix Husky and Tower Issue
Following [these instructions](https://www.git-tower.com/help/guides/integration/environment/mac) you should drop-in a file that adds a directory with node into the $PATH for Tower.

# Get Alt Keyboard Shortcuts to Work in iTerm2
Follow [this Stackoverflow post advice](https://stackoverflow.com/a/48000819/2149359) to set the left ⌥ (option) key to an Esc+ key:
<img width="1128" alt="image" src="https://user-images.githubusercontent.com/565647/138564899-03607920-60f7-441b-9088-830ef52cb60c.png">

## Install Monokai Color Scheme for iTerm2
https://github.com/Monokai/monokai-pro-sublime-text/issues/45
http://packages.monokai.pro/iterm/monokai-pro-iterm.zip

## GPG Signing with GPG2 and Tower
See https://github.com/fish-shell/fish-shell/issues/6643. The person who made the fisher install removed it. Lucky us.
```
brew install pinentry-mac
```

Update `~/.gnupg/gpg-agent.conf` to work with Tower:

```
default-cache-ttl 600
max-cache-ttl 7200
pinentry-program /opt/homebrew/bin/pinentry-mac
use-standard-socket
enable-ssh-support
```

## Move Nova Data to Mac
Follow [these instructions](https://help.panic.com/nova/moving-data/).
