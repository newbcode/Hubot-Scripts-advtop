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
    
        qr/^advtop (\d\d\d\d)$/,

        sub {
            my $msg = shift;
            my $user = $msg->message->user->{name};
            my $year = $msg->match->[0];
            my @top_tens;
            my $cnt = 1;

            my %adv_data = adv_cal($year);

            foreach my $p ( keys %adv_data ) {
                push @top_tens, $adv_data{$p};
            }
            @top_tens = sort { $b->[4] <=> $a->[4] } @top_tens;

            foreach my $rank_p ( @top_tens ) {
                my $title = title_parser($rank_p->[0], $cnt);
                $msg->send("$title($rank_p->[1]+$rank_p->[2]+$rank_p->[3]=$rank_p->[4])");  
                last if ($cnt == 10);
                $cnt++;
            }
        }
    );
}


sub adv_cal {
    my $year = shift;
    my $ua = LWP::UserAgent->new;

    my $fb_api_url ='http://api.facebook.com/restserver.php?method=links.getStats&urls=';
    my $url_2011 = "http://advent.perl.kr/$year/$year-12-";
    my $start_num = 1;
    my ($url_gen, $adv_info, @urls);

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

    my %adv_infos;

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

            # %adv_infos 익명해쉬 생성후 배열 레퍼런스를 사용하여 \@array 형태로 자료 구조를 만든다.
            push @{ $adv_infos{$argv_url} ||= [] }, ($argv_url, $share, $like, $comment, $total);
        }
        else {
            die $response->status_line;
        }
    }
    return %adv_infos;
}

sub title_parser {
    my ($url, $rank_num) = @_; 

    my $ua = LWP::UserAgent->new;
    my $resp = $ua->get($url);

    if ($resp->is_success) {
        my $decode_body =  $resp->decoded_content;
        if ( $decode_body =~ /<title>(.+)<\/title>/ ) { 
            my $title = "$rank_num. " . "$1"; 
            $title =~ s/\|.*//g;
            return $title;
        }
    }
    else {
        die $resp->status_line;
    }
}

1;

=pod

=head1 Name 

    Hubot::Scripts::advtop
 
=head1 SYNOPSIS

    advtop <year> - perl adventcalendar show popular 10 articles.

=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yunchang Kang.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself
 
=cut
