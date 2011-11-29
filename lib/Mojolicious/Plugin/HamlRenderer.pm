package Mojolicious::Plugin::HamlRenderer;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use MojoX::Renderer::Haml;

our $VERSION = '1.1';


sub register {
    my ($self, $app, $args) = @_;

    $args ||= {};

    my $haml = MojoX::Renderer::Haml->build(%$args, mojo => $app);

    # Add "haml" handler
    $app->renderer->add_handler(haml => $haml);
}

1;

=head2 NAME

Mojolicious::Plugin::HamlRenderer - Load HAML renderer

=head2 SYNOPSIS

# lite app
plugin 'haml_renderer';
# or normal app
$self->plugin 'haml_renderer';

=head2 DESCRIPTION

Simple plugin to load HAML renderer into your Mojolicious app.

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<viacheslav.t@gmail.com>.
Marcus Ramberg, C<mramberg@cpan.org>.

=head1 COPYRIGHT

Copyright (C) 2008-2009, Viacheslav Tykhanovskyi.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut


