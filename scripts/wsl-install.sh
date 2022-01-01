#!/bin/bash

## Basic configuration
sudo apt get update
sudo apt upgrade -y

## Tools for systemd
sudo apt install -yqq fontconfig daemonize apt-transport-https ca-certificates curl gnupg lsb-release