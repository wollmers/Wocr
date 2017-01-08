use strict;
use warnings;
use Test::More;

use lib qw( ../lib );

my @modules = qw(
  Wocr
  Wocr::Admin
  Wocr::Front

  Wocr::DB::Schema

  Wocr::DB::Schema::Result::Package

  Wocr::I18N::de
  Wocr::I18N::en

);

eval "package Wocr::I18N; use base 'Locale::Maketext'; 1;";

for my $module (@modules) {
  use_ok($module);
}

done_testing;
