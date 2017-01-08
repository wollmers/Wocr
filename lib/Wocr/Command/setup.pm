package Wocr::Command::setup;
use Mojo::Base 'Mojolicious::Command';

use Term::Prompt qw/prompt/;

has description => "Create the database for your Wocr application.\n";
has usage       => "usage: $0 setup\n";

sub run {
  my ($self) = @_;


  $self->inject_sample_data();

  print "Database created! Run 'wocr daemon' to start the server.\n";
}

sub inject_sample_data {
  my $self = shift;
  my $schema = eval { $_[0]->isa('Wocr::DB::Schema') } ? shift() : $self->app->schema;

  my $test = shift;

  $schema->deploy({ add_drop_table => 1});

=pod

  my $samples = [
    {author => 'WOLLMERS', name => 'Wocr-0.01'},
    {author => 'WOLLMERS', name => 'Text-Undiacritic-0.07'},
  ];

  my $samples1 = [
    {author => 'WOLLMERS', name => 'Wocr-0.01'},
    {author => 'WOLLMERS', name => 'Text-Undiacritic-0.07'},
  ];

  if ($test) {
    for my $sample (@$samples) {
      $schema->resultset('Package')->create($sample);
    }

    for my $sample (@$samples) {
      $schema->resultset('Cover')->create($sample);
    }
  }

=cut

  return $schema;
}

1;
