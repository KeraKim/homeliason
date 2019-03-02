#!/usr/bin/env bash

sudo fuser -k 80/tcp
sudo passenger stop