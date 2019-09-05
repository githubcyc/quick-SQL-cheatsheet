#!/bin/bash
git branch
git remote add upstream https://github.com/enochtangg/quick-SQL-cheatsheet.git
git remote -v
git fetch upstream

# save changes, and switch to master
git add -A 
git stash
git checkout master

git merge upstream/master
git push gh master

# switch back
git checkout dev
git stash pop
