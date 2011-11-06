# RFC2396.pm - Syntax for URI (RFC2396/RFC2368/RFC2141/RFC1738/RFC822)
#
#    0.0  1998/10/03
#    0.1  1999/01/19
#    0.2  1999/03/04 RFC2368
#    0.3  1999/07/24 fixed(?) bug in mailto:
#    0.40 1999/08/28 tune up regex / use Exporter / expire parse_URI
#    0.41 1999/12/05 fixed(?) bug in URL_mailto
#    0.42 1999/12/12 use Email:Valid
#    0.43 2000/04/22 fixed bug in news:
#    0.44 2001/09/26 URN
#    0.45 2002/10/29 strict
#
# by ISHINO Keiichiro <k16@chiba.email.ne.jp>

package RFC2396;
require 5.002;
use strict;
use vars qw(@ISA @EXPORT $VERSION
            $URI_reference $URI_parsing $absoluteURI $relativeURI
            $URL_ftp
            $URL_file
            $URL_http
            $URL_gopher
            $URL_mailto $RFC822PAT
            $URL_news
            $URL_nntp
            $URL_telnet
            $URL_wais
            $URL_prospero
            $URL_urn
            );
use vars qw($scheme $fragment $delimunwise $spdelimunwise $hex2 $control);

BEGIN {
  use Exporter;
  @ISA    = qw(Exporter);
  @EXPORT = qw($URI_reference &URI_reference
               $URI_parsing
               $URL_ftp       &URL_ftp
               $URL_file      &URL_file
               $URL_http      &URL_http
               $URL_gopher    &URL_gopher
               $URL_mailto    &URL_mailto
               $URL_news      &URL_news
               $URL_nntp      &URL_nntp
               $URL_telnet    &URL_telnet
               $URL_wais      &URL_wais
               $URL_prospero  &URL_prospero
               $URL_urn       &URL_urn
               );
}

$VERSION = '0.45';

#my $lowalpha     = '[a-z]';
#my $upalpha      = '[A-Z]';
my $_digit        = '0-9';             # char class
my $_alpha        = 'A-Za-z';          # char class
my $_alphanum     = $_digit.$_alpha;   # char class
my $digit         = '['.$_digit.']';
my $alpha         = '['.$_alpha.']';
my $alphanum      = '['.$_alphanum.']';

my $hex           = '[0-9A-Fa-f]';
   $hex2          = $hex.$hex;
my $escaped       = '\%'.$hex2;

   $control       = '[^\x20-\x7E]';
my $_space        = '\x20';            # char class
my $_delim        = '<>#%"';           # char class
my $_unwise       = '{}|\x5C^\[\]`';   # char class
   $spdelimunwise = '['.$_space.$_delim.$_unwise.']';
   $delimunwise   = '['.$_delim.$_unwise.']';

my $_mark         = '\-_.!~*\'()';     # char class
my $_unreserved   = $_alphanum.$_mark; # char class
my $_reserved     = ';/?:@&=+$,';      # char class
my $uric          = '(?:['.$_unreserved.$_reserved.']|'.$escaped.')';
my $uric_no_slash = '(?:['.$_unreserved.';?:@&=+$,]|'.$escaped.')';

   $fragment      = $uric.'*';
my $query         = $uric.'*';

my $pchar         = '(?:['.$_unreserved.':@&=+$,]|'.$escaped.')';
my $param         = $pchar.'+';
my $segment       = '(?:'.$pchar.'+(?:;'.$param.')*|(?:;'.$param.')+)';
my $path_segments = $segment.'(?:/(?:'.$segment.')?)*';
my $rel_segment   = '(?:['.$_unreserved.';@&=+$,]|'.$escaped.')+';

my $IPv4part      = '(?:[01]?\d\d?|2[0-4]\d|25[0-5])';
my $IPv4address   = $IPv4part.'\.'.$IPv4part.'\.'.$IPv4part.'\.'.$IPv4part;
my $toplabel      = $alpha.'(?:['.$_alphanum.'\-]*'.$alphanum.')?';
my $domainlabel   = $alphanum.'(?:['.$_alphanum.'\-]*'.$alphanum.')?';
my $hostname      = '(?:'.$domainlabel.'\.)*(?:'.$toplabel.')\.?';
my $host          = $hostname.'|'.$IPv4address;
my $port          = $digit.'*';
my $hostport      = '(?:'.$host.')(?::'.$port.')?';

my $reg_name      = '(?:['.$_unreserved.';:@&=+$,]|'.$escaped.')+';
my $userinfo      = '(?:['.$_unreserved.';:&=+$,]|'.$escaped.')+';
my $server        = '(?:'.$userinfo.'\@)?'.$hostport;
my $authority     = '(?:'.$server.'|'.$reg_name.')';

   $scheme        = $alpha.'['.$_alphanum.'+\-.]*';

