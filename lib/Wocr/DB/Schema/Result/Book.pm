package Wocr::DB::Schema::Result::Book;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('book');

__PACKAGE__->add_columns(
  'id',
  {data_type => 'integer', is_auto_increment => 1, is_nullable => 0},
  'title',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 255},
  'author',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 255},
  'year',
  {data_type => 'varchar', default_value => '0', is_nullable => 0, size => 25},
  'url',
  {data_type => 'varchar', default_value => '', is_nullable => 0, size => 255},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint("id_UNIQUE", ['id']);

1;
