use strict;
use warnings;
use Test::More tests => 1;

# The two modules in this dist have been released under two different dist names.
# MojoX-Renderer-Haml only defined a $VERSION for MojoX::Renderer::Haml.
# Mojolicious-Plugin-HamlRenderer only defined a $VERSION Mojolicious::Plugin::HamlRenderer.
# So now to keep PAUSE (and 02packages.details.txt.gz) happy
# we should ensure both modules get an updated $VERSION.

my @modules = qw(
  MojoX::Renderer::Haml
  Mojolicious::Plugin::HamlRenderer
);

eval "require $_" || die $@
  for @modules;

&is( (map { $_->VERSION } @modules), 'module versions match' );