my $abs_path      = '/(?:'.$path_segments.')?';
my $net_path      = '//(?:'.$authority.'(?:'.$abs_path.')?|'.$abs_path.')';
my $rel_path      = $rel_segment.'(?:'.$abs_path.')?';

my $hier_part     = '(?:'.$net_path.'|'.$abs_path.')(?:\?'.$query.')?';
my $opaque_part   = $uric_no_slash.$uric.'*';

$absoluteURI   = '(?:'.$scheme.':(?:'.$hier_part.'|'.$opaque_part.'))';
$relativeURI   = '(?:'.$net_path.'|'.$abs_path.'|'.$rel_path.')(?:\?'.$query.')?';

$URI_reference = '(?:(?:'.$absoluteURI.'|'.$relativeURI.')(?:\#'.$fragment.')?|'.
                                                            '\#'.$fragment.')';
sub URI_reference { $_[0] =~ /^$URI_reference$/o; }

# RFC2396 Appendix B
$URI_parsing = '(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?';


##############

# FTP (see also RFC959)
my $ftptype       = '[AIDaid]';
my $fsegment      = '(?:['.$_unreserved.'?:@&=+$,]|'.$escaped.')*';
my $fpath         = $fsegment.'(?:/'.$fsegment.')*';
my $password      = $userinfo;
my $login         = '(?:'.$userinfo.'(?::'.$password.')?\@)?'.$hostport;
$URL_ftp       = 'ftp://'.$login.'(?:/'.$fpath.'(?:;type='.$ftptype.')?)?';
sub URL_ftp { $_[0] =~ /^$URL_ftp$/o; }

# FILE (see also RFC1738)
$URL_file      = 'file://(?:'. $host.'|localhost)?/'.$fpath;
sub URL_file { $_[0] =~ /^$URL_file$/o; }

# HTTP (see also RFC1738)
my $hsegment      = '(?:['.$_unreserved.';:@&=+$,]|'.$escaped.')*';
my $hpath         = $hsegment.'(?:/'.$hsegment.')*';
$URL_http      = 'https?://'.$hostport.'(?:/'.$hpath.'(?:\?'.$query.')?)?';
sub URL_http { $_[0] =~ /^$URL_http$/o; }

# GOPHER (see also RFC1436)
my $gopher_string = $uric.'*';
my $selector      = $uric.'*';
my $gtype         = $uric;
$URL_gopher    = 'gopher://'.$hostport.'(?:/(?:'.$gtype.'(?:'.$selector.
                 '(?:\t'.$query.'(?:\t'.$gopher_string.')?)?)?)?)?';
sub URL_gopher { $_[0] =~ /^$URL_gopher$/o; }

# MAILTO (see also RFC822/RFC2368)
my $_urlc         = $_unreserved.';/:@+$,'; # char class
my $urlc          = '(?:['.$_urlc.']|'.$escaped.')';
my $hname         = $urlc.'*';
my $hvalue        = $urlc.'*';
my $header        = $hname.'='.$hvalue;
my $headers       = '(\?'.$header.'(?:&'.$header.')*)?';
my $to            = '('.$urlc.'*)';
$URL_mailto    = 'mailto:'.$to.$headers;

