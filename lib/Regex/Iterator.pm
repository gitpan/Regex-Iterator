package Regex::Iterator;

use strict;
use vars qw($VERSION);

$VERSION = "0.2";


=pod

=head1 NAME

Regex::Iterator - provides an iterator interface to regexps

=head1 SYNOPSIS


	my $it = Regex::Iterator->new($regex, $string);

	while (my $match = $it->match) {
		$it->replace('replaced') if $match eq 'replaceable';
	}
	print $it->result,"\n";

=head1 DESCRIPTION

Inspired by Mark Jason Dominus' talk I<Programming with Iterators and Generators> 
(available from http://perl.plover.com/yak/iterators/) this is an iterative regex 
matcher based on the work I did for B<URI::Find::Iterator>


=head1 METHODS

=head2 new <regex> <string> 
    
Fairly self explanatory - takes a regex and a string to match it against.

C<regex> can be the result of a C<qr{}>

=cut


sub new {
    my ($class, $re, $string) = @_;
	$re = qr/$re/ unless ref($re) eq 'Regexp';

    my $self          = {};
    $self->{_re}      = $re;
    $self->{_result}  = "";
    $self->{_remain}  = $string;
    $self->{_match}   = undef;
    

    return bless $self, $class;

}

=head2 match

Returns the current match as a string.

It then advances to the next one.

=cut 


sub match {
        my $self = shift;
        return undef unless defined $self->{_remain};



        local $1;
        "null" =~ m!()!; # set $1 to ""
        $self->_next();

        my $re = $self->{_re};

        $self->{_remain}   =~ /(.*?)($re)(.*)/s;


        return unless defined $2 and $2 ne "";

		
        my $match = $2;
        my $pre  = $1; $pre  = '' unless defined $pre;
		my $post = $+; $post = '' unless defined $post;

        $self->{_result}  .= $pre;
        $self->{_remain}   = $post; 
        $self->{_match}    = $match;

        return $match;
}



=head2 replace <replacement>

Replaces the current match with I<replacement>

=cut




sub replace {
        my ($self, $replace) = @_;
        return unless defined $self->{_match};
        $self->{_match} = $replace;

}

=head2 result

Returns the string with all replacements.

=cut 

sub result {
    my $self = shift;

	return join '', grep { defined } @$self{qw/ _result _match _remain /};
}

sub _next {
         my $self = shift;
         return undef unless defined $self->{_match};
        
         $self->{_result}  .= $self->{_match};
         $self->{_match}    = undef;
}


=pod

=head1 BUGS

None that I know of but there are probably loads.

=head1 COPYING

Distributed under the same terms as Perl itself.

=head1 AUTHOR

Copyright (c) 2003, Simon Wistow <simon@thegestalt.org>

=head1 SEE ALSO

L<URI::Find::Iterator>, http://perl.plover.com/yak/iterators/

=cut

# keep perl happy
1;
