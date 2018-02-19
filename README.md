# SaltStack formulas

This repo is simple wrapper to fetch and update all upstream saltstack formulas
(https://github.com/saltstack-formulas).

Inspired by https://github.com/salt-formulas/salt-formulas

## How it works

* Scripts to list github upstream repos and configure them locally
* May creates forks or submodules at `formulas/<formula name>`
* May use `mu_repo` or `myrepos`, tools to help in dealing with multiple git ...

## Usage

      make help
      make list

### for mu_repo fans
      make muconfig
      mu list
      mu help

