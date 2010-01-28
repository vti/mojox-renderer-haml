#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 15;

use Test::Mojo;
use Mojo::Client;
use Mojolicious::Lite;

# Silence
app->log->level('fatal');

plugin 'haml_renderer';

get '/' => 'root';

get '/error' => 'error';

get '/with_wrapper' => 'with_wrapper';

my $client = Mojo::Client->new(app => app);
app->client($client);

my $t = Test::Mojo->new;
$t->client($client);

# No cache
$t->get_ok('/')->status_is(200)->content_is("<foo></foo>\n");

# Cache hit
$t->get_ok('/')->status_is(200)->content_is("<foo></foo>\n");

# With wrapper
$t->get_ok('/with_wrapper')->status_is(200)->content_is("<foo>Hello!\n</foo>\n");

# Not found
$t->get_ok('/foo')->status_is(404)->content_is("Not found\n");

# Error
$t->get_ok('/error')->status_is(500)->content_like(qr/^Exception:\nsyntax error/);

1;
__DATA__

@@ root.html.haml
%foo

@@ error.html.haml
= 1 + {

@@ exception.html.haml
Exception:
= exception

@@ not_found.html.haml
Not found

@@ with_wrapper.html.haml
- layout 'wrapper';
Hello!

@@ layouts/wrapper.html.haml
%foo= content
