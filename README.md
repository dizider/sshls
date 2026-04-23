# sshls

Interactive SSH host picker built on `fzf`. Lists hosts from `~/.ssh/config` with tag support, fuzzy search, and a live config preview.

## Usage

```
sshls [tag]
```

Without arguments, shows all hosts. With a tag, shows only hosts matching that tag.

```sh
sshls              # show all hosts
sshls production   # show only hosts tagged "production"
sshls eu           # show only hosts tagged "eu"
```

Inside fzf you can type to fuzzy-search, use arrow keys to navigate, and press Enter to connect. Press Escape or Ctrl-C to exit.

## Tagging hosts

Add a `# Tags:` comment immediately before the `Host` entry in `~/.ssh/config`:

```
# Tags: production, eu
Host web-eu-01
    HostName 1.eu.example.com
    User alice
    Port 22

# Tags: staging, eu
Host web-eu-01-staging
    HostName 1.staging.eu.example.com
    User alice
```

Multiple tags are comma-separated. Tags are shown next to the hostname in the picker.

### Reserved tag: `ignore`

Hosts tagged `ignore` are hidden from the list entirely:

```
# Tags: ignore
Host legacy-host
    HostName old.example.com
```

## Setup

### Script

Link or copy `sshls` to somewhere on your `$PATH`:

```sh
ln -s /path/to/sshls-script/sshls ~/scripts/sshls
# or copy it: cp sshls ~/scripts/sshls
```

Make sure the target directory is on your `$PATH`.

### Zsh autocompletion

Link `_sshls` to your zsh completions directory:

```sh
ln -s /path/to/sshls-script/_sshls ~/.zsh/completions/_sshls
```

If `~/.zsh/completions` is not already in your `fpath`, add this to `~/.zshrc` before `compinit`:

```zsh
fpath=(~/.zsh/completions $fpath)
```

Then reload completions:

```sh
exec zsh
```

`sshls <Tab>` will now complete with the tags defined in `~/.ssh/config`.

## Dependencies

- [`fzf`](https://github.com/junegunn/fzf)
- `awk`, `column` (standard on most systems)
