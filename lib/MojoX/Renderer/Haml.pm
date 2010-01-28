package MojoX::Renderer::Haml;

use warnings;
use strict;

use base 'Mojo::Base';

use Text::Haml;
use Mojo::ByteStream;

our $VERSION = '0.010101';

__PACKAGE__->attr('haml');

sub build {
    my $self = shift->SUPER::new(@_);
    $self->_init(@_);
    return sub { $self->_render(@_) }
}

sub _init {
    my $self = shift;
    my %args = @_;

    my $mojo = delete $args{mojo};

    my %config = (%{$args{haml_options} || {}});

    $config{escape} = <<'EOF';
    my $v = shift;
    ref $v && ref $v eq 'Mojo::ByteStream'
      ? "$v"
      : Mojo::ByteStream->new($v)->xml_escape->to_string;
EOF

    $self->haml(Text::Haml->new(%config));

    return $self;
}

sub _render {
    my ($self, $r, $c, $output, $options) = @_;

    use Data::Dumper;

    my $path;
    unless ($path = $c->stash->{'template_path'}) {
        $path = $r->template_path($options);
    }

    my $t = $r->template_name($options);

    if ($r->can('helper')) {
        $self->haml->helpers_arg($c);
        $self->haml->helpers($r->helper);
    }

    $c->app->log->debug("Rendering $path");

    # Try template
    if (-r $path) { $$output = $self->haml->render_file($path, %{$c->stash}) }

    # Try DATA section
    elsif (my $d = $r->get_inline_template($c, $t)) {
        $$output = $self->haml->render($d, %{$c->stash});
    }

    # No template
    else {
        $c->app->log->error(qq/Template "$t" missing or not readable./);
        $c->render_not_found;
        return;
    }

    unless (defined $$output) {
        $$output = $self->haml->error;
        die $self->haml->error;
        return 0;
    }

    return 1;
}

1;
