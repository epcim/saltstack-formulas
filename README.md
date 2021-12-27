# SaltStack formulas

This repo is simple wrapper to fetch and update all upstream saltstack formulas
(https://github.com/saltstack-formulas).

Inspired by https://github.com/salt-formulas/salt-formulas

## How it works

* Scripts to list github upstream repos and configure them locally
* May creates forks or submodules at `formulas/<formula name>`

## Usage

```
pipenv install
pipenv shell

make update_forks

gitbatch -d formulas
gitbatch -d formulas --mode=pull
```

Other:
```
make help
make list
```

