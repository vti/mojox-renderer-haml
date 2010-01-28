#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Test::Mojo;
use Mojo::Client;
use Mojolicious::Lite;

# Silence
app->log->level('error');

plugin 'haml_renderer';

get '/' => sub {
    my $self = shift;

    $self->render;
} => 'root';

my $client = Mojo::Client->new(app => app);
app->client($client);

my $t = Test::Mojo->new;
$t->client($client);

$t->get_ok('/')->status_is(200)->content_is("<foo></foo>\n");

1;
__DATA__

@@ root.html.haml
%foo
