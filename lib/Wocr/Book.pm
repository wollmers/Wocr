package Wocr::Book;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # Render template "front/index.html.ep"
  $self->render();
}

sub query {
  my $self = shift;
  my $book = $self->param('book');

  $self->redirect_to("/book/$book");
}

sub show {
  my $self = shift;

  # Render $page
  $self->render_not_found
    unless $self->render();
}

1;
