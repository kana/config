#!/usr/local/bin/perl
# CGI script for Another HTML-lint gateway
require 5.004;
$VERSION = '1.28';
$PROGNAME = 'Another HTML-lint';
=ignore
use strict;
use vars qw($VERSION $PROGNAME);
use vars qw($RULEDIR $LOGSDIR $TMPDIR $IMGDIR $TAGSLIST $HTMLDIR $GATEWAYURL $EXPLAIN $CGIROOT $IMGROOT $HTMLLINTRC $HTMLEXT $INDEXHTML @REJECTREFERER @EXCEPTDOMAINS @PERMITDOMAINS $PERMITPRIVATEIP $NOUSELWP $NOUSEJCODE $MAXHTMLSIZE $TIMEOUT $HTTP_PROXY @HTTP_NOPROXY $GETLOCALFILE $KANJICODE $LYNX $W3M $SCOREFILE $SCORECOUNTER $STATFILE @EXCEPTSCORES $COUNTER $NOCOMMERCIAL $AUTOSCORE);
use vars qw($HTML $LOCALFILE $URL $RURL @OPT $RESULT $TXTCODE $STYLE $SCRIPT $RULE $FILE $PIPE $WARNS $SCORE $KIND $TAGS $STAT $LANG $outCODE $CHARSET $CTYPE $MIME $TextView $LWPUA $URLGETVer);
use vars qw(%in $stdio %doctypes $defaultrule %whines $icode $counter $err %warn %whinesStat %seenTagsStat %seenTagsKind %seenMultiBody %statistics %statSeenTags %statKindTags %statMultiBody $statstart $statsample $seensample);
=cut

my $myADDRESS = 'k16@chiba.email.ne.jp';
my $version = <<EndOfVersion;
  Another HTML-lint gateway script ver$VERSION
    Copyright (c) 1997-2009 by ISHINO Keiichiro <$myADDRESS>.
    All rights reserved.
EndOfVersion

use File::Basename;
use File::Find;
my $CGI_NAME = &basename($0);
my $LINT_NAME = 'htmllint.pm';

my $WIN = $^O =~ /Win32/oi;
my $MAC = $^O =~ /MacOS/oi;
my $OS2; #UNSUPPORTED;
my $UNIX = !($WIN || $MAC || $OS2);

require 'htmllint.env';
require $LINT_NAME;

if ($ENV{QUERY_STRING} eq '' && @ARGV) {
 # No CGI
 my $arg = shift;
 if ($arg eq '-vv') {
  print "$CGI_NAME $VERSION / $LINT_NAME $htmllint::VERSION";
 } else {
  print $version;
 }
 exit;
}

require 'common.rul';
use CGI;
$CGI::POST_MAX = $MAXHTMLSIZE*1024 if $MAXHTMLSIZE > 0;
my $CGIVer = "CGI $CGI::VERSION";
my $cgi = new CGI;
my ($Jcode, $JcodeVer);
if ($Jcode = (!$NOUSEJCODE && eval('require Jcode'))) {
 $JcodeVer = "Jcode $Jcode::VERSION";
 *Jgetcode = \&Jcode::getcode;
 *Jconvert = \&Jcode::convert;
} else {
 require 'jcode.pl';
 $JcodeVer = "jcode.pl $jcode::version";
 *Jgetcode = \&jcode::getcode;
 *Jconvert = sub { &jcode::to($_[1], $_[0], $_[2]); };
}

my $acceptMIME = 'text\/html|application\/xhtml\+xml';
my $msgCantLint = '申し訳ありません。ただいま調整中です。もうしばらくしてから再チェックしてください。';
my $msgInURL   = '指定されたURL (';
my $msgNoHTML  = ') は HTML ではありません。';
my $msgBadResp = ') は HTTPレスポンスヘッダに問題があります。';
my $msgInHTML  = '指定されたHTML (';
my $msgInFile  = '指定されたファイル (';
my $msgCantGet = ') を取得することができませんでした。';
my $msgNoData  = '入力されたデータはありませんでした。';
my $msgNoFile  = 'ファイル名が指定されていません。';
my $msgCannotMkdir = ' を作成できませんでした。';
my $myCODE = &Jgetcode(\$msgCantLint); # euc または sjis
my $bannerCommercial = $NOCOMMERCIAL? '': '';
my $addinfo = defined(&AddInfo);
&ShortName;

# 出力する漢字コードの選択
&DetectCode($cgi->param('CharCode')) or &DetectCode($KANJICODE) or &DetectCode('JIS');
$| = 1;

# ビジーチェック
if (defined(&BusyCheck)) {
 my $msg = &BusyCheck;
 &ErrorExit($msg) if $msg;
}
END { # シグナルでの終了時は来ない
  &EndProc if defined(&EndProc);
}

$URL = $RURL = ($cgi->param('Method') =~ /^(?:Data|File)$/oi)? '': &htmllint::AbsoluteURL($ENV{HTTP_REFERER}, $cgi->param('URL'));

# チェックオプションを得る
&GetOptions;
push @OPT, '-banner', '-score', '-w', 'long';
#push @OPT, '-r', $RULEDIR if $RULEDIR;

unless (-e $TMPDIR || mkdir $TMPDIR, 0777) {
 &ErrorExit($TMPDIR.$msgCannotMkdir);
}
if ($LOGSDIR ne '') {
 unless (-e $LOGSDIR || mkdir $LOGSDIR, 0777) {
  &ErrorExit($LOGSDIR.$msgCannotMkdir);
 }
} else {
 $SCOREFILE = $SCORECOUNTER = $STATFILE = '';
}