# Regular expression built using Jeffrey Friedl's example in
# _Mastering Regular Expressions_ (http://www.ora.com/catalog/regexp/).
$RFC822PAT = <<'EOF';
[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\
xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xf
f\n\015()]*)*\)[\040\t]*)*(?:(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\x
ff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n\015
"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[\040\t]*(?:\([^\\\x80-\
xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80
-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*
)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\
\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\
x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x8
0-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|"[^\\\x80-\xff\n
\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[\040\t]*(?:\([^\\\x
80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^
\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040
\t]*)*)*@[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([
^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\
\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\
x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-
\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()
]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\
x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\04
0\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\
n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\
015()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?!
[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\
]]|\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\
x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\01
5()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*|(?:[^(\040)<>@,;:".
\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]
)|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[^
()<>@,;:".\\\[\]\x80-\xff\000-\010\012-\037]*(?:(?:\([^\\\x80-\xff\n\0
15()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][
^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)|"[^\\\x80-\xff\
n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015"]*)*")[^()<>@,;:".\\\[\]\
x80-\xff\000-\010\012-\037]*)*<[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?
:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-
\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:@[\040\t]*
(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015
()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()
]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\0
40)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\
[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\
xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*
)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80
-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x
80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t
]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\
\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])
*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x
80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80
-\xff\n\015()]*)*\)[\040\t]*)*)*(?:,[\040\t]*(?:\([^\\\x80-\xff\n\015(
)]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\
\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*@[\040\t
]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\0
15()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015
()]*)*\)[\040\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(
\040)<>@,;:".\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|
\\[^\x80-\xff])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80
-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()
]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x
80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^
\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040
\t]*)*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".
\\\[\]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff
])*\])[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\
\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x
80-\xff\n\015()]*)*\)[\040\t]*)*)*)*:[\040\t]*(?:\([^\\\x80-\xff\n\015
()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\
\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)?(?:[^
(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-
\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\xff\
n\015"]*)*")[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|
\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))
[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff
\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\x
ff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(
?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\
000-\037\x80-\xff])|"[^\\\x80-\xff\n\015"]*(?:\\[^\x80-\xff][^\\\x80-\
xff\n\015"]*)*")[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\x
ff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)
*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*)*@[\040\t]*(?:\([^\\\x80-\x
ff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-
\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)
*(?:[^(\040)<>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\
]\000-\037\x80-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\]
)[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-
\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\x
ff\n\015()]*)*\)[\040\t]*)*(?:\.[\040\t]*(?:\([^\\\x80-\xff\n\015()]*(
?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]*(?:\\[^\x80-\xff][^\\\x80
-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)*\)[\040\t]*)*(?:[^(\040)<
>@,;:".\\\[\]\000-\037\x80-\xff]+(?![^(\040)<>@,;:".\\\[\]\000-\037\x8
0-\xff])|\[(?:[^\\\x80-\xff\n\015\[\]]|\\[^\x80-\xff])*\])[\040\t]*(?:
\([^\\\x80-\xff\n\015()]*(?:(?:\\[^\x80-\xff]|\([^\\\x80-\xff\n\015()]
*(?:\\[^\x80-\xff][^\\\x80-\xff\n\015()]*)*\))[^\\\x80-\xff\n\015()]*)
*\)[\040\t]*)*)*>)
EOF
$RFC822PAT =~ s/\n//g;

sub URL_mailto {
  unless ($_[0] =~ /^$URL_mailto$/o) { return 0; }
  my ($to, $headers) = ($1, $2);
  if ($to eq '') { return $headers ne ''; }
  $to =~ s/\%($hex2)/chr(hex($1))/oge;
  $to =~ /^$RFC822PAT$/o;
}

# NEWS (see also RFC1036)
my $article       = '(?:['.$_unreserved.';/?:&=+$,]|'.$escaped.')+\@'.$host;
my $newsgroup     = '(?:'.$alpha.'['.$_alphanum.'\-.+_]*)';
my $grouppart     = '(?:\*|'.$newsgroup.'|'.$article.')';
$URL_news      = 'news:'.$grouppart;
sub URL_news { $_[0] =~ /^$URL_news$/o; }

# NNTP (see also RFC977)
$URL_nntp      = 'nntp://'.$hostport.'/'.$newsgroup.'(?:/'.$digit.'+)?';
sub URL_nntp { $_[0] =~ /^$URL_nntp$/o; }

# TELNET (see also RFC1738)
$URL_telnet    = 'telnet://'.$login.'/?';
sub URL_telnet { $_[0] =~ /^$URL_telnet$/o; }

# WAIS (see also RFC1625)
my $wpath         = '(?:['.$_unreserved.'+$,]|'.$escaped.')*';
my $wtype         = '(?:['.$_unreserved.'+$,]|'.$escaped.')*';
my $database      = '(?:['.$_unreserved.'+$,]|'.$escaped.')*';
my $waisdoc       = $database.'/'.$wtype.'/'.$wpath;
my $waisindex     = $database.'\?'.$query;
my $waisdatabase  = $database;
$URL_wais      = 'wais://'.$hostport.'/(?:'.$waisdatabase.'|'.$waisindex.'|'.$waisdoc.')';
sub URL_wais { $_[0] =~ /^$URL_wais$/o; }

# PROSPERO (see also RFC1738)
my $fieldvalue    = '(?:['.$_unreserved.'?:@&+$,]|'.$escaped.')*';
my $fieldname     = '(?:['.$_unreserved.'?:@&+$,]|'.$escaped.')*';
my $fieldspec     = ';'.$fieldname.'='.$fieldvalue;
my $psegment      = '(?:['.$_unreserved.'?:@&=+$,]|'.$escaped.')*';
my $ppath         = $psegment.'(?:/'.$psegment.')*';
$URL_prospero  = 'prospero://'.$hostport.'/'.$ppath.'(?:'.$fieldspec.')*';
sub URL_prospero { $_[0] =~ /^$URL_prospero$/o; }

# URN (see also RFC2141)
my $nid           = $alphanum.'['.$_alphanum.'\-]{0,31}';
my $nss           = '(?:['.$_alphanum.'()+,\-.:=@;$_!*\']|'.$escaped.')+';
$URL_urn       = 'urn:'.$nid.':'.$nss;
sub URL_urn { $_[0] =~ /^$URL_urn$/o; }

1;
