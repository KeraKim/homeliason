#!/usr/bin/env bash

sudo fuser -k 3000/tcp
sudo passenger stop