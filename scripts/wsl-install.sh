#!/bin/bash

# Basic configuration
sudo apt get update
sudo apt upgrade -y

# Useful packages
sudo apt install -yqq fontconfig daemonize apt-transport-https ca-certificates curl gnupg lsb-release