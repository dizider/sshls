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

## Adding a host

Add a new host to `~/.ssh/config` without leaving `sshls`:

- Run `sshls add`, or
- Press **Ctrl-A** inside the picker.

You'll be prompted for the alias, HostName, User, Port, IdentityFile, and Tags
(Port/IdentityFile/Tags are optional). Before saving, `sshls` runs a
non-interactive connection test; if it fails you'll be asked whether to save
anyway. The new host appears in the picker immediately.

### Adding a whole cluster

If a field contains an inline range, the add flow expands it into one host per
node. Use bash-style `{start..end}` (or `{start..end..step}`); padding is taken
from the numbers you write, so the alias and hostname can pad differently:

- Host (alias): `server-{01..03}`
- HostName: `{1..3}.server.example.com`

creates `server-01` → `1.server…`, `server-02` → `2.server…`,
`server-03` → `3.server…`. Fields without a range (User, Port, IdentityFile,
Tags) are copied to every node. Multiple ranged fields must expand to the same
count and are matched up by position.

All nodes are connection-tested in parallel; you then choose to save **all**,
only the **passing** ones, or **abort**. Nodes whose alias already exists are
skipped, so you can widen the range and re-run to grow a cluster.

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

`sshls <Tab>` will now complete with the tags defined in `~/.ssh/config` as well as the `add` subcommand.

## Dependencies

- [`fzf`](https://github.com/junegunn/fzf)
- `awk`, `column` (standard on most systems)
