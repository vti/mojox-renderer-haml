package Mojolicious::Plugin::HamlRenderer;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use MojoX::Renderer::Haml;

sub register {
    my ($self, $app, $args) = @_;

    $args ||= {};

    my $haml = MojoX::Renderer::Haml->build(%$args, mojo => $app);

    # Add "haml" handler
    $app->renderer->add_handler(haml => $haml);
}

1;
