# SSH Multi Manage

A lightweight toolkit that enhances SSH for managing multiple hosts.
It checks host availability, latency, OS details, and uptime, and provides a text-based interface for
quickly browsing and connecting to configured servers - all driven by your existing `~/.ssh/config`.

## Features

- **`connect`** - Interactive TUI for browsing and connecting to SSH hosts (shows live online/offline status)
- **`lssrv`** - List configured servers with live OS info and uptime, supports filtering
- **`hostcheck`** - Parallel port-check of all configured hosts (up / down, latency)
- **`vihosts`** - Safely edit your SSH config with syntax validation before saving
- **`configdump`** - Dump parsed SSH host configuration for inspection or debugging
- **`s2a` / `a2s`** - Convert between SSH config and Ansible inventory formats

## Requirements

- Perl 5.20+
- OpenSSH client (`ssh`)
- A valid `~/.ssh/config` file (or a custom path via `--file` / `CONNECT_CONFIG_FILE`)

### Perl module dependencies

The full list of required modules is declared in `Makefile.PL`.
Key non-core modules: `Curses::UI`, `Net::OpenSSH`, `Term::Table`.

## Installation

```bash
git clone https://github.com/DanielElgh/ssh-multi-manage.git
cd ssh-multi-manage

# Install Perl dependencies (pick one)
cpanm --installdeps .
# or: cpan .
# or, see INSTALLATION.md for installing dependencies using the distribution-specific package managers.

perl Makefile.PL
make
make test
sudo make install
```

## Usage

### connect - interactive TUI

```bash
connect                   # launch with default ~/.ssh/config
connect -f /path/to/config
```

### lssrv - list servers

```bash
lssrv                     # show all hosts with OS & uptime
lssrv prod                # filter to hosts matching "prod"
lssrv --hostnames         # print bare hostnames (useful for scripting / completion)
```

### hostcheck - check host availability

```bash
hostcheck                 # parallel check of all hosts
HOSTCHECK_JOBS=8 hostcheck  # limit concurrency
```

### vihosts - edit SSH config safely

```bash
vihosts                   # edit ~/.ssh/config with syntax validation
vihosts /path/to/config   # edit a specific config file
```

### configdump - inspect parsed config

```bash
configdump                # dump all hosts
configdump myhost         # dump a specific host
configdump -e             # show enriched (ssh -G) data
```

### s2a / a2s - format conversion

```bash
s2a                       # SSH config → Ansible inventory (stdout)
s2a -i /path/to/config    # explicit input file
a2s -i inventory.ini      # Ansible inventory → SSH config (stdout)
```

## Configuration

All tools read from `~/.ssh/config` by default. Override with:

| Method | Scope |
|---|---|
| `CONNECT_CONFIG_FILE` environment variable | All tools |
| `--file <path>` / `-f <path>` | `connect` only |
| Positional argument | `vihosts`, `configdump` |

### Custom tags

Add `# tags <tag1> <tag2>` comments inside a `Host` block to tag hosts.
Tags are used by `s2a` to generate Ansible group assignments and displayed by `lssrv`.

```sshconfig
Host webserver01
    HostName 10.0.0.1
    User admin
    # tags prod web
```

### Concurrency control

| Variable | Tool | Default |
|---|---|---|
| `LSSRV_JOBS` | `lssrv` | 16 |
| `HOSTCHECK_JOBS` | `hostcheck` | 32 |

## SSH agent tips

To avoid repeatedly entering passphrases, add to `~/.bashrc`:

```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" >/dev/null
fi
```

And to `~/.ssh/config`:

```
Host *
    AddKeysToAgent yes
```

## Running tests

```bash
make test
# or directly:
prove -lv t/
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE) - Copyright 2025, 2026 Daniel Elgh

