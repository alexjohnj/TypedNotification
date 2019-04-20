#!/bin/sh

git submodule update --remote

bundle install

bundle exec jazzy \
  --output ./ \
  --source-directory TypedNotification/ \
  --readme TypedNotification/README.md \
  --author 'Alex Jackson' \
  --author_url 'https://alexj.org' \
  --module 'TypedNotification' \
  --github_url 'https://github.com/alexjohnj/TypedNotification' \
