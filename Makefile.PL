use inc::Module::Install;
name 'WWW-Google-WeatherJP';
all_from 'lib/WWW/Google/WeatherJP.pm';

requires 'DateTime';
requires 'Encode';
requires 'URI';
requires 'WWW::Mechanize';
requires 'Web::Scraper';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
