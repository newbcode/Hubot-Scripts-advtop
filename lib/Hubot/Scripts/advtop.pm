package Hubot::Scripts::advtop;

use strict;
use warnings;
use Encode qw(encode decode);
use Data::Printer;
use DateTime;
use LWP::UserAgent;

sub load {
    my ( $class, $robot ) = @_;

    $robot->hear(
    
        qr/^advtop$/,

        sub {
            my $msg = shift;
            my $user = $msg->message->user->{name};

            adv_cal();
        }
    );
}


sub adv_cal {
    my $ua = LWP::UserAgent->new;

    my $fb_api_url ='http://api.facebook.com/restserver.php?method=links.getStats&urls=';
    my $url_2011 = 'http://advent.perl.kr/2011/2011-12-';
    my $url_gen;
    my $start_num = 1;
    my %adv_info;
    my @urls;
    my @adv_info;

    while ( $start_num <= 24 ) {
        if ( $start_num < 10 ) {
            $url_gen = "$fb_api_url$url_2011"."0"."$start_num"."\.html";
            push @urls, $url_gen;
        }
        else {
            $url_gen = "$fb_api_url$url_2011$start_num"."\.html";
            push @urls, $url_gen;
        }
        $start_num++;
    }

    foreach my $url (@urls) {

        my ( $argv_url, $share, $like, $comment, $total, $rank);
        my $response = $ua->get($url);

        if ($response->is_success) {

            my $likes =  $response->decoded_content;

            if ( $likes =~ /<url>(.+)<\/url>/ ) { $argv_url = $1; }
            if ( $likes =~ /<share_count>(\d+)<\/share_count>/ ) { $share = $1; }
            if ( $likes =~ /<like_count>(\d+)<\/like_count>/ ) { $like = $1; }
            if ( $likes =~ /<comment_count>(\d+)<\/comment_count>/ ) { $comment = $1; }
            if ( $likes =~ /<total_count>(\d+)<\/total_count>/ ) { $total = $1; }

            push @adv_info, ($argv_url, $share, $like, $comment, $total);
        }
        else {
            die $response->status_line;
        }

        %adv_info = (
            $argv_url => {
                share       => $share,
                like        => $like,
                comment     => $comment,
                total       => $total,
            }
        );
    }
    p %adv_info;

    foreach my $paser(@adv_info) {
        #print "$paser\n";
    }
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
