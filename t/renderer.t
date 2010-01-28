#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

use Mojo;
use MojoX::Dispatcher::Routes::Controller;
use Mojolicious::Controller;
use MojoX::Renderer;
use MojoX::Renderer::Haml;

my $c = MojoX::Dispatcher::Routes::Controller->new(app => Mojo->new);
$c->app->log->path(undef);
$c->app->log->level('fatal');

$c->app->home->parse("$FindBin::Bin/../");

my $r = MojoX::Renderer->new(default_format => 'haml');
$r->add_handler(haml => MojoX::Renderer::Haml->build);

$c->stash->{partial} = 1;
$c->stash->{format} = 'html';
$c->stash->{template_path} = "t/renderer/template.html.haml";
$c->stash->{handler}  = 'haml';
is($r->render($c), "<foo></foo>\nt/renderer/template.html.haml\n");
