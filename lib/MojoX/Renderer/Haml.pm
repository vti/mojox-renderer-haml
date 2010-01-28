package MojoX::Renderer::Haml;

use warnings;
use strict;

use base 'Mojo::Base';

use Text::Haml;
use Mojo::ByteStream 'b';

our $VERSION = '0.010101';

sub build {
    my $self = shift->SUPER::new(@_);

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

    # Interpret again
    if ($haml && $haml->compiled) {
        $$output = $haml->interpret(%{$c->stash});
    }

    # No cache
    else {
        $haml ||= Text::Haml->new(escape => $ESCAPE);

        if ($r->can('helper')) {
            $haml->helpers_arg($c);
            $haml->helpers($r->helper);
        }

        $c->app->log->debug("Rendering $path");

        # Try template
        if (-r $path) {
            $$output = $haml->render_file($path, %{$c->stash});
        }

        # Try DATA section
        elsif (my $d = $r->get_inline_template($c, $t)) {
            $$output = $haml->render($d, %{$c->stash});
        }

        # No template
        else {
            $c->app->log->error(qq/Template "$t" missing or not readable./);
            $c->render_not_found;
            return;
        }
    }

    unless (defined $$output) {
        my $e = $$output;
        $$output = '';
        $c->app->log->error( qq/Template error in "$t": / . $haml->error);
        $c->render_exception($haml->error);

        return 0;
    }

    $r->{_haml_cache}->{$cache} ||= $haml;

    return 1;
}

1;
