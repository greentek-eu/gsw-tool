# GSW-TOOL - Git SSH command wrappers manager

## Decription

A tool to manage basic wrappers for `GIT_SSH_COMMAND`.

If you find yourself working with a lot of ssh keys and multiple git 
servers, you might reach the point where `~/.ssh/config` won't suffice,
or it won't work as expected.

## How it works

It's a bash script that does simple mapping from a profile (a name that
you choose) to a ssh key. It works by populating `GIT_SSH_COMMAND`
environment variable with SSH commands such as: `ssh -i /path/to/key`.

The script is not used directly, but proxied through a bash function
so that it can set the upmentioned environment variable in the current
working shell

## Installing

```
curl -sSL https://github.com/greentek-eu/gsw-tool/latest/dist/install | bash -
```

## Usage

Map your SSH keys from `~/.ssh` to mnemonics, and then switch using `gsw use`.

```
~$ gsw mapkey work my_work_key_name
~$ gsw mapkey personal my_personal_key_name
~$ gsw use work # or gsw use personal
```
