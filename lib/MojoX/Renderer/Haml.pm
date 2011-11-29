package MojoX::Renderer::Haml;

use warnings;
use strict;

use base 'Mojo::Base';

use Mojo::ByteStream 'b';
use Mojo::Exception;
use Text::Haml;


__PACKAGE__->attr(haml_args=>sub { return {}; });

sub build {
    my $self = shift->SUPER::new(@_);
    my %args=@_;
    $self->haml_args(\%args);
    return sub { $self->_render(@_) }
}

my $ESCAPE = <<'EOF';
    my $v = shift;
    ref $v && ref $v eq 'Mojo::ByteStream'
      ? "$v"
      : Mojo::ByteStream->new($v)->xml_escape->to_string;
EOF

sub _render {
    my ($self, $r, $c, $output, $options) = @_;

    my $path;
    unless ($path = $c->stash->{'template_path'}) {
        $path = $r->template_path($options);
    }

    my $list = join ', ', sort keys %{$c->stash};
    my $cache = b("$path($list)")->md5_sum->to_string;

    $r->{_haml_cache} ||= {};

    my $t = $r->template_name($options);

    my $haml = $r->{_haml_cache}->{$cache};

    my %args = (app => $c->app, %{$c->stash});

    # Interpret again
    if ( $c->app->mode ne 'development' &&  $haml && $haml->compiled) {
        $haml->helpers_arg($c);

        $$output = $haml->interpret(%args);
    }

    # No cache
    else {
        $haml ||= Text::Haml->new(escape => $ESCAPE,%{$self->{haml_args}});

        $haml->helpers_arg($c);
        $haml->helpers($r->helpers);

        # Try template
        if (-r $path) {
            $$output = $haml->render_file($path, %args);
        }

        # Try DATA section
        elsif (my $d = $r->get_data_template($c, $t)) {
            $$output = $haml->render($d, %args);
        }

        # No template
        else {
            $c->app->log->error(qq/Template "$t" missing or not readable./);
            $c->render_not_found;
            return;
        }
    }

    unless (defined $$output) {
        $$output = '';

        my $e = Mojo::Exception->new($haml->error);

        $c->app->log->error( qq/Template error in "$t": / . $haml->error);

        $c->render_exception($e);

        return 0;
    }

    $r->{_haml_cache}->{$cache} ||= $haml;

    return 1;
}

1;

=head2 NAME

MojoX::Renderer::Haml - Mojolicious renderer for HAML templates. 

=head2 SYNOPSIS

   my $haml = MojoX::Renderer::Haml->build(%$args, mojo => $app);

   # Add "haml" handler
   $app->renderer->add_handler(haml => $haml);

=head2 DESCRIPTION

This module is a renderer for L<HTML::Haml> templates. normally, you 
just want to use L<Mojolicious::Plugin::HamlRenderer>.

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<viacheslav.t@gmail.com>.

=head1 COPYRIGHT

Copyright (C) 2008-2009, Viacheslav Tykhanovskyi.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut
