use strict;
use warnings;
package Dist::Zilla::Plugin::Keywords;
BEGIN {
  $Dist::Zilla::Plugin::Keywords::AUTHORITY = 'cpan:ETHER';
}
# git description: v0.003-1-g4a0135e
$Dist::Zilla::Plugin::Keywords::VERSION = '0.004';
# ABSTRACT: add keywords to metadata in your distribution
# KEYWORDS: plugin distribution metadata cpan-meta keywords
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
with 'Dist::Zilla::Role::MetaProvider',
    'Dist::Zilla::Role::PPI' => { -version => '5.009' };
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose 'ArrayRef';
use MooseX::Types::Common::String 'NonEmptySimpleStr';
use namespace::autoclean;

my $word = subtype NonEmptySimpleStr,
    where { !/\s/ };

my $wordlist = subtype ArrayRef[$word];
coerce $wordlist, from ArrayRef[NonEmptySimpleStr],
    via { [ map { split /\s+/, $_ } @$_ ] };


sub mvp_aliases { +{ keyword => 'keywords' } }
sub mvp_multivalue_args { qw(keywords) }

has keywords => (
    is => 'ro', isa => $wordlist,
    coerce => 1,
    lazy => 1,
    default => sub {
        my $self = shift;
        my @keywords = $self->keywords_from_file($self->zilla->main_module);
        \@keywords;
    },
);

sub metadata
{
    my $self = shift;
    return { keywords => $self->keywords };
}

sub keywords_from_file
{
    my ($self, $file) = @_;

    my $document = $self->ppi_document_for_file($file);

    my @keywords;
    $document->find(
        sub {
            die if $_[1]->isa('PPI::Token::Comment')
                and (@keywords = $_[1]->content =~ m/^\s*#+\s*KEYWORDS:\s*(.+)$/m);
        }
    );
    $self->log('found keyword string in main module: ' . $_) foreach @keywords;
    return map { split /\s+/ } @keywords;
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=encoding UTF-8

=for :stopwords Karen Etheridge irc

=head1 NAME

Dist::Zilla::Plugin::Keywords - add keywords to metadata in your distribution

=head1 VERSION

version 0.004

=head1 SYNOPSIS

In your F<dist.ini>:

    [Keywords]
    keyword = plugin
    keyword = tool
    keywords = development Dist::Zilla

Or, in your F<dist.ini>:

    [Keywords]

And in your main module:

    # KEYWORDS: plugin development tool

=head1 DESCRIPTION

This plugin adds metadata to your distribution under the C<keywords> field.
The L<CPAN meta specification|https://metacpan.org/pod/CPAN::Meta::Spec#keywords>
defines this field as:

    A List of keywords that describe this distribution. Keywords must not include whitespace.

=for Pod::Coverage metadata mvp_aliases mvp_multivalue_args keywords_from_file

=head1 CONFIGURATION OPTIONS

=head2 C<keyword>, C<keywords>

One or more words to be added as keywords. Can be repeated more than once.
Strings are broken up by whitespace and added as separate words.

If no configuration is provided, the main module of your distribution is
scanned for the I<first> C<# KEYWORDS:> comment.

=head1 SUPPORT

Bugs may be submitted through L<the RT bug tracker|https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-Keywords>
(or L<bug-Dist-Zilla-Plugin-Keywords@rt.cpan.org|mailto:bug-Dist-Zilla-Plugin-Keywords@rt.cpan.org>).
I am also usually active on irc, as 'ether' at C<irc.perl.org>.

=head1 SEE ALSO

=over 4

=item *

L<https://metacpan.org/pod/CPAN::Meta::Spec#keywords>

=back

=head1 AUTHOR

Karen Etheridge <ether@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut