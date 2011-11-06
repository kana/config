package httpreq;

require 5.002;

# @(#)httpreq.pl -- Get a HTML document given a WWW URL
#
#     Copyright (c) 1997 by ISHINO Keiichiro <k16@chiba.email.ne.jp>.
#     All rights reserved.
#
# history:  0.10 Sep 18, 1997  First release.
#           0.11 Sep 19, 1997  Fixed small bug.
#           0.12 Oct 13, 1997  Returns redirected URL.
#           0.13 Sep 27, 1997  Used sysread, and timeout.
#           0.14 Oct 20, 1997  Fixed bug: redirection.
#           0.15 Mar 03, 1998  Max received size.
#           0.16 Mar 12, 1998  Split @http_noproxy.
#           0.17 Aug 31, 1998  Use \x0D\x0A in MIME header
#           0.18 Sep 06, 1998  Require Perl5 & :?(\d*) -> (?::(\d+))?
#                Jul 10, 1999  &jcode::convert(*x) -> &jcode::convert(\$x)
#           0.20 Jul 18, 1999  Use Jcode.pm
#           0.21 Jul 23, 1999  $version -> $VERSION
#           0.22 Aug 29, 1999  Get rid of $&, $' and $`
#           0.23 Oct 31, 2001  Accept: text/html
#           0.24 Nov 01, 2001  Host: $host
#           0.25 Jan 28, 2006  Accept: text/html, application/xhtml+xml, */*;q=0.1
$VERSION = '0.25';
#
# usage:
#   $httpreq::http_proxy = 'host:port';
#   @httpreq::http_noproxy = (noproxy domain names list);
#   $httpreq::user_agent = 'optional any string for agent name';
#   $httpreq::timeout = optional # of seconds for timeout (default is 180);
#   $httpreq::maxsize = optional max received size (defaut is unlimit).
#
#   &httpreq::get($url, $output, $jcode)
#   &httpreq::head($url)
#
#     $url     -  URL of http document.
#                   'http://host[:port]/path[?search-string][#fragment-id]'
#     $output  -  Optional output file ('-' means STDOUT) put HTML body into;
#                   always cr-only or cr-lf changes to lf.
#     $jcode   -  Optional Japanese code conversion method; euc, jis or sjis.
#
#   return ($status, $url, $header, $body)
#
#     $status   0  - URL is not http protocol.
#               1  - Can not open $output file.
#               2  - Can not get IP address.
#               3  - Can not connect to host.
#               4  - Time out.
#             2xx  - Success.
#             3xx  - Redirection (no return this status if 'GET' method).
#             4xx  - Client Error.
#             5xx  - Server Error.
#     $url     - Redirected URL.
#     $header  - HTTP/MIME header.
#     $body    - HTML body; return if 'GET' request and no $output specified.
#
# ex. $httpreq::http_proxy = 'firewall:8080';
#     @httpreq::http_noproxy = (localhost, inner);
#     $httpreq::timeout = 45.5;
#     &httpreq::head('http://www.uso800.ac.jp/~k16/index.html');
#     &httpreq::get('http://www.uso800.ac.jp/~k16/index.html', 'temp.html', 'euc');
#
# note: assume $[ == 0.
#              $* == 0.
#
# refer to: url_get  Jack Lund
#           webxref  Rick Jansen
#
# thanks for: miyaichi@vector.co.jp

$http_proxy = '';
@http_noproxy = ();
$user_agent = '';
$timeout = 180;
$maxsize = undef;

$httpreq = "httpreq.pl/$VERSION";

$AF_INET = 2;
$SOCK_STREAM = 1;
$SOCK_ADDR = 'S n a4 x8';
$handlename = 'httpreq0000';
#chomp($thishost = `hostname`);
#$thisaddr = $thishost =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/?
#            pack('C4', $1, $2, $3, $4): gethostbyname($thishost);

