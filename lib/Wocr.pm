package Wocr;
use Mojo::Base 'Mojolicious';

use Data::Dumper;

our $VERSION = '0.01';

use File::Basename 'dirname';
use File::Spec;
use File::Spec::Functions qw'rel2abs catdir';
use File::ShareDir 'dist_dir';
use Cwd;

use Mojo::Home;

has db => sub {
  my $self         = shift;
  my $schema_class = $self->config->{db_schema}
    or die "Unknown DB Schema Class";
  eval "require $schema_class"
    or die "Could not load Schema Class ($schema_class), $@";

  my $db_connect = $self->config->{db_connect}
    or die "No DBI connection string provided";
  my @db_connect = ref $db_connect ? @$db_connect : ($db_connect);

  my $schema = $schema_class->connect(@db_connect)
    or die "Could not connect to $schema_class using $db_connect[0]";

  return $schema;
};

has app_debug => 0;

has home_path => sub {
  my $path = $ENV{MOJO_HOME} || getcwd;
  return File::Spec->rel2abs($path);
};

has config_file => sub {
  my $self = shift;
  return $ENV{WOCR_CONFIG} if $ENV{WOCR_CONFIG};

  return rel2abs('wocr.conf', $self->home_path);
};

sub startup {
  my $app = shift;

  $app->plugin(
    Config => {
      file    => $app->config_file,
      default => {
        'db_connect' => [
          'dbi:SQLite:dbname=' . $app->home->rel_file('wocr.db'),
          undef,
          undef,
          {'sqlite_unicode' => 1}
        ],
        'db_schema' => 'Wocr::DB::Schema',
        'secret'    => '47110815'
      },
    }
  );

  $app->plugin('I18N');
  $app->plugin('Mojolicious::Plugin::ServerInfo');
  $app->plugin('Mojolicious::Plugin::DBInfo');

  {
    # use content from directories under share/files or using File::ShareDir
    my $lib_base = catdir(dirname(rel2abs(__FILE__)), '..', 'share','files');

    my $public = catdir($lib_base, 'public');

    $app->static->paths->[0] = -d $public ? $public : catdir(dist_dir('Wocr'), 'files','public');
    my $static_path = $app->static->paths->[0];

    my $templates = catdir($lib_base, 'templates');
    $app->renderer->paths->[0] = -d $templates ? $templates : catdir(dist_dir('Wocr'), 'files', 'templates');
  }

  push @{$app->commands->namespaces}, 'Wocr::Command';

  $app->secrets([$app->config->{secret}]);

  $app->helper(schema => sub { shift->app->db });

  $app->helper('home_page' => sub {'/'});

  my $routes = $app->routes;

  $routes->get('/')->to('front#index');
  $routes->get('/front/*name')->to('front#page');

  $routes->get('/book/*book')->to('book#show');
  $routes->post('/book')->to('book#query');
  $routes->get('/books' => sub { shift->render });

  $routes->get('/page/*page')->to('page#show');
  $routes->post('/page')->to('page#query');
  $routes->get('/pages' => sub { shift->render });

  $routes->get('/about' => sub { shift->render });

}

1;

__END__

=head1 NAME

Wocr - Web-Interface to ocr.bionomen.org

=begin html

<a href="https://travis-ci.org/wollmers/Wocr"><img src="https://travis-ci.org/wollmers/Wocr.png" alt="Wocr" /></a>
<a href='https://coveralls.io/r/wollmers/Wocr?branch=master'><img src='https://coveralls.io/repos/wollmers/Wocr/badge.png?branch=master' alt='Coverage Status' /></a>
<a href='http://cpants.cpanauthors.org/dist/Wocr'><img src='http://cpants.cpanauthors.org/dist/Wocr.png' alt='Kwalitee Score' /></a>
<a href="http://badge.fury.io/pl/Wocr"><img src="https://badge.fury.io/pl/Wocr.svg" alt="latest CPAN version" height="18"></a>

=end html

=head1 SYNOPSIS

 $ wocr setup
 $ wocr daemon

=head1 DESCRIPTION

L<Wocr> is a Perl web application.

=head1 INSTALLATION

L<Wocr> uses well-tested and widely-used CPAN modules, so installation should be as simple as

    $ cpanm Wocr

when using L<App::cpanminus>. Of course you can use your favorite CPAN client or install manually by cloning the L</"SOURCE REPOSITORY">.

=head1 SETUP

=head2 Environment

Although most of L<Wocr> is controlled by a configuration file, a few properties must be set before that file can be read. These properties are controlled by the following environment variables.

=over

=item C<Wocr_HOME>

This is the directory where L<Wocr> expects additional files. These include the configuration file and log files. The default value is the current working directory (C<cwd>).

=item C<Wocr_CONFIG>

This is the full path to a configuration file. The default is a file named F<Wocr.conf> in the C<Wocr_HOME> path, however this file need not actually exist, defaults may be used instead. This file need not be written by hand, it may be generated by the C<Wocr config> command.

=back

=head2 The F<wocr> command line application

L<Wocr> installs a command line application, C<wocr>. It inherits from the L<mojo> command, but it provides extra functions specifically for use with Wocr.

=head3 config

 $ wocr config [options]

This command writes a configuration file in your C<Wocr_HOME> path. It uses the preset defaults for all values, except that it prompts for a secret. This can be any string, however stronger is better. You do not need to memorize it or remember it. This secret protects the cookies employed by Wocr from being tampered with on the client side.

L<Wocr> does not need to be configured, however it is recommended to do so to set your application's secret.

The C<--force> option may be passed to overwrite any configuration file in the current working directory. The default is to die if such a configuration file is found.

=head3 setup

 $ Wocr setup

This step is required. Run C<Wocr setup> to setup a database. It will use the default DBI settings (SQLite) or whatever is setup in the C<Wocr_CONFIG> configuration file.

=head1 RUNNING THE APPLICATION

 $ Wocr daemon

After the database is has been setup, you can run C<Wocr daemon> to start the server.

You may also use L<morbo> (Mojolicious' development server) or L<hypnotoad> (Mojolicious' production server). You may even use any other server that Mojolicious supports, however for full functionality it must support websockets. When doing so you will need to know the full path to the C<Wocr> application. A useful recipe might be

 $ hypnotoad `which Wocr`

where you may replace C<hypnotoad> with your server of choice.

=head2 Logging

Logging in L<Wocr> is the same as in L<Mojolicious|Mojolicious::Lite/Logging>. Messages will be printed to C<STDERR> unless a directory named F<log> exists in the C<Wocr_HOME> path, in which case messages will be logged to a file in that directory.

=head1 TECHNOLOGIES USED

=over

=item *

L<Mojolicious|http://mojolicio.us> - a next generation web framework for the Perl programming language

=item *

L<DBIx::Class|http://www.dbix-class.org/> - an extensible and flexible Object/Relational Mapper written in Perl

=item *

L<Bootstrap|http://twitter.github.com/bootstrap> - the CSS/JS library from Twitter

=item *

L<jQuery|http://jquery.com/> - jQuery


=back

=head1 SEE ALSO

=over

=item *

L<tesseract>

=back

=head1 SOURCE REPOSITORY

L<http://github.com/wollmers/Wocr>

=head1 AUTHOR

Helmut Wollmersdorfer, E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=begin html

<a href='http://cpants.cpanauthors.org/author/wollmers'><img src='http://cpants.cpanauthors.org/author/wollmers.png' alt='Kwalitee Score' /></a>

=end html

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Helmut Wollmersdorfer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
