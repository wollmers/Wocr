package Wocr::DB::Schema::Result::Page;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('pages');

__PACKAGE__->add_columns(
  'id',
  {data_type => 'integer', is_auto_increment => 1, is_nullable => 0},
  'book_id',
  {data_type => 'integer', default_value => 0, is_nullable => 0},
  'index',
  {data_type => 'integer', default_value => 0, is_nullable => 0},
  'number',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 25},
  'filename',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 255},
  'version',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 25},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint("id_UNIQUE", ['id']);

1;