sub get($;$$) { return &httpreq::request('GET',  @_); }
sub head($)   { return &httpreq::request('HEAD', @_); }
sub request($$;$$)
{
  my($method, $url, $out, $jcode) = @_;
  $url =~ s/^\s*//o;
  $url =~ s/\s*$//o;
# $url =~ s/#.*$//o;   # Delete name anchor
# $url =~ s/\?.*$//o;  # Delete parameters
  my($server, $proto, $host, $port, $path) =
    ($url =~ m#^((\w+)://([\w\-\.]+)(?::(\d+))?)(.*)#);
  return 0 unless $proto =~ /^http$/oi;
  $port = 80 unless $port;
  unless ($path) {
    $path = '/';
    $url .= '/';
  }
  if ($http_proxy =~ /^\s*([\w\-\.]+):(\d+)/o) {
    my $proxy_host = $1;
    my $proxy_port = $2;
    foreach (@http_noproxy) {
      $proxy_host = '', last if /^$host$/i;
    }
    if ($proxy_host ne '') {
      $host = $proxy_host;
      $port = $proxy_port;
      $path = $url;
    }
  }
  $jcode =~ tr/A-Z/a-z/;
  if ($jcode =~ /^(euc|jis|sjis)$/o) {
    if ($Jcode = eval('require Jcode')) {
      *Jgetcode = \&Jcode::getcode;
      *Jconvert = \&Jcode::convert;
    } else {
      require 'jcode.pl';
      *Jgetcode = \&jcode::getcode;
      *Jconvert = sub { &jcode::to($_[1], $_[0], $_[2]); }
    }
  } else {
    $jcode = '';
  }

  my($hostaddr, $status, $header, $body, $rstat);
  if ($host =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/) {
    $hostaddr = pack('C4', $1, $2, $3, $4);
  } else {
    my(@temp) = gethostbyname($host);
    return 2 unless @temp;
    $hostaddr = $temp[4];
  }
  $proto = getprotobyname('tcp');
# $port  = getservbyname($port, 'tcp') unless $port =~ /^\d+$/;
  my $proc = pack($SOCK_ADDR, $AF_INET, $port, $hostaddr);
# my $this = pack($SOCK_ADDR, $AF_INET, 0,     $thisaddr);
  $CMD = $handlename++;
  my $notext = 0;
  my $length = 0;
  if (socket($CMD, $AF_INET, $SOCK_STREAM, $proto) &&
#     bind($CMD, $this) &&
      connect($CMD, $proc)) {
    select((select($CMD), $| = 1)[0]);
    my $ua = ($user_agent ne '')? $user_agent: $httpreq;
    print $CMD "$method $path HTTP/1.0\x0D\x0A",
               "Accept: text/html, application/xhtml+xml, */*;q=0.1\x0D\x0A",
               "Host: $host\x0D\x0A",
               "User-Agent: $ua\x0D\x0A",
               "\x0D\x0A";
    $telnetbuff{$CMD} = '';
    # read MIME header
    $header = '';
    while (($rstat = &httpreq::readline($CMD)) > 0) {
      last if /^\s*$/o;
      $status = (split(' ', $_))[1] if $header eq '';
      if ($status >= 200 && $status < 300) {
        if (/^Content-Type:\s*(.*)$/oi) {
          $notext = $1 !~ m#^text/#oi;
        } elsif (/^Content-Length:\s*(.*)$/oi) {
          $length = $1;
        }
      } elsif ($status >= 300 && $status < 400) {
        if (/^Location:\s*(.*)$/oi) {
          $path = $1;
          if ($method eq 'GET') {
            &httpreq::closesock($CMD);
            return &httpreq::request($method, $path, $out, $jcode);
          }
        }
      }
      $header .= $_;
    }
    if ($rstat < 0) {
      &httpreq::closesock($CMD);
      return 4;
    }
  } else {
    &httpreq::closesock($CMD);
    return 3;
  }
  $body = '';
  if ($status >= 200 && $status < 300) {
    if ($out ne '') {
      if ($out eq '-') {
        *OUT = *STDOUT;
      } elsif (!open(OUT, ">$out")) {
        &httpreq::closesock($CMD);
        return 1;
      }
      binmode(OUT);
      select((select(OUT), $| = 1)[0]);
    }
    # read the rest
    while (($rstat = &httpreq::readline($CMD, $notext)) >= 0) {
      &Jconvert($_, $jcode) if $jcode && !$notext;
      ($out ne '')? (print OUT): ($body .= $_);
      last if $rstat == 0;
    }
    $status = 4 if $rstat < 0;
    close(OUT) if $out ne '' && $out ne '-';
  }
  &httpreq::closesock($CMD);
  ($status, ($path =~ m#^/#)? $server.$path: $path, $header, $body);
}

sub closesock($)
{
  my($CMD) = @_;
  close($CMD);
  $telnetbuff{$CMD} = '';
}

# Read a line into $_.
# usage: &httpreq::readline($HANDLE, $notext)
# return:  1  -  success
#          0  -  eof
#         -1  -  timeout
sub readline($)
{
  my($CMD, $notext) = @_;
  my $stat = 1;
  if ($notext && $telnetbuff{$CMD}) {
    $_ = $telnetbuff{$CMD};
    $telnetbuff{$CMD} = '';
  } else {
    if ($notext || $telnetbuff{$CMD} !~ /\x0D\x0A?|\x0A/o) {
      my $endtime = $timeout? time+$timeout: undef;
      my $rin = '';
      vec($rin, fileno($CMD), 1) = 1;
      while () {
        my $timeleft = $endtime? $endtime-time: undef;
        $stat = -1, last if $endtime && $timeleft <= 0;
        my $rout;
        unless ((select($rout=$rin, undef, undef, $timeleft))[0]) {
          # time out
          $telnetbuff{$CMD} = '';
          return -1;
        }
        if (sysread($CMD, $_, 2048) <= 0) {
          # eof
          $stat = 0;
          return $stat if $notext;
          last;
        }
        return $stat if $notext;
        $telnetbuff{$CMD} .= $_;
        if ($maxsize && length($telnetbuff{$CMD}) >= $maxsize) {
          # size over
          $stat = 0;
          last;
        }
        last if /\x0D.|\x0A/o;
      }
    }
    if ($telnetbuff{$CMD} =~ /^([^\x0D\x0A]*)(?:\x0D\x0A?|\x0A)([\x00-\xFF]*)/o) {
      $_ = $1."\x0A";
      $telnetbuff{$CMD} = $2;
    } else {
      $_ = $telnetbuff{$CMD};
      $telnetbuff{$CMD} = '';
    }
  }
  $stat;
}

1;
