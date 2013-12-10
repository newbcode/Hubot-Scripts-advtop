package Hubot::Scripts::advtop;

use strict;
use warnings;
use Encode qw(encode decode);
use Data::Printer;
use DateTime;

sub load {
    my ( $class, $robot ) = @_;

    $robot->hear(
    
        qr/^advtop$/,

        sub {
            my $msg = shift;
            my $user = $msg->message->user->{name};

        }
    );
}

1;

=pod

=head1 Name 

    Hubot::Scripts::advtop
 
=head1 SYNOPSIS

    Perl Advent Calendar Top 10

=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yunchang Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself
 
=cut
