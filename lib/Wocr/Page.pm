package Wocr::Page;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Dom;

sub index {
  my $self = shift;

  # Render template "dist/index.html.ep"
  $self->render();
}


sub query {
  my $self = shift;
  my $dist = $self->param('page');

  $self->redirect_to("/book/$page");
}


sub show {
  my $self = shift;

  # /skins/<%= $skin %>/css/bootstrap.min.css
  my $file1 = '/Users/helmut/github/perl/Wocr/share/files/public/pages/isis_152.hocr.html';
  my $scan = '/pages/isis_152.jpg';

  open(my $in1,"<:encoding(UTF-8)",$file1) or die "cannot open $file1: $!";

  my $html = '';
  while (my $line = <$in1>) { $html .= $line;}

  my $dom = Mojo::DOM->new($html);

  my $content = $dom->at('div.ocr_page');

  #$self->stash(hocr => $content);
  #$self->stash(hocr => 'test');
  $self->stash->{hocr} = $content;
  $self->stash->{scan} = $scan;

  # Render $page
  #$self->render_not_found  unless
    $self->render();
}

1;
