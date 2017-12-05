@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

REM Need to be in Reposistory
cd D:/home/site/repository
cd

call gem install bundler --source http://rubygems.org

ECHO Bundler install (not update!)
call bundle install

cd D:/home/site/repository
cd

ECHO Running Jekyll
call bundle exec jekyll build

REM KuduSync is after this!