# HTMLをローカルに得る
$HTML = $TMPDIR.'htmllint'.$$.'.html';
if ($UNIX) {
 $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'TERM'} = $SIG{'PIPE'} = sub {
  &Unlink;
  &Exit;
 }
}
if ($URL ne '') {
 if ($GETLOCALFILE) {
  if ($URL =~ m#^file:///?(.*)#oi) {
   ($LOCALFILE = $1) =~ s/^(\w)\|(.*)/$1:$2/o;
  } elsif ($WIN && $URL =~ /^\w:/o) {
   $LOCALFILE = $URL;
  }
 }
 if (defined($LOCALFILE)) {
  # ローカルファイルを取得
  $HTML = $RURL = $LOCALFILE;
  if ($MAC) {
   $HTML =~ s#/#:#og;
   $HTML = ($HTML =~ m#^:(.*)#)? $1: ':'.$HTML;
  }
  # %XXのデコードを行なう
  $HTML =~ s/\%([0-9A-Fa-f][0-9A-Fa-f])/pack('C', hex($1))/oge;
 } else {
  my ($scheme, $host, $port, $path, $file) = &htmllint::ParseURL($URL);
  unless ($scheme =~ /^http/i) {
     &ErrorExit($msgInURL.&HrefURL($URL).$msgCantGet);
  }
  $host = $1 if $host =~ /\@(.+)$/;
  unless ($PERMITPRIVATEIP) {
   # Private IP か調べる
   &ErrorExit($msgInHTML.&HrefURL($URL).$msgCantGet) if !CheckPrivateIP($ENV{REMOTE_ADDR}) && CheckPrivateIP($host);
  }
  if (@REJECTREFERER) {
   # 拒否REFERER
   my $ref = (&htmllint::ParseURL($ENV{HTTP_REFERER}))[1];
   foreach (@REJECTREFERER) {
    if (&CheckDomain($ref, $_)) {
     &ErrorExit($msgInHTML.&HrefURL($URL).$msgCantGet);
    }
   }
  }
  if (@EXCEPTDOMAINS) {
   # 除外ドメインのチェック
   my $ok = 1;
   foreach (@EXCEPTDOMAINS) {
    if (&CheckDomain($host, $_)) {
     $ok = 0;
     foreach (@PERMITDOMAINS) {
      if (&CheckDomain($host, $_)) {
       $ok = 1; # 非除外
       last;
      }
     }
     last;
    }
   }
   &ErrorExit($msgInHTML.&HrefURL($URL).$msgCantGet) unless $ok;
  }
  if (@EXCEPTSCORES) {
   # 得点記録除外ドメインのチェック
   foreach (@EXCEPTSCORES) {
    if (&CheckDomain($host, $_)) {
     $SCOREFILE = $STATFILE = '';
     last;
    }
   }
  }
  { # 20100811
    $path .= $file;
    $path =~ s/\%([0-9A-F][0-9A-F])/chr(hex($1))/gei;
    if ($path =~ /<script\b/i) {
      # XSSアタックの疑い
      &ErrorExit($msgInHTML.&HrefURL($URL).$msgCantGet);
    }
  }
  # HTMLを読み込んで改行を変換してテンポラリに書く
  if (!$NOUSELWP &&
    eval('require LWP::UserAgent') && eval('require HTTP::Request')) {
   $URLGETVer = "LWP $LWP::VERSION";
   $LWPUA = new LWP::UserAgent;
   my $uagent = "Another_HTML-lint/$VERSION +".$LWPUA->agent;
   $LWPUA->agent($uagent);
   $LWPUA->timeout($TIMEOUT) if $TIMEOUT > 0;
   $LWPUA->max_size($MAXHTMLSIZE*1024) if $MAXHTMLSIZE > 0;
   $LWPUA->proxy('http', "http://$HTTP_PROXY/") if $HTTP_PROXY;
   $LWPUA->no_proxy(@HTTP_NOPROXY) if @HTTP_NOPROXY;
   $LWPUA->parse_head(0);
   my $req = new HTTP::Request GET => $URL;
#  $req->header('Accept' => 'text/html, application/xhtml+xml, */*;q=0.1');
   $req->header('Accept' => 'text/html, application/xhtml+xml');	# 20090427
   if ($host =~ m#^//(.+)#o) { $req->header('Host' => $1); }
   my $res = $LWPUA->request($req, $HTML);
   $RESULT = $res->status_line()."\n".$res->headers_as_string();
   if ($res->is_success()) {
    $RURL = $res->request->url();
    my $warning = $res->header('Client-Warning');
    if ($warning ne '') {
     &Unlink;
     $warning = qq|(<code>$warning</code>)|;
     &ErrorExit($msgInURL.&HrefURL($URL).$msgBadResp.$warning);
    }
    $CTYPE = $res->header('Content-Type');
    unless ($CTYPE =~ m#\b($acceptMIME)\b#oi) {
     &Unlink;
     $CTYPE = qq|(<code>$CTYPE</code>)| if $CTYPE ne '';
     &ErrorExit($msgInURL.&HrefURL($URL).$msgNoHTML.$CTYPE);
    }
    $MIME = $1;
    ($CTYPE) = $CTYPE =~ /charset\s*=\s*([^\s;,]+)/oi;
    $LANG = $res->header('Content-Language');
    $STYLE = $res->header('Content-Style-Type');
    $SCRIPT = $res->header('Content-Script-Type');
   } else {
    ($STAT = "\n".$res->status_line()) =~ s/\s*\(\@INC contains:.+//o;
    &Unlink;
   }
  } elsif (eval("require 'httpreq.pl'")) {
   $URLGETVer = "httpreq.pl $httpreq::VERSION";
   $httpreq::http_proxy = $HTTP_PROXY if $HTTP_PROXY;
   $httpreq::user_agent = "Another_HTML-lint/$VERSION +$httpreq::httpreq";
   $httpreq::timeout = $TIMEOUT if $TIMEOUT > 0;
   $httpreq::maxsize = $MAXHTMLSIZE*1024 if $MAXHTMLSIZE > 0;
   $httpreq::http_proxy = $HTTP_PROXY if $HTTP_PROXY;
   @httpreq::http_noproxy = @HTTP_NOPROXY if @HTTP_NOPROXY;
   ($STAT, $RURL, $RESULT) = &httpreq::get($URL, $HTML);
   if ($STAT >= 200 && $STAT < 300) {
    ($CTYPE) = $RESULT =~ /Content-Type:\s*([^\r\n]+)/oi;
    unless ($CTYPE =~ m#\b($acceptMIME)\b#oi) {
     &Unlink;
     &ErrorExit($msgInURL.&HrefURL($URL)."$msgNoHTML(<code>$CTYPE</code>)");
    }
    $MIME = $1;
    ($CTYPE) = $CTYPE =~ /charset\s*=\s*([^\s;,]+)/oi;
    ($LANG) = $RESULT =~ /Content-Language:\s*([^\s\r\n]+)/oi;
    ($STYLE) = $RESULT =~ /Content-Style-Type:\s*([^\s\r\n]+)/oi;
    ($SCRIPT) = $RESULT =~ /Content-Script-Type:\s*([^\s\r\n]+)/oi;
   } else {
    &Unlink;
   }
  }
  if ($CTYPE ne '') {
   push @OPT, '-charset', $CTYPE;
   $CTYPE = ($Jcode && lc($CTYPE) eq 'utf-8')? 'utf8': undef;
  }
  push @OPT, '-mime', $MIME if $MIME ne '';
  push @OPT, '-lang', $LANG if $LANG ne '';
  push @OPT, '-style', $STYLE if $STYLE ne '';
  push @OPT, '-script', $SCRIPT if $SCRIPT ne '';
  push @OPT, '-nolo', '-base', $URL;
 }
 push @OPT, '-usec';
} else {
 if ($cgi->param('Method') =~ /^File$/oi) {
  # ファイルアップロード
  $FILE = $cgi->param('File');
  if ($FILE eq '') { &ErrorExit($msgNoFile); }
  $HTML = $cgi->tmpFileName($FILE);
  close($FILE);
  push @OPT, '-usec';
 } else {
  # TEXTEREAの内容をテンポラリに書く
  open(HTML, ">$HTML");
  print HTML $cgi->param('Data');
  close(HTML);
  push @OPT, '-ignc';
 }
}
push @OPT, '-stat', $STATFILE if $STATFILE && $cgi->param('Stat');

if (!(-e $HTML) || (-z $HTML)) {
 # テンポラリファイルがうまくできていない
 my $japURL = (&Jgetcode(\$URL) =~ /^(jis|euc|sjis)$/)? 'URLに日本語などのASCII以外の文字を使うことはできません。': '';
 &Unlink;
 &EscapeRef(\$STAT);
 &EscapeRef(\$FILE);
 &ErrorExit(($URL ne '')? $msgInHTML.&HrefURL($URL).$msgCantGet.$japURL.$STAT: ($FILE ne '')? $msgInFile.$FILE.$msgCantGet: $msgNoData);
}

$TextView = lc($cgi->param('LynxView')? 'lynx': $cgi->param('TextView'));
$TextView = '' if $TextView ne 'lynx' && $TextView ne 'w3m';
if ($TextView ne 'lynx' || $MAC) { $LYNX = ''; } else { $LYNX =~ s/^\s+//o; }
if ($TextView ne 'w3m'  || $MAC) { $W3M  = ''; } else { $W3M  =~ s/^\s+//o; }
if (!$cgi->param('NoCheck') || ($LYNX eq '' && $W3M eq '')) {
 push @OPT, '--', $HTML;
 # 結果用PIPEファイルを作る
 $PIPE = $TMPDIR.'htmllint'.$$.'.result';
 open(PIPE, ">$PIPE");
 my $oldfh = select PIPE;
 # さあ行け！
 &htmllint::HTMLlint(@OPT);
 &DetectCode($TXTCODE)
  if $cgi->param('CharCode') eq '' || uc($cgi->param('CharCode')) eq 'AUTO';
 select $oldfh;
 # 結果を読み込む
 my $header;
 my $footer;
 #close(PIPE);
 open(PIPE, "<$PIPE");
 my @line;
 while (<PIPE>) {
  local $RESULT;
  chomp($RESULT = $_);
  &EscapeRef(\$RESULT);
  if ($RESULT =~ /^\d+: /o) {
   push(@line, $RESULT);
  } else {
   if ($header) { $footer = $RESULT; } else { $header = $RESULT; }
  }
 }
 close(PIPE);
 unlink($PIPE);
 ($WARNS) = $footer =~ /^(\d+)/o;
 ($SCORE) = $footer =~ / (-?\d+)(.*)/o;
 ($KIND, $TAGS) = $2 =~ / (\d+)\D+ (\d+)/o;
 ($RULE) = $header =~ /\Qを\E (.+) \Qとして\E/o;
 if ($RULE eq '' || $SCORE eq '') {
  &Unlink;
  &ErrorExit("$msgCantLint<br>$header");
 }
 $counter = $SCOREFILE? &LogScore: 0;
 # 結果の表示
 my ($img, $alt) = (!$WARNS && $SCORE >= 100)? ('verygood', 'たいへんよくできました'):
                              ($SCORE >=  80)? ('good',     'よくできました'):
                              ($SCORE >=  35)? ('normal',   'ふつうです'):
                                               ('fight',    'がんばりましょう');
 $img .= '.gif';
 if ($cgi->param('Image') ne '') {
  &Unlink;
  if ($AUTOSCORE) {
   if ($COUNTER && uc($cgi->param('Image')) eq 'SCORE') {
    $SCORE = sprintf("%0$in{'md'}d", $SCORE) if $cgi->param('md');
    my $query = "lit=$SCORE";
    foreach ('dd', 'tr', 'pad', 'ft', 'frgb', 'trgb', 'srgb', 'prgb', 'chcolor', 'negate', 'degrees', 'rotate') {
     $query .= "&$_=".$cgi->param($_) if $cgi->param($_);
    }
    $ENV{QUERY_STRING} = $query;
#   $ENV{HTTP_REFERER} = $ENV{REMOTE_ADDR};
    $ENV{HTTP_REFERER} = 'http://'.$ENV{HTTP_HOST}.$ENV{HTTP_URI};
    $ENV{REQUEST_METHOD} = 'GET';
    exec $COUNTER;
   } else {
    $img = $IMGDIR.'ahl-'.$img;
    if (open(IMG, "<$img")) {
     binmode(IMG);
     my $len = -s IMG;
     my $buff;
     sysread(IMG, $buff, $len);
     close(IMG);
     print qq|Content-type: image/gif\n|, qq|Content-length: $len\n\n|, $buff;
    }
   }
  }
 } else {
  &PrintHTMLHeader("Check result of $PROGNAME");
  if (defined(&AddInfo2)) { &Jprint(&AddInfo2); }
# my $useimage = $ENV{HTTP_ACCEPT} =~ m#image/gif#o;
  my $useimage = 1;
  if ($addinfo) { print q|<table align="right"><tr><td>| }
  if ($useimage) {
   print qq|<a href="https://sw.vector.co.jp/swreg/step1.info?srno=SR011941&amp;site=v&amp;sid=335404740" class="image"><img src="$IMGROOT$img" alt="$alt" width="68" height="68" border="0"|;
   print qq| align="right"| if (!$addinfo);
   print qq|></a>|;
  }
  if ($addinfo) {
   print q|</td></tr><tr><td style="padding-top:1em">|;
   &Jprint(&AddInfo($SCORE));
   print q|</td></tr></table>|;
  }
  $footer =~ s#(\Q＼(^o^)／\E)#<code>$1</code>#o;
  print('<h2>');
  &Jprint('チェックの結果は以下のとおりです。');
  print("</h2>\n");
  print("<p>\n");
  if ($FILE ne '') {
   &EscapeRef(\$FILE);
   &Jprint($FILE.' を ');
  } elsif ($URL ne '') {
   &Jprint(&HrefURL($URL).' を ');
  }
  &Jprint($RULE.' としてチェックしました。'."<br>\n", ($TAGS ne '0')?
      "$footer<br>\n": 'タグのひとつもないHTMLは採点できません。'."<br>\n");
  if (!$Jcode && $cgi->param('CharCode') =~ /^UTF8$/oi) {
   &Jprint("<br>\n".'このサーバではUTF-8は扱えません。');
  }
  if ($LYNX ne '' || $W3M ne '') {
   &Jprint(qq|<br>\n<a href="#${TextView}View">${TextView}|.'での見え方はこちら</a>にあります。');
  }
  print("</p>\n");
  &PrintHTTPHeader;
  my $gray = '#666666';
  if (@line) {
   my $br = '';
   my $tar = $cgi->param('OtherWindow')? ' target="explain"': '';
   &Jprint('<p>先頭の数字はエラーのおおまかな重要度を 0〜9 で示しています(減点数ではありません)。少ない数字は軽く、9 になるほど致命的です。');
   foreach (@line) {
    /^(\d+): ([^:]+):\s*(.*)/o;
    my $id = $2;
    unless ($whines{$id}) {
     if ($SCORE >= 0) {
      &Jprint('0 は減点対象外のごく軽度のエラーで '.qq|<span class="slight-error">|.'(グレイのかっこつき)</span> でメッセージされています。');
     } else {
      &Jprint('<strong>このHTMLには重要な問題が多く含まれています</strong>。環境によっては閲覧できない可能性が非常に高いと言えます。減点対象外のごく軽度のエラーは割愛されています。');
     }
     last;
    }
   }
   print("</p><p>\n");
   foreach (sort { $a <=> $b } @line) {
    /^(\d+): ([^:]+):\s*(.*)/o;
    my $n = $1;
    my $id = $2;
    $warn{$n}++;
    if ($SCORE > 0 || $whines{$id}) {
     my $body = &PrintableCtrlCharacter($3);
     print("<br>\n") if $br++;
     print("$whines{$id}: ");
     print($cgi->param('ViewSource')? qq|<a href="#$n">line $n</a>: |: qq|line $n: |);
     if ($whines{$id}) {
      &Jprint($body);
     } else {
      print(qq|<span class="slight-error">(|);
      &Jprint($body);
      print(q|)</span>|);
     }
     $n = ${$htmllint::messages{$id}}[1];
     unless (defined($n)) {
      $id = $htmllint::alias_messages{$id};
      $n = ${$htmllint::messages{$id}}[1];
     }
     &Jprint(' → '.qq|<a href="$EXPLAIN#$id"$tar>|.'解説'." $n</a>");
    }
   }
   print("</p>\n");
  }
  # print(qq|<br clear="all">\n|) if $useimage;

  if ($cgi->param('ViewSource')) {
   &Jprint('<hr><h2>チェックしたHTMLは以下のとおりです。'."</h2>\n");
   if ($RURL ne '' || $LYNX ne '' || $W3M ne '') {
    print('<p>');
    &Jprint(&HrefURL($RURL)) if $RURL ne '';
    if ($LYNX ne '' || $W3M ne '') {
     &Jprint(qq| → <a href="#${TextView}View">${TextView}での見え方はこちら</a>|);
    }
    print("</p>\n");
   }
   print("<ol>\n");
   open(HTML, $HTML);
   local $/ = &DetectSeparator;
   my $ln = 0;
   while ($RESULT = <HTML>) {
    $ln = $.;
    $RESULT =~ s/\s+$//g;
    &ConvertAndEscape($TXTCODE);
    $RESULT =~ s/  |\t/&nbsp;&nbsp;/og;
#   ($RESULT = &PrintableCtrlCharacter($RESULT)) =~ s/  |\t/&nbsp;&nbsp;/og;
    print('<li>');
    if ($warn{$ln}) {
     print(qq|<code><a name="$ln"><span class="error-line">|, $RESULT, q|</span></a></code>|);
    } elsif ($RESULT ne '') {
     print('<code>', $RESULT, '</code>');
    }
    print("</li>\n");
   }
   $ln++;
   print(qq|<li><a name="$ln"><span class="slight-error">[EOF]</span></a>\n|)
    if $warn{$ln};
   print("</ol>\n");
   close(HTML);
  }

  if ($TextView) {
   print('<hr>');
   my $view;
   if ($LYNX ne '') {
    $view = &LynxView; # Lynx も見たければ実行する
   } elsif ($W3M ne '') {
    $view = &W3mView; # w3m も見たければ実行する
   }
   &Jprint('<h2>このサーバでは', $TextView, 'はサポートされていません。</h2>'."\n") if !$view;
  }
  &Unlink;
  &PrintHTMLFooter(1);
 }
} else {
 &PrintHTMLHeader("$TextView View by $PROGNAME");
 if ($LYNX ne '') {
  &LynxView; # Lynx の表示だけ見る
 } elsif ($W3M ne '') {
  &W3mView; # w3m の表示だけ見る
 }
 &Unlink;
 &PrintHTMLFooter(0);
}
&Exit;

sub PrintHTTPHeader
{
 if ($URL ne '' && $cgi->param('HTTPHeader')) {
  print('<blockquote>');
  if ($RESULT ne '') {
   #$RESULT .= "\n\n".join(' ',@OPT); for DEBUG
   $RESULT =~ s/(\r?\n)+$//o;
   &ConvertAndEscape($CTYPE);
   print('<pre>', $RESULT, '</pre>');
  } else {
   &Jprint('このサーバの設定ではHTTPヘッダを得られません。');
  }
  print("</blockquote>\n");
 }
}

sub LynxView
{
 &TextView($LYNX, '-dump -nolist -force_html');
}
sub W3mView
{
 my $opt = '-dump -T text/html -M '.(($myCODE eq 'euc')? '-e': '-s');
 &TextView($W3M, $opt);
}
sub TextView
{
 my $opt;
 my ($prog, $defopt) = @_;
 if ($prog =~ /^(\S+)\s+(.*)/o) {
  $prog = $1;
  $opt = $2;
 }
 my $ver;
 if ($TextView eq 'lynx') {
  $ver = `$prog -version`;
  $ver =~ s#\n#<br>\n#og;
  $ver =~ s# (http:\S+) # <a href="$1">$1</a> #og;
  return 0 if $ver eq '';
 }
 $opt = $defopt if $opt eq '';
 $RESULT = `$prog $opt $HTML`;
 &ConvertAndEscape(&Jgetcode(\$RESULT));
 &Jprint(qq|<h2><a name="${TextView}View">$TextView|, 'での見え方は以下のとおりです。</a>');
 print(qq|</h2>\n<div class="lynx"><pre class="lynx">\n|, $RESULT, "</pre></div>\n");
 print(q|<blockquote><hr class="none">|, $ver, "</blockquote>\n") if $ver;
 1;
}

sub Jprint
{
 foreach (@_) { print &Jconvert($_, $outCODE, $myCODE); }
}

sub DetectSeparator
{
 my $sep = "\n";
 my $buff;
 read(HTML, $buff, 1024);
 if ($buff !~ /\x0D\x0A/o) {
  $sep = "\x0A" if $buff =~ /\x0A/o;
  $sep = "\x0D" if $buff =~ /\x0D/o;
 }
 seek(HTML, 0, 0);
 $sep;
}

sub DetectCode
{
 my $ccode = uc(shift);
 if ($ccode eq 'EUC') {
  $outCODE = 'euc';
  $CHARSET = 'EUC-JP';
 } elsif ($ccode eq 'SJIS') {
  $outCODE = 'sjis';
  $CHARSET = 'Shift_JIS';
 } elsif ($ccode eq 'JIS') {
  $outCODE = 'jis';
  $CHARSET = 'ISO-2022-JP';
 } elsif ($Jcode && $ccode eq 'UTF8') {
  $outCODE = 'utf8';
  $CHARSET = 'UTF-8';
 } else {
  return 0;
 }
 1;
}

# テンポラリファイルを消す
sub Unlink
{
 unlink($HTML) if !defined($LOCALFILE);
}

# IPを得る
sub GetIP
{
 my $host = shift;
 $host =~ s#^//##o;
 my @ip;
 if ($host =~ m#^(\d+)\.(\d+)\.(\d+)\.(\d+)$#) {
  @ip = ($1,$2,$3,$4);
 } else {
  my (@addr) = (gethostbyname($host))[4];
  @ip = unpack('C4', $addr[0]);
 }
 ((((($ip[0]<<8)+$ip[1])<<8)+$ip[2])<<8)+$ip[3];
}

# Private IP か調べる
sub CheckPrivateIP
{
 my $host = shift;
 if ($host =~ m#^(?://)?(\d+)\.(\d+)\.(\d+)\.(\d+)$#) {
  # RFC1918に示されるのは以下
  # 10.0.0.0〜10.255.255.255
  # 172.16.0.0〜172.31.255.255
  # 192.168.0.0〜192.168.255.255
  ($1==10) || ($1==172 && $2>=16 && $2<32) || ($1==192 && $2==168) ||
  ($1==127 && $2==0 && $3==0); # 127.0.0.*
 } else { 0 }
}

# ドメイン名が指定のものか調べる
sub CheckDomain
{
 my ($host, $domain) = @_;
 if ($domain =~ m#^(\d+\.\d+\.\d+\.\d+)(?:/(\d+))?(?:([*!])(.+))?$#) {
  my $rule  = $4;
  my $cond  = $3;
  my $mask  = $2;
  my $domip = &GetIP($1);
  my $hostip = &GetIP($host);
  return 0 if $rule && $cond eq (&CheckDomain($ENV{REMOTE_ADDR}, $rule)? '!': '*');
  if (defined($mask)) {
   $mask = ~((1<<(32-$mask))-1);
  } else {
   $mask = ~0;
   foreach (0xFFFFFFFF, 0xFFFFFF, 0xFFFF, 0xFF) {
    unless ($domip & $_) {
     $mask = ~$_;
     last;
    }
   }
  }
  return 1 if ($hostip & $mask) == ($domip & $mask);
 } else {
  $domain =~ s/\./\\\./og;
  if ($host =~ m#(^//|\.)$domain$#) {
   return 1; # 指定ドメイン名で終わるホスト
  }
 }
 0;
}

# URLへのリンク参照を求める
sub HrefURL
{
 my $url = shift;
 &EscapeRef(\$url);
 $url =~ m#^\w+://#o? qq|<a href="$url">$url</a>|: $url;
}

# URL が存在するか調べステータスを返す (http のみ)
# 戻り値は (stat, url, content-type, content-length, msg) の配列
sub AskHTML
{
 my $stat = 200;
 my ($rurl, $type, $length, $header, $msg);
 my $TIMEOUT = $cgi->param('TimeOut')+0;
 if ($TIMEOUT > 0.0) {
  $TIMEOUT = 60 if $TIMEOUT > 60.0;
  my $url = &htmllint::AbsoluteURL;
  if ($LWPUA) {
   $LWPUA->timeout($TIMEOUT);
   my $req = new HTTP::Request HEAD => $url;
   my $res = $LWPUA->request($req);
   $stat = $res->code();
   if ($cgi->param('CheckGET') && $stat >= 400) {
    $req = new HTTP::Request GET => $url;
    $res = $LWPUA->request($req);
    $stat = $res->code();
   }
   $rurl = $res->request->url();
   $type = $res->header('Content-Type');
   $length = $res->header('Content-Length');
   $msg = $res->message();
   $msg =~s /,\s*<HTML> chunk \d+.+$//;
  } else {
   $httpreq::timeout = $TIMEOUT;
   ($stat, $rurl, $header) = &httpreq::head($url);
   if ($cgi->param('CheckGET') && $stat >= 400) {
    ($stat, $rurl, $header) = &httpreq::get($url);
   }
   ($header =~ /(?:^|\n)Content-Type:\s*(.+)\n/omi)   and $type = $1;
   ($header =~ /(?:^|\n)Content-Length:\s*(.+)\n/omi) and $length = $1;
  }
 }
 [$stat, $rurl, $type, $length, $msg];
}

# コード変換して実体参照にエスケープする
sub ConvertAndEscape
{
 $icode = shift;
 if ($outCODE eq 'jis') {
  &Jconvert(\$RESULT, $myCODE, $icode);
  &EscapeRef(\$RESULT);
  &Jconvert(\$RESULT, $outCODE, $myCODE);
 } else {
  &Jconvert(\$RESULT, $outCODE, $icode);
  &EscapeRef(\$RESULT);
 }
}

# 実体参照にエスケープする
sub EscapeRef
{
 my $str = shift;
 $$str =~ s/&/&amp;/og;
 $$str =~ s/</&lt;/og;
 $$str =~ s/>/&gt;/og;
 $$str =~ s/"/&quot;/og;
 $$str =~ s/\n/<br>/og;
}

# 制御文字を印字可能に変換する
sub PrintableCtrlCharacter
{
 my $str = shift;
 $str =~ s#([\x00-\x08\x0B\x0C\x0E-\x1F])#'<i>^'.pack('C',unpack('C',$1)+0x40).'</i>'#eog;
 $str;
}

# エラー出力して終了する
sub ErrorExit
{
 my (@msgs) = @_;
 &PrintHTMLHeader("$PROGNAME error!");
 &Jprint(qq|<h2>$PROGNAME error!</h2>\n|);
 while (@msgs) {
  print('<p>');
  &Jprint(shift(@msgs));
  print("</p>\n");
 }
 &PrintHTTPHeader if $RESULT ne '';
 &PrintHTMLFooter(0);
 &Exit;
}

sub Exit
{
 # 消されていないテンポラリの始末をする
 &find(\&CleanupTmp, $TMPDIR? $TMPDIR: '.');
 exit;
}

sub CleanupTmp
{
 if (-d) {
  $File::Find::prune = 1 if $_ ne '.';
 } elsif (/^htmllint-?\d+\.(html|result)$/o && (stat($_))[9] < time-24*60*60) {
  # 24時間以前のファイルを消す
  unlink($_);
 }
}

# HTML ヘッダ部分を出力する (PrintHeaderという関数は cgi-lib に既存)
sub PrintHTMLHeader {
 my ($title) = @_;
 my $brclear = $bannerCommercial? '<br clear="all">': '';
 print(qq|Content-Type: text/html; charset=$CHARSET\x0D\x0A\x0D\x0A|);
 &Jprint(<<EndOfHTMLHeader);
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="ja"><head>
<meta http-equiv="Content-Type" content="text/html; charset=$CHARSET">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<meta name="keywords" content="lint,バリデータ,HTML文法,HTML検証,最適化,SEO">
<meta name="author" content="ISHINO Keiichiro">
<link rel="stylesheet" type="text/css" href="${HTMLDIR}htmllint.css">
<link rel="contents" href="${HTMLDIR}index.html">
<title>$title</title>
</head>
<body>
<div align="center" class="nav">$bannerCommercial
[<a href="${HTMLDIR}index.html">about</a>]
[<a href="${HTMLDIR}sitemap.html">sitemap</a>]
[<a href="${HTMLDIR}htmllint.html">gateway</a>]
[<a href="${HTMLDIR}htmllintl.html">lite</a>]
[<a href="${HTMLDIR}htmllinte.html">dyn</a>]$brclear
</div><hr>
EndOfHTMLHeader
}

# HTMLフッタ部分を出力する
sub PrintHTMLFooter
{
 my $cntstr;
 if (shift) {
  $cntstr = ($counter? "-- #$counter": '').' -- cost '.(time - $^T).' sec';
  #$cntstr .= " -- $LOCKCNT" if $LOCKCNT > 0;
  $cntstr .= ' --<br>';
 }
 $JcodeVer .= ' NoXS' if $Jcode && defined($Jcode::Unicode::NoXS::VERSION);
 my $vers = join(' / ', $CGIVer, $JcodeVer);
 $vers = join(' / ', $URLGETVer, $vers) if $URLGETVer;
 print(<<EndOfHTMLFooter);
<hr><div align="center">
<address>${cntstr}This page was generated by $CGI_NAME $VERSION / $LINT_NAME $htmllint::VERSION<br>
$vers<br>
1997-2009 \&#xA9; by <!--a href="mailto:k16\@chiba.email.ne.jp"-->k16\@chiba.email.ne.jp<!--/a--></address></div>
<hr><div align="center" class="nav">$bannerCommercial
[<a href="${HTMLDIR}index.html">about</a>]
[<a href="${HTMLDIR}sitemap.html">sitemap</a>]
[<a href="${HTMLDIR}htmllint.html">gateway</a>]
[<a href="${HTMLDIR}htmllintl.html">lite</a>]
[<a href="${HTMLDIR}htmllinte.html">dyn</a>]
</div>
</body></html>
EndOfHTMLFooter
}

# 得点の記録
sub LogScore
{
 my $rule = $RULE;
 foreach (keys(%doctypes)) {
  if (${$doctypes{$_}}{'guide'} eq $rule) {
   $rule = $_;
   last;
  }
 }
 my $cnt = 0;
 my $file = $SCOREFILE;
 my $url = ($FILE or $URL);
 $url =~ s/ /%20/og;
 $url = '<TEXTAREA>' if $url eq '';
 my ($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
 my $post = sprintf('%04d%02d', 1900+$year, 1+$mon);
 $file =~ s/#/$post/g;
 my $existfile = -e $file;
 if (open(LOGF, ($existfile? '>>': '>').$file)) {
  flock(LOGF, 2) if $UNIX;
  if ($SCORECOUNTER) {
   open(CNTF, $SCORECOUNTER);
   $cnt = <CNTF>+1;
   if (open(CNTF, ">$SCORECOUNTER")) {
    print CNTF "$cnt\n";
   }
   close(CNTF);
   chmod 0766, $SCORECOUNTER;
  }
  $WARNS = 0 unless $WARNS;
  my $rhost = ($ENV{REMOTE_HOST} or $ENV{REMOTE_ADDR});
  print LOGF sprintf('%04d/%02d/%02d %02d:%02d:%02d', 1900+$year, 1+$mon, $mday, $hour, $min, $sec),
   " $rhost $url ", ($TAGS ne '0')? "$SCORE/$WARNS/$TAGS/$KIND": "//$TAGS/$KIND", " $rule\n";
# flock(LOGF, 8) if $UNIX;
  close(LOGF);
  chmod 0766, $file;
 }
 $cnt;
}

# 警告情報を収集する (htmllint.pm が呼ぶ)
sub PushStat
{
 my $name = shift;
 push(@{'stat'.$name}, shift);
}

# 警告の統計を取る (htmllint.pm が呼ぶ)
sub TakeStatistics
{
 my $stat = shift;
 if ($stat ne '') {
  local ($statstart, $statsample, $seensample, *STAT);
  my @lt = localtime;
  my $suffix = sprintf('%04d%02d', $lt[5]+1900, $lt[4]+1);
  $stat =~ s/#/$suffix/g;
  if ($stat ne $stdio) {
   if (-e $stat) {
    open(STAT, "+<$stat") || return;
    flock(STAT, 2) if $UNIX;
    # 排他制御が起こったときSTATの内容は古いのでもう一度オープンし直す
    open(STAT, "+<$stat") || return;
    flock(STAT, 2) if $UNIX;
    local $err = 0;
    local $SIG{__WARN__} = sub { $err++; }; # 次の do のエラーをトラップ
    do $stat;
    if (!defined($statstart) && !$err) {
     # 何らかの理由で読み込みに失敗した ($stat が破損しているときは修復する)
#    flock(STAT, 8) if $UNIX;
     close(STAT);
     return;
    }
    seek(STAT, 0, 0);
   } else {
    open(STAT, ">$stat") || return;
    flock(STAT, 2) if $UNIX;
   }
  } else {
   *STAT = *STDOUT;
  }
  foreach (keys(%whinesStat)) { $statistics{$_} += $whinesStat{$_}; }
  undef %whinesStat;
  foreach (keys(%seenTagsStat)) { $statSeenTags{$_} += $seenTagsStat{$_}; }
  undef %seenTagsStat;
  foreach (keys(%seenTagsKind)) { $statKindTags{$_} += $seenTagsKind{$_}; }
  undef %seenTagsKind;
  foreach (keys(%seenMultiBody)) { $statMultiBody{$_} += $seenMultiBody{$_}; }
  undef %seenMultiBody;
  my $statcurrent = sprintf('%4d/%02d/%02d %02d:%02d:%02d',
   $lt[5]+1900, $lt[4]+1, $lt[3], $lt[2], $lt[1], $lt[0]);
  my $statstart = $statcurrent unless defined($statstart);
  print STAT
   '$statstart   = \'', $statstart,   "';\n",
   '$statcurrent = \'', $statcurrent, "';\n",
   '$statsample = ',  ++$statsample,   ";\n",
   '$seensample = ',  ++$seensample,   ";\n";
  &PrintStatArray('statistics',
   'statOnceOnly',
   'statOnceOnlyGroup',
   'statUnclosedElement',
   'statExcludedElement',
   'statOmitEndTag',
   'statDeprecatedElement',
   'statDeprecatedTag',
   'statDeprecatedAttr',
   'statMustFollow',
   'statEmptyContainer',
   'statIllegalClosing',
   'statRequired',
   'statRequiredAttr',
   'statRequiredValue',
   'statUnknownElement',
   'statUnknownAttribute',
   'statUnexpectedPCDATA',
   'statOmitAttributeName',
   'statMinimizedAttribute',
   'statHereAnchor',
   'statNoRegCharset',
   'statNoTextHtml',
   'statUnknownProtocol',
   'statBadJISX0208',
   'statExcludedURLRef',
   'statSeenTags',
   'statKindTags',
   'statMultiBody');
  if ($stat ne $stdio) {
   truncate(STAT, tell(STAT));
#  flock(STAT, 8) if $UNIX;
   close(STAT);
   chmod 0766, $stat;
  }
 }
}

sub PrintStatArray
{
 foreach my $name (@_) {
  my $esc;
  if ($name ne 'statistics') {
   foreach (@$name) { $$name{$_}++; }
   undef @$name;
  }
  if (%$name) {
   print STAT "\%$name = (\n";
   foreach (sort {$$name{$b} <=> $$name{$a} || $a cmp $b} keys(%$name)) {
    $esc = $_;
    $esc =~ s/[\x00-\x1F]/ /og; # 暫定
    $esc =~ s/\\/\\\\/og;
    $esc =~ s/'/\\'/og;
    print STAT "  '$esc' => $$name{$_},\n";
   }
   print STAT ");\n";
  }
  undef %$name;
 }
}

# 短縮問い合わせデータの調整
sub ShortName
{
 foreach (split(/[&;]/, $cgi->param('keywords'))) {
  $cgi->param(-name=>$_, -value=>'on');
 }
 foreach ($cgi->param) {
  next if /^(?:URL|Data|File|TimeOut)$/oi;
  $cgi->param(-name=>$_, -value=>'on') if $cgi->param($_) eq '';
 }
 my %shortNames = (
  Method          => 'M',
  CharCode        => 'C',
  NoWarnings      => 'N',
  ViewSource      => 'V',
  LynxView        => 'L',
  TextView        => 'X',
  OtherWindow     => 'O',
  IgnoreDOCTYPE   => 'I',
  HTMLVersion     => 'H',
  Pedantic        => 'P',
  NoReligious     => 'R',
  NoAccessibility => 'A',
  TimeOut         => 'T',
  Enable          => 'E',
  Disable         => 'D',
 );
 foreach (keys(%shortNames)) {
  $cgi->param(-name=>$_, -value=>$cgi->param($shortNames{$_})) if !defined($cgi->param($_));
 }
}

# チェックオプションを得る
sub GetOptions
{
 my $x = $defaultrule;
 foreach (keys(%doctypes)) {
  if ($cgi->param('HTMLVersion') =~ /^(${$doctypes{$_}}{'name'})$/i) { $x = $_; last; }
 }
 push @OPT, '-x', $x,
  $cgi->param('IgnoreDOCTYPE')?   '-ignd':  '-used',
  $cgi->param('NoWarnings')?      '-nowar': '-war',
  $cgi->param('NoReligious')?     '-norel': '-rel',
  $cgi->param('NoAccessibility')? '-noacc': '-acc';
 push @OPT, '-limit', $cgi->param('LimitWhines') if $cgi->param('LimitWhines') > 0;
 my (@warnings, @enable, @disable);
 &htmllint::ListWarnings(\@warnings);
 foreach (@warnings) {
  if (/^(\S+)\s+(\S+)\s+(ENABLED|DISABLED)\s+(\S+)(?:\s+(\S+)\s+(\S+))?/) {
   my ($id, $sh, $ed, $n, $swa, $wna) = ($1, $2, $3, $4, $5, $6);
   $whines{$id} = int($n+0.9);
   $whines{$id} = 9 if $whines{$id} > 9;
   $whines{$swa} = int($wna+0.9) if $swa;
   next if $id eq 'over-limit-whines';
   $sh = $id if $sh eq '-';
   if ($cgi->param($id)) { push(@enable, $sh) if $ed =~ /^D/o; }
   else { push(@disable, $sh) if $ed =~ /^E/o; }
  }
 }
 if ($cgi->param('Pedantic')) {
  push @OPT, '-ped';
 } else {
  push @OPT, '-noped';
  if ($cgi->param('CheckList')) {
   push @OPT, '-e', join(',', @enable)  if @enable;
   push @OPT, '-d', join(',', @disable) if @disable;
  } else {
   push @OPT, '-e', $cgi->param('Enable')  if $cgi->param('Enable')  ne '';
   push @OPT, '-d', $cgi->param('Disable') if $cgi->param('Disable') ne '';
  }
 }
}
