#!/bin/bash

export PORT=5102

cd ~/www/checkers
./bin/checkers stop || true
./bin/checkers start