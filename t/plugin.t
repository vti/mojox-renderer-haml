#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 9;

use Test::Mojo;
use Mojo::Client;
use Mojolicious::Lite;

# Silence
app->log->level('fatal');

plugin 'haml_renderer';

get '/' => 'root';

get '/error' => 'error';

my $client = Mojo::Client->new(app => app);
app->client($client);

my $t = Test::Mojo->new;
$t->client($client);

# No cache
$t->get_ok('/')->status_is(200)->content_is("<foo></foo>\n");

# Cache hit
$t->get_ok('/')->status_is(200)->content_is("<foo></foo>\n");

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
