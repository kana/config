# Another HTML-lint ###########################################

eval(q|require 'htmllint.env'|);
eval(q|require 'common.rul'|);

package htmllint;

=ignore
use strict;
use vars qw($htmlfile @htmlfiles $curcwd $ext $prune);
use vars qw($rule $HTML $line $ungetl $token $reacheof $readsize $fromfile
            $textcode $jcharcode $charset $xcharset $bom
            @ucase @lcase @xcase @ucaseln @lcaseln @xcaseln $pretab
            $xmldecl $seenXml $seenHtml, $metaLang,
            $lang $tagscnt $whinescnt $pwhinescnt $upenalty $penalty $maxpnt
            $tagsNestWhine @tagsNest @inclNest @exclNest $nonAsciiEarly
            $omit_html $p_isnot_br $appElem $lastTag $contBRs %seenAllTags
            $seenCharset $metaCharset $baseURL @refreshHTML %iddef %idref $ahref
            %hrefAnchors %seenAnchors %seenAnchorsU %seenAnchorsID %seenAnchorsIN
            %mapAnchors %seenMapAnchors %seenMapAnchorsU %seenMapAnchorsID
            %seenFrameName $seenRelURL $headElements @ijams @istas @ilets @iswfs @irsts
            @tableInfos @tableInfo $tableCell %linkText %linkInfo %alt $bgcolor
            $multibody $bodyline @seenLabels @seenLabel @ctrlLabels @ctrlLabel
            @seenSelect @selOption $selOptions $seenPre @seenObjects @seenObject
            @headingLevel $headingStart %formNames $needprchar
            $nestULOL $cntLI $nestOBJECT $cntPARAM
            $isohtml $xhtml $xml $xmlns @xmlns @markedSection $procdoctype);
use vars qw($allTags $emptyTags $pairTags $deprecatedTags $omitStartTags $omitEndTags
            $maybeEmpty %requiredTags %onceonlyTags $sequencialTags
            %tagsElements %excludedElems %includedElems $noOmitEtag
            %deprecatedElems %deprecatedAttrs %deprecatedAttrsCss %deprecatedVals
            %tagsAttributes %requiredAttrs $disabled
            %refEntities %refParams %indexhtml %stathtml);
use vars qw($nameChr $nameStr $idStr $tokenStr $nutokenStr %tokenizedType);
use vars qw($opt_pedantic $opt_banner $opt_echoname
            $opt_score $opt_scorenowhines $opt_scoreonly
            $opt_religious $opt_accessibility $opt_warnings $opt_prune $opt_base
            $opt_igndoctype $opt_igncharset $opt_lc $opt_limit $opt_omit $opt_mime
            $opt_lang $opt_charset $opt_style $opt_script $opt_local $opt_linklist
            $opt_after $opt_w $opt_f $opt_x $opt_stat $opt_dbg);
use vars qw($cnf_style $cnf_html $cnf_limit $cnf_omit
            %cnf_e %opt_e $opt_r $opt_listwarnings $opt_u $opt_v $opt_version $opt_help);
use vars qw($analizing $pcdata
            $TAG $oTAG $atag $minetag %seenTags %seenAttrs %seenAttrsOrg $unknownTag
            $ATTR $oATTR $subATTR $value $ahref $quot);
use vars qw($lastPairTag $lastOmitTag @innerTags @seq $seqid $thisTagElements);
use vars qw($stdio $htmlVer %colorTable $ruledir $rulefile
            %messages %alias_messages %religious %accessibility %shortid %enabled
            %uniquewhine %pairTags %emptyTags %attributes);
use vars qw($charsets $usascii %japanesesets %escapeseq);
use vars qw($VERSION);
=cut

my ($PROGRAM, $PROGDIR);
my ($WIN, $MAC, $UNIX);
my ($SEP, $version);

BEGIN {     require 5.002;  # JPerl では動作しません

$VERSION = '3.46';

my $myADDRESS = 'k16@chiba.email.ne.jp';

$version = <<EndOfVersion;
  Another HTML-lint ver$VERSION
    Copyright (c) 1997-2007 by ISHINO Keiichiro <$myADDRESS>.
    All rights reserved.
EndOfVersion

$WIN = $^O =~ /Win32/i;
$MAC = $^O =~ /MacOS/i;
my $OS2; #UNSUPPORTED;
$UNIX = !($WIN || $MAC || $OS2);

$SEP = '/';
if ($WIN) {
  ($PROGRAM = $0) =~ s#\\#/#g; # 日本語ファイル名不可
  $PROGRAM =~ m#^([A-Za-z]:)?(.*)#;
  $PROGDIR = $1;
  $2 =~ m#^(.*?)([^/]+)$#;
  $PROGRAM = $2;
  $PROGDIR .= ($1 eq '')? '.': $1;
} elsif ($MAC) {
  ($PROGDIR, $PROGRAM) = $0 =~ m#^(.*?)([^:]+)$#;
  $SEP = ':';
} else {
  $PROGRAM = $0;
  my $LINK;
  while ($LINK = readlink($PROGRAM)) {
    if ($LINK =~ m#^/#) {
      $PROGRAM = $LINK;
    } else {
      $PROGRAM =~ m#^(.*?)[^/]+$#;
      $PROGRAM = $1.$LINK;
    }
    $PROGRAM = &NormalizeDots($PROGRAM);
  }
  ($PROGDIR, $PROGRAM) = $PROGRAM =~ m#^(.*?)([^/]+)$#;
  $PROGDIR = '.' if $PROGDIR eq '';
}
$PROGDIR .= $SEP if $PROGDIR !~ m#$SEP$#o;
unshift @::INC, $PROGDIR;
$stdio = "\tstdio\t";

sub HTMLlint(@);
sub ListWarnings(;\@);

} # End of BEGIN

use Time::Local;
use Getopt::Long;
   $Getopt::Long::autoabbrev = 1;
use Cwd;
use File::Find;
require RFC2396;
my $Jcode;
if (!$::NOUSEJCODE && eval('require Jcode')) {
  $Jcode = $Jcode::VERSION;
  *Jgetcode = \&Jcode::getcode;
  *Jconvert = \&Jcode::convert;
} else {
  $Jcode = 0;
  require 'jcode.pl';
  *Jgetcode = \&jcode::getcode;
  *Jconvert = \&jcode::convert;
}

my $usage = <<EndOfUsage . <<'EndOfOptions';
  usage: perl5 $PROGRAM options file.html...
EndOfUsage
  options: (*=default)
    -d <warn>     : 指定された警告を無効にする。(各警告はコンマで区切る)
    -e <warn>     : 指定された警告を有効にする。(各警告はコンマで区切る)
    -f <file>     : 設定ファイル(htmllintrc)を指定する。
    -pedantic     : すべての警告を有効にする。(このとき -d -e の指定無効)
    -nopedantic   : すべての警告を有効にすることはしない。
    -religious    : 宗教的な警告を有効にする。
    -noreligious  : 宗教的な警告を無効にする。
    -accessibility   : アクセス性向上に関する警告を有効にする。
    -noaccessibility : アクセス性向上に関する警告を無効にする。
    -banner       : 処理開始と終了メッセージを表示する。
    -nobanner     : 処理開始と終了メッセージを表示しない。
    -echoname     : チェックする HTML ファイル名を標準エラー出力する。
    -noechoname   : チェックする HTML ファイル名を標準エラー出力しない。
    -score        : チェックした HTML の点数を表示する。
    -scorenowhines: チェックした HTML の点数を警告ありのときのみ表示する。
    -scoreonly    : チェックした HTML の点数のみを表示する。
    -noscore      : チェックした HTML の点数を表示しない。
    -prune        : ディレクトリ指定のとき下位ディレクトリを探さない。
    -noprune      : ディレクトリ指定のとき下位ディレクトリを探す。
    -warnings     : チェックによる警告を表示する。
    -nowarnings   : チェックだけして何も警告を表示しない。
    -linklist     : HTML に含まれるリンク先を表示する。
    -nolinklist   : HTML に含まれるリンク先を表示しない。
    -lc           : 警告中の要素名や属性名を小文字で表示する。XHTMLは無効。
    -uc           : 警告中の要素名や属性名を大文字で表示する。XHTMLは無効。
    -listwarnings : サポートされているすべての警告を表示する。
    -w <style>    : 警告メッセージのスタイルを指定する。
                     <style> = lint     file(#): warning-message
                             = short    #: warning-message
                             = long     #: warning-id: warning-message
                             = terse    file:#:warning-id
                             = verbose  file: #: warning-id: warning-message
    -limit <n>    : 警告の打ち切り個数を指定する。
    -omit <n>     : 無減点同一警告の打ち切り数を指定する。
    -x <html>     : 指定された HTML ヴァージョンでチェックする。
                     <html> = html10
                            = html20 | RFC1866
                            = html2x | RFC2070 | i18n
                            = html+ | htmlplus
                            = html30 | arena
                            = html32 | wilbur
                            = html40 | html40s | html40-strict
                            = html40t | html40-transitional
                            = html40f | html40-frameset
                            = html40m | html40-mobile
                            = html401 | html401s | html401-strict
                            = html401t | html401-transitional
                            = html401f | html401-frameset
                            = xhtml1 | xhtml1s | xhtml1-strict
                            = xhtml1t | xhtml1-transitional
                            = xhtml1f | xhtml1-frameset
                            = xhtml11
                            = xhtmlb
                            = xhtmlmp
                            = 15445 | iso-html
                            = 15445p | 15445-preparation | iso-html-preparation
                            = mozilla20
                            = mozilla30
                            = mozilla40 | navigator | netscape
                            = ie30b | msie30b
                            = ie30 | msie30
                            = ie40 | msie40
                            = ie50 | msie50
                            = ie55 | msie55 | microsoft
                            = webexp
                            = compact-html | compact
                            = imode10
                            = imode20
                            = imode30
                            = imode40
                            = imode-xhtml | ixhtml
                            = imode-xhtml11 | ixhtml11
                            = jskyweb
                            = jskystation
                            = doti10
                            = jpo
                    大文字小文字の区別なし。
    -igndoctype   : HTML 中の DOCTYPE 宣言を無視する。
    -usedoctype   : HTML 中の DOCTYPE 宣言を無視しない。
    -igncharset   : CHARSET の指定とコードの一致性を無視する。
    -usecharset   : CHARSET の指定とコードの一致性を無視しない。
    -local        : HTML 中のローカルファイルの参照を許可する。
    -nolocal      : HTML 中のローカルファイルの参照を禁止する。
    -after <date> : 指定日以降のファイルのみチェックする。
                     <date> = YYYY-MM-DD-hh-mm-ss (区切りは任意、途中までで可)
                            = @file (このファイルのタイムスタンプを基準)
    -r <dir>      : 規則ファイルのディレクトリを指定する。
                    指定がなければ htmllint と同じ場所とみなされる。
    -v | -version : ヴァージョンを表示する。
    -u | -help    : このメッセージを表示する。
  return: 何もエラーがなければエラーステータス 0 で終了する。
EndOfOptions

my $myCODE = &Jgetcode(\$usage); # euc または sjis

$::HTMLLINTRC = '.htmllintrc'          unless defined($::HTMLLINTRC);
$::HTMLEXT    = 'html?|[sp]ht(ml?)?'   unless defined($::HTMLEXT);
$::INDEXHTML  = "index\\.($::HTMLEXT)" unless defined($::INDEXHTML);

my $stdNameChr  = '[A-Za-z0-9\.\-]';
my $stdTokenStr = $stdNameChr.'+';
#  $nameStr     = '[A-Za-z]'.$stdNameChr.'*';
my $allc     = '[\x00-\xFF]';
my $digits   = '\d+';
my $charData = '(?=[CNIE])(?:CDATA|NUMBER|NAME|NMTOKEN|NUTOKEN'.
               '|NUMBERS|NAMES|NMTOKENS|NUTOKENS|ID|IDREF|IDREFS|ENTITY'.
               '|CDATA\+)'; # 空にできない CDATA
my $internalElem = '#\d+';
my $unsafeuri   = '~';
my $nameSep     = '/';  # $nameChr に含まれないもの
my %URLcollection = ();
my $stylescript = '(?:STYLE|SCRIPT)';

my %TagAttrCheckers = (
  'BASE'.  $nameSep.'HREF'     => \&CheckTagAttrBASE_HREF,
  'FRAME'. $nameSep.'NAME'     => \&CheckTagAttrFRAME_NAME,
  'FRAME'. $nameSep.'SRC'      => \&CheckTagAttrFRAME_SRC,
  'A'.     $nameSep.'HREF'     => \&CheckTagAttrA_HREF,
  'A'.     $nameSep.'IJAM'     => \&CheckTagAttrA_IJAM,
  'A'.     $nameSep.'ISTA'     => \&CheckTagAttrA_ISTA,
  'A'.     $nameSep.'ILET'     => \&CheckTagAttrA_ILET,
  'A'.     $nameSep.'ISWF'     => \&CheckTagAttrA_ISWF,
  'A'.     $nameSep.'IRST'     => \&CheckTagAttrA_IRST,
  'A'.     $nameSep.'CTI'      => \&CheckTagAttrA_CTI,
  'A'.     $nameSep.'KANA'     => \&CheckTagAttrA_KANA,
  'A'.     $nameSep.'EMAIL'    => \&CheckTagAttrA_EMAIL,
  'IMG'.   $nameSep.'ALT'      => \&CheckTagAttrIMG_ALT,
  'IMG'.   $nameSep.'USEMAP'   => \&CheckTagAttrIMG_USEMAP,
  'IMG'.   $nameSep.'ISMAP'    => \&CheckTagAttrIMG_ISMAP,
  'IMG'.   $nameSep.'MOTION'   => \&CheckTagAttrIMG_MOTION,
  'OBJECT'.$nameSep.'TITLE'    => \&CheckTagAttrOBJECT_TITLE,
  'OPTION'.$nameSep.'SELECTED' => \&CheckTagAttrOPTION_SELECTED,
  'FONT'.  $nameSep.'COLOR'    => \&CheckTagAttrFONT_COLOR,
);
my %AttrCheckers = (
  CLASS      => \&CheckAttrCLASS,
  LANG       => \&CheckAttrLANG,
  'XML:LANG' => \&CheckAttrXMLLANG,
  ALT        => \&CheckAttrALT,
  ISMAP      => \&CheckAttrISMAP,
  TARGET     => \&CheckAttrTARGET,
  STYLE      => \&CheckAttrSTYLE,
  TABINDEX   => \&CheckAttrTABINDEX,
  DISABLED   => \&CheckAttrDISABLED,
);
my %TagCheckers = (
  HTML     => \&CheckTagHTML,
  BODY     => \&CheckTagBODY,
  LINK     => \&CheckTagLINK,
  META     => \&CheckTagMETA,
  SCRIPT   => \&CheckTagSCRIPT,
  STYLE    => \&CheckTagSTYLE,
  OL       => \&CheckTagOLUL,
  UL       => \&CheckTagOLUL,
  LI       => \&CheckTagLI,
  DD       => \&CheckTagDD,
  A        => \&CheckTagA,
  MAP      => \&CheckTagMAP,
  LABEL    => \&CheckTagLABEL,
  SELECT   => \&CheckTagSELECT,
  OPTION   => \&CheckTagOPTION,
  INPUT    => \&CheckTagINPUT,
  BUTTON   => \&CheckTagBUTTON,
  TEXTAREA => \&CheckTagTEXTAREA,
# TABLE    => \&CheckTagTABLE,
  COL      => \&CheckTagCOL,
  TR       => \&CheckTagTR,
  TH       => \&CheckTagTHTD,
  TD       => \&CheckTagTHTD,
  BR       => \&CheckTagBR,
  PRE      => \&CheckTagPRE,
  IMG      => \&CheckTagIMG,
  APPLET   => \&CheckTagAPPLET,
  OBJECT   => \&CheckTagOBJECT,
  PARAM    => \&CheckTagPARAM,
  XML      => \&CheckTagXML,
);
my %TagClosing = (
  HTML     => \&CloseTagHTML,
  PRE      => \&CloseTagPRE,
  FORM     => \&CloseTagFORM,
  SELECT   => \&CloseTagSELECT,
  LABEL    => \&CloseTagLABEL,
  HEAD     => \&CloseTagHEAD,
  OBJECT   => \&CloseTagOBJECT,
  APPLET   => \&CloseTagOBJECT,
  OL       => \&CloseTagOLUL,
  UL       => \&CloseTagOLUL,
);

##################################################
# 入り口

sub HTMLlint(@)
{
  local @ARGV = @_;
  local ($opt_pedantic, $opt_banner, $opt_echoname,
         $opt_score, $opt_scorenowhines, $opt_scoreonly,
         $opt_religious, $opt_accessibility, $opt_warnings, $opt_prune, $opt_base,
         $opt_igndoctype, $opt_igncharset, $opt_lc, $opt_limit, $opt_omit, $opt_mime,
         $opt_lang, $opt_charset, $opt_style, $opt_script, $opt_local, $opt_linklist,
         $opt_after, $opt_w, $opt_f, $opt_x, $opt_stat, $opt_dbg);
  return if &ReadOptions();
  &ReadRule('charsets.rul');
  &ReadRule('colortable.rul');
  &ReadTagsSet();

  if ($myCODE eq 'sjis') {
    # 日本語の含まれる正規表現用文字列をエスケープする
    my $esc = 0;
    my $escStr = '';
    foreach (unpack('C*', $::hereAnchorsJ)) {
      $esc = 2 if $esc <= 0 && ((0x0081 <= $_ && $_ <= 0x009F) ||
                                (0x00E0 <= $_ && $_ <= 0x00FC));
      $escStr .= ($esc-- <= 0)? chr: sprintf('\\x%02X', $_);
    }
    $::hereAnchorsJ = $escStr; # 二重エスケープ注意
  }

  my $exit_status;
  while (@ARGV > 0) {
    local @htmlfiles;
    $_ = shift(@ARGV);
    if ($_ eq $stdio) {
      *HTML = *STDIN;
      &Lint('');
      &::TakeStatistics($opt_stat) if $opt_stat;
    } else {
      local $curcwd = &currentdir;
      if (-d) {
        local $ext = '\.('.$::HTMLEXT.')';
        &find(\&HTMLwanted, $_);
      } else {
        /(.*?[$SEP])?([^$SEP]+)$/o;
        my $dir = $1;
        local $ext = $2;
        if ($ext =~ /[*?]/) {
          $ext =~ s/([.^()\$@%+])/\\$1/g;
          $ext =~ s/\*/.*/g;
          $ext =~ s/\?/./g;
          &find(\&HTMLwanted, ($dir eq '')? '.': $dir);
        } else {
          push(@htmlfiles, $_);
        }
      }
      foreach (@htmlfiles) {
        if (open(HTML, "<$_")) {
          if ($opt_after && [stat HTML]->[9] <= $opt_after) { next; }
          binmode HTML if $WIN;
          $exit_status = 1 if &Lint($_);
          close(HTML);
          &::TakeStatistics($opt_stat) if $opt_stat;
        } else {
          warn "Can't open `$_`.\n";
        }
      }
    }
  }
  $exit_status;
}

sub currentdir
{
  my $dir = &Cwd::getcwd().$SEP;
  $dir =~ s/$SEP$SEP$/$SEP/e;
  $dir;
}

sub HTMLwanted
{
  if (-d) {
    $File::Find::prune = 1 if $opt_prune && $_ ne '.' && $_ ne '..';
  } elsif (/$ext$/i) {
    my $name = &currentdir.$_;
    if (substr($name, 0, length($curcwd)) eq $curcwd) {
      $name = substr($name, length($curcwd));
    }
    push(@htmlfiles, $name);
  }
}

sub DetectSeparator
{
  my $buff;
  read(HTML, $buff, 1024);
  my $top = 0;
  if ($buff =~ /^(\xEF\xBB\xBF|\xFF\xFE(?:\x00\x00)?|(?:\x00\x00)?\xFE\xFF)/) {
    # BOM
    $bom = $1;
    $top = length($bom);
    #$buff = substr($buff, $top);
    &Whine(0, 'bom');
  }
  my $sep = "\n";
  if ($buff !~ /\x0D\x0A/) {
    $sep = "\x0A" if $buff =~ /\x0A/;
    $sep = "\x0D" if $buff =~ /\x0D/;
  }
  seek(HTML, $top, 0);
  $sep;
}

sub DetectEncoding
{
  my $buff = shift;
  my ($code, $nmatch);
  if ($Jcode) {
    ($code, $nmatch) = &Jgetcode($buff);
  } else {
    ($nmatch, $code) = &Jgetcode($buff);
  }
  if ($code =~ /^(?:jis|euc|sjis|utf8)$/) {
    return $code if $code =~ /^(?:jis)$/ or $nmatch >= 8;
  }
  undef;
}

##################################################
# HTML を読んで解析する

  sub xc { ($opt_lc || $xhtml)? lc(shift): shift; }
  sub xetag { ($opt_lc || $xhtml)? ' />': '>'; }

sub Lint
{
  undef %::whinesStat;
  local ($htmlfile) = @_;
  local ($rule, $HTML, $line, $ungetl, $token, $reacheof, $readsize, $fromfile,
         $textcode, $jcharcode, $charset, $xcharset, $bom,
         @ucase, @lcase, @xcase, @ucaseln, @lcaseln, @xcaseln, $pretab,
         $xmldecl, $seenXml, $seenHtml, $metaLang,
         $lang, $tagscnt, $whinescnt, $pwhinescnt, $upenalty, $penalty, $maxpnt,
         $tagsNestWhine, @tagsNest, @inclNest, @exclNest, $nonAsciiEarly,
         $omit_html, $p_isnot_br, $appElem, $lastTag, $contBRs, %seenAllTags,
         $seenCharset, $metaCharset, $baseURL, @refreshHTML, %iddef, %idref, $ahref,
         %hrefAnchors, %seenAnchors, %seenAnchorsU, %seenAnchorsID, %seenAnchorsIN,
         %mapAnchors, %seenMapAnchors, %seenMapAnchorsU, %seenMapAnchorsID,
         %seenFrameName, $seenRelURL, $headElements, @ijams, @istas, @ilets, @iswfs, @irsts,
         @tableInfos, @tableInfo, $tableCell, %linkText, %linkInfo, $bgcolor,
         $multibody, $bodyline, @seenLabels, @seenLabel, @ctrlLabels, @ctrlLabel,
         @seenSelect, @selOption, $selOptions, $seenPre, @seenObjects, @seenObject,
         @headingLevel, $headingStart, %formNames, $needprchar,
         $nestULOL, $cntLI, $nestOBJECT, $cntPARAM,
         $isohtml, $xhtml, $xml, $xmlns, @xmlns, @markedSection, $procdoctype);
  local ($allTags, $emptyTags, $pairTags, $deprecatedTags, $omitStartTags, $omitEndTags,
         $maybeEmpty, %requiredTags, %onceonlyTags, $sequencialTags,
         %tagsElements, %excludedElems, %includedElems, $noOmitEtag,
         %deprecatedElems, %deprecatedAttrs, %deprecatedAttrsCss, %deprecatedVals,
         %tagsAttributes, %requiredAttrs, $disabled,
         %refEntities, %refParams, %indexhtml, %stathtml);
  local ($nameChr, $nameStr, $idStr, $tokenStr, $nutokenStr, %tokenizedType);
  local $/;
  if ($htmlfile eq '') {
    $htmlfile = 'stdin';
  } else {
    $fromfile = 1;
    $/ = &DetectSeparator;
  }
  %URLcollection = ();
  $penalty = 0;
  return 1 if &Doctype;
  $lang = { val=>$opt_lang, n=>0 };
  if ($opt_charset ne '') {
    if ($opt_charset =~ /^(?:$usascii)$/oi) {
      $charset = 'usascii';
    } else {
      $charset = $opt_charset;
      foreach (keys %japanesesets) {
        if ($opt_charset =~ /^(?:$japanesesets{$_})$/i) {
          $jcharcode = $_;
          last;
        }
      }
    }
    $metaCharset++;
  }
  $tagscnt = 0;
  my ($ln, $tag);
  local $analizing = 1;
  ($ln, $tag) = &ReadTag($HTML) until $tag eq $HTML;
  $analizing = 0;
  # これ以降後始末 #############
  my $over = ($whinescnt >= $opt_limit);
  if (!$over) {
    {
      my @noattrs;
      my $seens = 0;
      foreach (qw(BGCOLOR TEXT LINK VLINK ALINK)) {
        if ($seenAllTags{'BODY'.$nameSep.$_}) {
          $seens++;
        } elsif ($tagsAttributes{BODY}->{$_} ne '') {
          push(@noattrs, xc($_));
        }
      }
      if ($seens && @noattrs) {
        if ($seenAllTags{'A'.$nameSep.'HREF'}) {
          my $attrs = join('、', @noattrs);
          &Whine($bodyline, 'body-color', xc('BODY'), $attrs);
        } elsif ($tagsAttributes{BODY}->{BGCOLOR} ne '') {
          if ($seenAllTags{'BODY'.$nameSep.'TEXT'}) {
            &Whine($bodyline, 'body-color', xc('BODY'), xc('BGCOLOR'))
              unless $seenAllTags{'BODY'.$nameSep.'BGCOLOR'};
          } else {
            &Whine($bodyline, 'body-color', xc('BODY'), xc('TEXT'))
              if $seenAllTags{'BODY'.$nameSep.'BGCOLOR'};
          }
        }
      }
    }
    foreach (@ctrlLabels) {
      my @label = &SearchLabel(@$_);
      &CheckAccesskey(\@label, \@$_);
    }
    foreach my $ijam (@ijams, @istas, @ilets, @iswfs, @irsts) {
      my $found;
      foreach (@seenObjects) {
        if (uc($ijam->{id}) eq uc($_->{id})) {
          $found = 1;
          last;
        }
      }
      unless ($found) {
        &Whine($., 'undef-id', xc($ijam->{tag}), xc($ijam->{attr}), xc($ijam->{id}), $ijam->{n});
        delete $idref{$ijam->{id}};
      }
    }
    &SkipComment;
    if ($line ne '') {
      &Whine($., 'unexpected-end-of-html', xc($HTML));
      while (&GetLine ne '') { $line = ''; } # 行数をカウントしておく
    }
    foreach (reverse keys %idref) {
      unless ($iddef{$_}) {
        $idref{$_} =~ /^(\d+)$nameSep($idStr)$nameSep($idStr)$/;
        &Whine($., 'undef-id', xc($2), xc($3), $_, $1);
      }
    }
    if ($tagsAttributes{A}->{NAME} ne '' || $htmlVer >= 4) {
      if ($htmlVer >= 4) {
        # HTML4 では、アンカー名と ID は同一空間
        foreach (sort {$seenAnchors{$a} <=> $seenAnchors{$b}} keys %seenAnchors) {
          my $uval = $xhtml? $_: uc;
          &Whine($seenAnchors{$_}, 'same-fragment-id',
                                   xc('A'), $_, $iddef{$uval}, xc('ID'))
            if $iddef{$uval} && !$seenAnchorsID{$uval} && !$seenAnchorsIN{$uval};
        }
      }
      foreach (sort {$hrefAnchors{$a}[0] <=> $hrefAnchors{$b}[0]} keys %hrefAnchors) {
        if ($seenAnchors{$_}) {
          delete $seenAnchors{$_};
        } else {
          my $uval = $xhtml? $_: uc;
          my $lin = $hrefAnchors{$_}[0];
          my $tag = xc($hrefAnchors{$_}[1]);
          if ($htmlVer >= 4 && $iddef{$uval}) {
            &Whine($lin, 'id-link', $tag, $_, $iddef{$uval}, xc('ID')) if $htmlVer == 4 && !$isohtml;
            &Whine($lin, 'lower-id', $tag, xc('ID'), $_) if !$xhtml && !$isohtml && /[a-z]/;
          } else {
            &Whine($lin, 'bad-link', $tag, $_);
          }
        }
      }
    }
    foreach (sort {$seenAnchors{$a} <=> $seenAnchors{$b}} keys %seenAnchors) {
      &Whine($seenAnchors{$_}, 'unref-link', xc('A'), $_);
    }
    if ($tagsAttributes{MAP}->{NAME} ne '') {
      foreach (sort {$mapAnchors{$a}[0] <=> $mapAnchors{$b}[0]} keys %mapAnchors) {
        if ($seenMapAnchors{$_}) {
          delete $seenMapAnchors{$_};
        } else {
          my $uval = $xhtml? $_: uc;
          &Whine($mapAnchors{$_}[0], 'bad-link', xc($mapAnchors{$_}[1]), $_);
        }
      }
    }
    foreach (keys %::nonsupportedTagsPair) {
      my $alt = $::nonsupportedTagsPair{$_}[0];
      if ($alt =~ /^(?:$allTags)$/ &&
          $seenAllTags{$_} && !$seenAllTags{$alt}) {
        &Whine($., $::nonsupportedTagsPair{$_}[1], xc($_), xc($alt));
      }
    }
  }
  &CheckMIME($opt_mime, 'HTTPレスポンスヘッダ');
  &Whine($., 'http-head-charset', '', xc('CHARSET')) if $opt_base && $xml && $opt_charset eq '' && !$opt_igncharset; # $opt_base は URL 指定の確認用
  if (!$xcharset && $xhtml) {
    if ($xml || $opt_charset eq '') {
      &Whine($., 'xml-encoding', ${$::doctypes{$rule}}{group});
    }
  }
  if (!$opt_igncharset) {
    if (${$::doctypes{$rule}}{restrict} & $::restrictsjisutf) {
      if ($textcode eq 'jis' || $textcode eq 'euc') {
        &Whine($., 'jpo-shift-jis', '', ${$::doctypes{$rule}}{guide}, 'Shift JIS または UTF-8');
      }
    }
    if (${$::doctypes{$rule}}{restrict} & $::restrictsjiseuc) {
      if ($textcode eq 'jis' || $textcode eq 'utf8') {
        &Whine($., 'jpo-shift-jis', '', ${$::doctypes{$rule}}{guide}, 'Shift JIS または EUC');
      }
    }
    if (${$::doctypes{$rule}}{restrict} & $::restrictsjis) {
      if ($textcode eq 'jis' || $textcode eq 'euc' || $textcode eq 'utf8') {
        &Whine($., 'jpo-shift-jis', '', ${$::doctypes{$rule}}{guide}, 'Shift JIS');
      }
    }
    my $textcode2 = $textcode;
    $textcode2 =~ tr/a-z/A-Z/;
    $textcode2 = 'Shift JIS' if $textcode2 eq 'SJIS';
    $textcode2 = 'UTF-8'     if $textcode2 eq 'UTF8';
#   if ($textcode eq 'jis' || $textcode eq 'sjis' || $textcode eq 'euc') {
#     &Whine($seenXml, 'xmldecl-encoding', $textcode2) if $seenXml && $xcharset eq '';
#   }
    if ($jcharcode && $textcode && $jcharcode ne $textcode) {
      if ($opt_charset ne '') {
        &Whine($., 'charset-mismatch', $charset, $textcode2, 'HTTPレスポンスヘッダに');
      } else {
        &Whine($seenCharset, 'charset-mismatch', $charset, $textcode2);
      }
    }
    if ($opt_charset ne '' && $opt_charset !~ /^($charsets)$/oi) {
      &Whine($., ($opt_charset =~ /^x-/i)?
                  'no-registered-charset-ex':
                  'no-registered-charset', '', 'HTTPレスポンスヘッダに', $opt_charset);
    }
  }
  &Whine($refreshHTML[0], 'refresh-link', xc($tag), xc('HTTP-EQUIV'), xc('REFRESH'),
                                          xc('CONTENT').'="〜"') if @refreshHTML;
  foreach (0, 1) {
    if (($lcase[$_] && $ucase[$_]) || $xcase[$_]) {
      $ln = $xcaseln[$_];
      $ln = $lcaseln[$_] if $lcase[$_] && $lcase[$_] <= $ucase[$_];
      $ln = $ucaseln[$_] if $ucase[$_] && $ucase[$_] <= $lcase[$_];
      &Whine($ln, 'mixed-case', $_? '属性名': '要素名');
    }
  }
  foreach (reverse @markedSection) {
    &Whine($., 'unclosed-marked-section', '', $_->[1], $_->[0]);
  }
  if (${$::doctypes{$rule}}{doclimit} &&
      ${$::doctypes{$rule}}{doclimit}*1024 < $readsize) {
    &Whine($., 'over-file-size', '', ${$::doctypes{$rule}}{guide},
                                     ${$::doctypes{$rule}}{doclimit});
  }
  &Whine($., 'over-limit-whines', $opt_limit) if $over;
  $ln = $.;
  my $kind = scalar(keys %seenAllTags);
  if ($opt_stat) {
    $::seenMultiBody{$multibody}++ if $multibody > 1;
    $::seenTagsKind{$kind}++;
    foreach (keys %seenAllTags) {
      $::seenTagsStat{$_} += $seenAllTags{$_} unless m#$nameSep#o;
    }
  }
  print "panalty=$penalty+$upenalty/lines=$ln/tags=$tagscnt/kind=$kind" if $opt_dbg;
  if ($penalty+$upenalty) {
    my $weight = $tagscnt+($kind+13)/29; # 16(=29-13)個位はタグの種類が欲しい
#   my $threshold = 200;
#   if ($tagscnt > $threshold) {
#     $weight += $tagscnt*sqrt($tagscnt-$threshold)/$threshold;
#   }
    $penalty = int((1-$penalty/$weight)*100 -$upenalty);
    $penalty = 99 if $penalty == 100;
    if ($penalty < 80) {
      # (80, 80), (0, -$c) を通り、(80, 80) の傾きが 1 の sqrt 曲線
      my $c = -5;
      my $a = $c/6400;
      my $b = (1-$c/40)/$a;
      $penalty = int((-$b-sqrt($b*$b-4*($c-$penalty)/$a))/2);
    }
    if    ($maxpnt >= 9) { $penalty -= 27 }
    elsif ($maxpnt >= 8) { $penalty -= 24 }
    elsif ($maxpnt >= 7) { $penalty -= 21 } # 7以上は文法違反
    elsif ($maxpnt >= 6) { $penalty -= 4 }
    elsif ($maxpnt >= 5) { $penalty -= 3 }
    elsif ($maxpnt >= 4) { $penalty -= 2 }
    elsif ($maxpnt >= 3) { $penalty -= 1 }
  } else {
    $penalty = 100;
  }
  print "/score=$penalty\n" if $opt_dbg;
  if ($whinescnt || !$opt_scorenowhines) {
    if ($opt_banner) {
      if ($whinescnt) {
        print $whinescnt, '個'.($over?'以上':'').'のエラーがありました',
              ($opt_score && $penalty >= 100)? 'が、': '。';
      } else {
        print 'エラーは見つかりませんでした。＼(^o^)／ ';
      }
    }
    if ($opt_score) {
      if ($opt_scoreonly) {
        print $penalty;
      } else {
        print 'このHTMLは ', $penalty, '点です。';
        print 'タグが ', $kind, '種類 ', $tagscnt, '組使われています。' if !$over;
        if (!$opt_igncharset) {
          my $code = ($textcode eq 'jis')? 'JIS (ISO-2022-JP)':
                     ($textcode eq 'sjis')? 'Shift JIS':
                     ($textcode eq 'euc')? 'EUC-JP':
                     ($textcode eq 'utf8')? 'UTF-8': undef;
          print '文字コードは ', $code, ' のようです。' if $code;
        }
      }
    }
    if ($opt_banner || $opt_score) {
      print "\n" unless $opt_scoreonly;
      print "\n" if $opt_echoname;
    }
  }
  if ($opt_linklist && %URLcollection) {
    print $htmlfile.' には以下のリンクが含まれています。'."\n";
    foreach (sort { my $ah = $a =~ /^$::httpSchemes/o;
                    my $bh = $b =~ /^$::httpSchemes/o;
                    $ah <=> $bh or $a cmp $b; } keys %URLcollection) {
      print "$_\n";
    }
  }
  $whinescnt? 1: 0;
}

##################################################
# タグを読む
# タグを処理したときは、もしあれば終了タグまで処理され、行番号とタグ名が返る
# それらは、(nnn, TAG) の形のリストである
# タグを処理しなかったときは nnn が 0 である
# そのとき処理しようとしたタグが TAG にセットされているかも知れない

sub ReadTag
{
  my $tags = shift; # 許可されるタグセット
  $pretab = 0;
  my $ln;
  $tags = ($tags =~ /^%(.*)/)? $refParams{$1}: &ExpandInternalElements($tags);
  if ($tags =~ /^R?CDATA$/) {
    #$ln = $.;
    &ReadCDATA($tags);
    return (0, $TAG);
  }
  my $oldxmlns = $xmlns;
  local $xmlns = $oldxmlns;
  my $id = &GetTag;
  local $TAG = uc($id);
  local $oTAG = $xhtml? $id: $TAG;
  local $atag = $TAG; # XMLNS:namespace に対応するための代表
  local $minetag;
  local (%seenAttrs, %seenAttrsOrg);
  $needprchar = 0 unless $token =~ /^<A(?:\s|>|$)/i;
  $ln = $.;
  local $unknownTag = 0;
  if ($TAG eq '') {
    # 次の $appElem は有効な内容がないときに無限ループを防ぐ
    &GetLine ne '' || !$appElem++ || return (0, '');
    $ln = $.;
    $TAG = '#PCDATA';
  } else {
    if ($TAG =~ m#^/#) {
      if ($#tagsNest >= 0) {
        # ここでは終了タグは処理できない
        &UnGetToken;
        return (0, $TAG);
      }
    } else {
      if ($xhtml && $id ne lc($id)) {
        &Whine($., 'lower-case-tag', '', $id) if uc($id) =~ /^(?:$allTags)$/;
      }
      my $unknown;
      if ($TAG =~ /^([^:]+):/) {
        # IE5 の XMLNS:namespace 対応
        my $xmlns = $1;
        $unknown = 1;
        foreach (@xmlns) {
          if ($xmlns eq $_) {
            $unknown = 0;
            $atag = ':XMLNS:';
            $tagsElements{$TAG} = $tagsElements{$atag};
            &Whine($., 'unsupported-tag', xc($TAG));
            last;
          }
        }
      } else {
        $unknown = $TAG !~ /^(?:$allTags)$/ && !$xmlns;
      }
      if ($unknown) {
        # 不明なタグ
        if ($TAG eq '!DOCTYPE') {
          &Whine($., 'misplaced-doctype');
          &AdvanceCloseTag($TAG, $.);
          return ($ln, $lastTag = $TAG);
        }
        $unknownTag++;
        if (&WhineUnknownElement($id)) {
          # 他のHTMLの要素
          $seenAllTags{$TAG}++;
          $tagscnt++;
          $unknownTag++;
        }
      }
    }
  }
  my $omitstart = '';
  my $omitstart_trivial = 0;
  my $allow = 0;
  my $unget = 0;
  my $errHtml = 0;
  if (!$unknownTag) {
    if ($#tagsNest != -1) {
      # 開始タグの省略は $omitStartTags にあるタグで次のいずれかのときに可能とする
      #   $tags が 1 タグのとき
      #   順序タグのとき
      #   省略可能なタグがひとつでそれによって $TAG が書けるようになるとき
      if (@seq) {
        my $stag = ($seqid == -1)? '': &ExpandInternalElements($seq[$seqid]);
        my $parent = $tagsNest[$#tagsNest]{tag};
        if ($stag ne '' && $TAG =~ /^(?:$stag)$/ &&
            $TAG !~ /^(?:$onceonlyTags{$parent})$/) {
          # このタグはここに書ける
        } else {
          foreach my $i ($seqid+1..$#seq) {
            $stag = &ExpandInternalElements($seq[$i]);
            last if $TAG =~ /^(?:$stag)$/;
            next unless $seq[$i] =~ /^(?:$requiredTags{$parent})$/;
            foreach (split(/\|/, $stag)) {
              if (/^(?:$omitStartTags)$/) {
                $omitstart = $_;
                $seqid = $i;
                # 次の判定あいまい (TBODY対応)
                $omitstart_trivial = 1 if $#tagsNest > 0;
                last;
              }
            }
            last if $omitstart;
          }
        }
      } else {
        if ($tags =~ /\|/) {
          # ここの処理はすごくいいかげん
          # Cougar09/04 の TABLE 処理を想定しているが、TBODY の順序関係など見ていない
          foreach (split(/\|/, $tags)) {
            if (/^(?:$omitStartTags)$/) {
              $omitstart = $_;
              $omitstart_trivial = 1 if $#tagsNest > 0;
              last;
            }
          }
        } else {
          $omitstart = $tags if $tags =~ /^(?:$omitStartTags)$/;
        }
      }
    }
    if ($TAG ne '') {
      foreach (reverse @inclNest) {
        if ($TAG =~ /^(?:$_)$/) {
          $allow = 1;
          last;
        }
      }
    }
    if (!$allow) {
      my ($exclude, $exclude_force) = (-1, -1);
      # 禁止されているタグを調べる (後ろから)
      foreach (reverse 0..$#exclNest) {
        if ($TAG =~ /^(?:$exclNest[$_])$/) {
          if ($omitstart) {
            # 開始タグが省略できるときはそれが現れたとして処理を続ける
            $unget++;
            last;
          }
          if (&OmitEndTag($_)) {
            # 終了タグが省略できるときは処理を終える
            &UnGetToken;
            return (0, $TAG);
          }
          $exclude_force = $exclude = $_+1;
          last;
        }
      }
      if (!$unget && $tags ne 'ANY' && ($TAG eq '' || $TAG !~ /^(?:$tags)$/)) {
        # ここには書けないタグ
        if ($omitstart) {
          # ここに $tags が現れたとして処理する
          $unget++;
          $exclude = -1;
        } else {
          if (&OmitEndTag($#tagsNest)) {
            # 終了タグが省略できるときは処理を終える
            &UnGetToken;
            return (0, $TAG);
          }
          $exclude = $#tagsNest+1;
        }
      }
      my ($parent, $pln);
      if ($exclude == -1) {
        ($parent, $pln) = ($tagsNest[$#tagsNest]{tag}, $tagsNest[$#tagsNest]{n})
          if $#tagsNest != -1;
        if ($unget || ($omitstart && $omitstart ne $TAG &&
            $omitstart =~ /^(?:$requiredTags{$parent})$/)) {
          # 省略されている省略可能なタグが必要なときはそれが現れたとして処理を続ける
          &UnGetToken;
          $TAG = $omitstart;
          &Whine($., $omitstart_trivial? 'omit-start-tag-trivial':
                                         'omit-start-tag', xc($TAG));
          $unget++;
        }
      } elsif ($exclude-- == 0) {
        # 省略不可の <HTML> が省略されたケース
        &UnGetToken;
        $TAG = $tags;
        &Whine($., ($TAG =~ /^(?:$omitStartTags)$/)?
                   'omit-start-tag': 'required-start-tag', xc($TAG));
        $unget++;
      } else {
        # 書けないタグに対する警告
        ($parent, $pln) = ($tagsNest[$exclude]{tag}, $tagsNest[$exclude]{n});
        my ($msg, @cand);
        if ($TAG ne '#PCDATA') {
          foreach my $x (reverse 0..$exclude-1) {
            @cand = grep((!/^$internalElem$/o &&
                          $TAG =~ /^(?:$tagsElements{$_})$/ &&
                          $tagsElements{$_} !~ /^(?:$deprecatedTags)$/),
                           split(/\|/, $tagsElements{$tagsNest[$x]{tag}}));
            last if @cand;
          }
          if (@cand) {
            $msg = &Join('|', @cand);
            if ($exclude_force == -1 &&
                $msg !~ /\|/ && $msg =~ /^(?:$omitStartTags)$/ &&
                $TAG =~ /^(?:$tagsElements{$msg})$/ &&
                $msg =~ /^(?:$tagsElements{$lastTag})$/) {
              # 候補がひとつでそれが省略可能で、
              # その候補をここに書くことができるときは、
              # ここにそれが現れたとして処理する
              &UnGetToken;
              $TAG = $omitstart = $msg;
              &Whine($., 'omit-start-tag', xc($TAG));
              $unget++;
              $exclude = -1;
            } else {
              $msg = ($#cand >= 5)? '': # あまり候補が多いときは出さない
                     &FormatTagGuide($msg, '%s 内になら書けます。');
            }
          }
        }
      }
      if ($exclude != -1) {
        foreach (reverse 0..$exclude-1) {
          last unless $tagsNest[$_+1]{tag} =~ /^(?:$omitEndTags)$/;
          if ($TAG =~ /^(?:$tagsElements{$tagsNest[$_]{tag}})$/) {
            # 親を省略すると書けるようになるタグ
            &UnGetToken;
            return (0, $TAG);
          }
        }
        if ($TAG ne '#PCDATA') {
          my $msg;
          &::PushStat('ExcludedElement', $parent.' '.$TAG) if $opt_stat;
          if ($TAG =~ /^(?:$pairTags)$/ && $parent =~ /^(?:$tagsElements{$TAG})$/) {
            # 入れ替えると書けるようになるタグ
            $msg = xc("<$TAG>").'〜'.xc("</$TAG>").' 内に '.
                   xc("<$parent>").' を書くことはできます。';
          }
          if ($exclude == $#tagsNest && $TAG eq $parent) {
            if ($TAG ne $HTML) {
              # 直前が同じタグのときは、その終了タグを補うと </A> 忘れでの
              # 大量警告を減らせる
              &WhineExcludedElement($TAG, $parent, $pln,
                                    xc("</$parent>").' を補ってください。');
              &UnGetToken;
              return (0, $TAG);
            }
            &WhineExcludedElement($TAG, $parent, $pln, $msg);
            $errHtml = 1;
          } elsif (&WhineExcludedElement($TAG, $parent, $pln, $msg)) {
            &UnGetToken;
            $line = '</'.xc($parent).'>'.$line;
            return (0, $TAG);
          }
          $parent = '';
        }
      }
      if ($parent && $TAG =~ /^(?:$deprecatedElems{$parent})$/) {
        my $elem = ($TAG eq '#PCDATA')? '普通のテキスト': xc("<$TAG> ");
        &Whine($., 'deprecated-element', '', $elem, xc($parent), $pln);
        &::PushStat('DeprecatedElement', $parent.' '.$TAG) if $opt_stat;
      }
      if ($TAG eq '#PCDATA') {
        &ReadPCDATA;
        if ($pcdata ne '' &&
            ($exclude != -1 || ($tags ne 'ANY' && $TAG !~ /^(?:$tags)$/))) {
          &::PushStat('UnexpectedPCDATA', $tagsNest[$#tagsNest]{tag}) if $opt_stat;
          if (&WhineExcludedElement($TAG, $tagsNest[$#tagsNest]{tag},
                                          $tagsNest[$#tagsNest]{n})) {
            &UnGetToken;
            $line = '</'.xc($parent).'>'.$pcdata.$line;
            return (0, $TAG);
          }
        }
        if ($parent eq 'FIELDSET' && $pcdata ne '') {
          my $legend = 0;
          foreach (0..$seqid) {
            if ($seq[$_] eq 'LEGEND') {
              $legend++;
              last;
            }
          }
          &Whine($., 'fieldset-whitespace', '', xc($parent)) unless $legend;
        }
        return ($ln, $lastTag = $TAG);
      }
    }
  }
  if (!$unget) {
    my $badInner = '';
    if (!$unknownTag && $TAG ne $HTML) {
      if (@seq) {
        # タグの出現順序を調べる
        # @seq と $seqid の寿命に注意
        # @seq には #XXX というのが入っているがそのままで構わない
        my ($where, $stag, $rtag, @last);
        my $parent = $tagsNest[$#tagsNest]{tag};
        foreach $where ($seqid..$#seq) {
          next if $where == -1;
          $stag = &ExpandInternalElements($seq[$where]);
          unless ($TAG =~ /^(?:$stag)$/) {
            if ($where == $#seq) {
              my $err = 0;
              foreach (reverse 0..$#seq-1) {
                $stag = &ExpandInternalElements($seq[$_]);
                if ($err) {
                  push(@last, $stag);
                  if ($seq[$_] =~ /^(?:$requiredTags{$parent})$/) {
                    $err = -1;
                    last;
                  }
                } elsif ($TAG =~ /^(?:$stag)$/) {
                  $err++;
                }
              }
              push(@last, '') if $err > 0;
            }
          } else {
            my $err = 0;
            if ($where == $seqid) {
              if ($TAG =~ /^(?:$onceonlyTags{$parent})$/) {
                $err = $where;
                my $last = '';
                foreach (@seq) {
                  push(@last, $last) if $_ eq $TAG && $last !~ /^#/;
                  $last = $_;
                }
              }
            } else {
              foreach ($seqid+1..$where-1) {
                if ($seq[$_] =~ /^(?:$requiredTags{$parent})$/) {
                  $err = $_;
                  push(@last, &ExpandInternalElements($seq[$_]));
                }
              }
            }
            unless ($err) {
              undef @last;
              $seqid = $where;
              last;
            }
          }
        }
        if (@last) {
          my $last = join('|',
            map { (($_ eq '')? $parent: /^(?:$pairTags)$/? "/$_": $_) } @last);
          &Whine($., 'must-follow', xc($TAG), &FormatTagGuide($last));
          &::PushStat('MustFollow', $TAG.' '.$last) if $opt_stat;
        }
      }
#     # 特定のタグ内にしか書けないタグか調べる
#     my $badInner = '';
#     foreach (keys %::innerElements) {
#       if ($TAG =~ /^(?:$::innerElements{$_})$/) {
#         $badInner = $_;
#         foreach (reverse @tagsNest) {
#           if ($badInner eq $$_{tag}) {
#             $badInner = '';
#             last;
#           }
#         }
#         if ($badInner ne '') {
#           &Whine($., 'misplaced-element', xc($TAG), xc($badInner));
#           last;
#         }
#       }
#     }
      # 薦められないタグか調べる
      if ($TAG =~ /^(?:$deprecatedTags)$/) {
        my $alt = '';
        my $whine = 'deprecated-tag';
        foreach (keys %::altDeprecated) {
          if ($TAG =~ /^(?:$_)$/) {
            $alt = $::altDeprecated{$_};
            if ($alt eq 'css') {
              $whine = 'deprecated-tag-css';
#             &::PushStat('DeprecatedTagCSS', $TAG) if $opt_stat;
            } elsif ($alt eq 'css2') {
              $whine = 'deprecated-tag-css2';
#             &::PushStat('DeprecatedTagCSS', $TAG) if $opt_stat;
            } else {
              $alt = xc("<$alt>").(($htmlVer >= 4 && $alt =~ /ALIGN/)?
                                   ' かスタイルシートを使いましょう。':
                                   ' を使いましょう。');
            }
            last;
          }
        }
        &Whine($., $whine, xc($TAG), $alt);
        &::PushStat('DeprecatedTag', $TAG) if $opt_stat && $whine eq 'deprecated-tag';
      }
      # ヘディングの順序を調べる
      if ($TAG =~ /^H(\d)$/) {
        my $level = $1;
        if ($headingStart <= $#headingLevel) {
          my $last = $headingLevel[$#headingLevel];
          if ($last->[0]+1 < $level) {
            &Whine($., 'heading-order', xc($TAG), xc('H'.$last->[0]), $last->[1]);
          } else {
            foreach (reverse $headingStart..$#headingLevel) {
              last if $level >= $last->[0];
              pop(@headingLevel);
            }
          }
        }
        push(@headingLevel, [ $level, $. ]);
      }
    }
    # 使うべきでないタグ
    &Whine($., 'should-not-use', xc($TAG)) if $TAG =~ /^(?:$::shouldNotUse)$/o;
    # 属性を調べる
    local ($ATTR, $oATTR, $subATTR, $value);
    while (&GetAttrName ne '') {
      my $sp = $line =~ /^(?:\s|$)/;
      my $orgvalue = '';
      if (&GetLine =~ /^=($allc*)/o) {
        # 属性名 = 属性値
        $line = $1;
        if ($sp || $line =~ /^(?:\s|$)/) {
          &Whine($., 'space-around-equal', xc($TAG), xc($ATTR));
        }
        $orgvalue = $value = &GetAttrValue;
        &CheckAttribute($TAG, $ATTR) || next;
        ($_ = $TagAttrCheckers{$TAG.$nameSep.$ATTR}) and &$_;
        ($_ = $AttrCheckers{$ATTR}) and &$_;
        # 次の判定の '%Script' 要注意 (規則ファイル中にこの字面を仮定)
        &CheckAttrINTRINSIC
          if $tagsAttributes{$atag}->{$ATTR} =~ /^\%Script(?:\.datatype)?$/o;
      } else {
        # 属性名が省略されている場合
        $line = ' '.$line if $sp;
        ($_ = $TagAttrCheckers{$TAG.$nameSep.$ATTR}) and &$_;
        if ($ATTR =~ /:$/) {
          # IE5 の XMLNS:namespace 対応
          $value = '';
        } else {
          $value = $ATTR;
          &Whine($., 'no-minimization', xc($TAG), xc($value)) if $xhtml;
          ($_ = $AttrCheckers{$ATTR}) and &$_;
          my ($akey, $avals) = ('', '');
          my $attrval = \%{$tagsAttributes{$TAG}};
          foreach (keys %{$attrval}) {
            # 指定された属性値を持つ属性名を探す
            $ATTR = $_;
            $avals = $attrval->{$ATTR};
            next if $avals =~ /=/;
            if ($avals =~ /^%(.*)/) {
              # ここでは <TABLE BORDER> のような書式を判定する
              # 選択以外を非正規表現として比較する quotemeta ではだめ
              my $x = $refParams{$1};
              $x =~ s/([^\w\(\|\)])/\\$1/g;
              if ($value =~ /^(?:$x)$/i) {
                $akey = $ATTR;
                last;
              }
            }
            if ($avals !~ /^(?:$charData)$/oi && $value =~ /^(?:$avals)$/i) {
              if ($akey) {
                # 同じ属性値を持つ属性が複数存在する
                $akey = '';
                last;
              }
              $akey = $ATTR;
            }
          }
          if ($akey eq '') {
            if ($tagsAttributes{$atag}->{$value} ne '') {
              # 属性値の候補を表示してもよい
              &Whine($., 'required-value', xc($TAG), xc($value));
              &::PushStat('RequiredValue', $TAG.' '.$value) if $opt_stat;
            } else {
              &WhineUnknownAttribute($TAG, $value);
            }
            next;
          }
          unless ($value =~ /^$akey$/i) {
            &Whine($., 'omit-attribute-name', xc($TAG), xc($akey), $value);
            &::PushStat('OmitAttributeName', $TAG.' '.$value) if $opt_stat;
          }
          $ATTR = $akey;
        }
      }
      if ($ATTR =~ /^(?:$deprecatedAttrsCss{$TAG})$/i) {
        # 薦められない属性 (スタイルシートからみ)
        &Whine($., 'deprecated-attribute-css', xc($TAG), xc($ATTR));
#       &::PushStat('DeprecatedAttrCSS', $TAG.' '.$ATTR) if $opt_stat;
      } elsif ($ATTR =~ /^(?:$deprecatedAttrs{$TAG})$/ ||
               $ATTR =~ /^(?:$deprecatedAttrs{'*'})$/) {
        # 薦められない属性
        # <SCRIPT LANGUAGE> は、<SCRIPT TYPE> があれば無減点とする
        # この処理は別の場所で行なう
        unless ($TAG eq 'SCRIPT' && $ATTR eq 'LANGUAGE') {
          &Whine($., 'deprecated-attribute', xc($TAG), xc($ATTR));
        }
        &::PushStat('DeprecatedAttr', $TAG.' '.$ATTR) if $opt_stat;
      }
      &Whine($., 'repeated-attribute', xc($TAG), xc($ATTR))
        if defined($seenAttrs{$ATTR});
      $seenAttrs{$ATTR.$subATTR} = $value;
      if ($orgvalue ne '') { $seenAttrsOrg{$ATTR.$subATTR} = $orgvalue; }
    } # &GetAttrName
    # 物理フォントタグか調べる
    if ($::physicalFontElements{$TAG} && !$seenAttrs{CLASS}) {
      my @p = grep(/^(?:$allTags)$/,
                   split(/\|/, $::physicalFontElements{$TAG}));
      &Whine($., 'physical-font', xc($TAG),
                 &FormatTagGuide(&Join('|', @p), '例えば %s。')) if @p;
    }
    if ($textcode =~ /^(?:jis|euc|sjis)$/ && ${$lang}{val} ne '') {
      # 日本語以外が指定されているときに属性値の文字コードを調べる
      foreach (keys %seenAttrs) {
        my $v = $seenAttrsOrg{$_};
        if ($v eq '') { $v = $seenAttrs{$_}; }
        if (&CheckLanguageCode($v)) {
          &WhineLanguageCode($ln, 'lang-attribute', $TAG, $_);
        }
      }
    }
    if ($tagsAttributes{$TAG}->{LANG} && $tagsAttributes{$TAG}->{'XML:LANG'}) {
      my $seens = ($seenAttrs{LANG} ne '')+($seenAttrs{'XML:LANG'} ne '');
      if ($TAG ne $HTML && $seens == 1) {
        my ($seen, $noseen) = ($seenAttrs{LANG} ne '')? ('LANG', 'XML:LANG'): ('XML:LANG', 'LANG');
        &Whine($., 'lang', xc($TAG), xc($seen), xc($noseen));
      }
      if ($seens == 2 && $seenAttrs{LANG} ne $seenAttrs{'XML:LANG'}) {
        &Whine($., 'lang-mismatch', xc($TAG), xc('LANG'), xc('XML:LANG'));
      }
    }
    return ($ln, $lastTag = $TAG) if $unknownTag || $errHtml;
    if ($TAG =~ /^(?:$::formControls)$/o) {
      my @label;
      if (@seenLabel) {
        # ラベル内のフォームコントロールを調べる
        @label = @seenLabel;
        &Whine($., 'label-control', xc($TAG), $seenLabel[0], xc('LABEL'),
                                    $ctrlLabel[0], xc($ctrlLabel[1]))
          if @ctrlLabel;
        if ($seenLabel[1] ne '') {
          &Whine($., 'label-for-control', xc($TAG), $seenLabel[0],
                       xc('LABEL'), xc('FOR'),
                       (($seenAttrs{ID} eq '')? '指定されていない ': ' ').xc('ID'))
            if uc($seenLabel[1]) ne uc($seenAttrs{ID});
        }
        @ctrlLabel = ($., $TAG);
      }
      if (!$disabled && $TAG =~ /^(?:$::recommendedAccesskey)$/o) {
        # コントロールに対応するラベルを探す
        my @ctrl = ($., $TAG, $seenAttrs{ID}, $seenAttrs{ACCESSKEY});
        @label = &SearchLabel(@ctrl) unless @label;
        if (@label) {
          # 対応するラベルがすでにある
          &CheckAccesskey(\@label, \@ctrl);
        } else {
          # 対応するラベルがまだない (永久にないかも知れない)
          push(@ctrlLabels, [@ctrl])
            if $TAG ne 'INPUT' || uc($seenAttrs{TYPE}) ne 'HIDDEN';
        }
      }
    }
    # 必須属性を調べる
    foreach (split(/&/, $requiredAttrs{$TAG})) {
      if (/\|/) {
        my $req = $_;
        foreach (keys %seenAttrs) {
          if (/^(?:$req)$/) {
            $req = '';
            last;
          }
        }
        if ($req) {
          &Whine($., 'required-attribute', xc($TAG), &FormatAttrGuide($req));
          &::PushStat('RequiredAttr', $TAG.' '.$req) if $opt_stat;
        }
      } elsif (!defined($seenAttrs{$_})) {
        &Whine($., 'required-attribute', xc($TAG), xc($_));
        &::PushStat('RequiredAttr', $TAG.' '.$_) if $opt_stat;
      }
    }
    ($_ = $TagCheckers{$TAG}) and &$_;
    if ($htmlVer >= 4 && $TAG =~ /^(?:$::deprecatedName)$/o &&
          $tagsAttributes{$TAG}->{NAME} ne '') {
      my $name = $seenAttrs{NAME};
      my $id   = $seenAttrs{ID};
      if ($name ne '') {
        if ($id ne '') {
          if ($name ne $id) {
            &Whine($., 'diff-id-link', xc($TAG), xc('NAME'), $name, xc('ID'), $id);
            $seenAnchorsIN{xc($id)} = $. if !$xhtml && uc($id) eq uc($name);
          } else {
            if (!$xhtml && !$isohtml) {
              &Whine($., 'lower-id', xc($TAG), xc('ID'), $id) if $id =~ /[a-z]/;
            }
          }
        } else {
          if ($xhtml) {
            &Whine($., 'deprecated-attribute',
                   xc($TAG), xc('NAME'), xc('ID').' 属性を使いましょう。');
          }
        }
      }
      if (($name eq '')^($id eq '')) {
        &Whine($., 'need-id-name', xc($TAG), xc('NAME'), xc('ID')) if $xhtml || $isohtml;
      }
    }
    if ($badInner eq '' && $TAG =~ /^(?:$::innerElements{FORM})$/o) {
      my $name = $seenAttrs{NAME};
      my $type = uc($seenAttrs{TYPE});
      $type = 'TEXT' if $type eq '';
      if ($name ne '') {
        my ($ln, $chk);
        if ($formNames{$name} =~ /^(\d+)$nameSep($nameStr)(${nameSep}1)?/) {
          ($ln, $chk) = ($1, $3);
          &Whine($., 'repeated-name', xc($TAG), xc('NAME'), $name, $ln)
            if $type ne $2 || $TAG !~ /^(?:INPUT|BUTTON)$/ ||
               $type !~ /^(?:RADIO|CHECKBOX|SUBMIT|RESET|BUTTON|IMAGE|HIDDEN)$/;
        }
        if ($TAG eq 'INPUT' && $type eq 'RADIO' && $seenAttrs{CHECKED} ne '') {
          &Whine($., 'multiple-checked', xc($TAG), xc('TYPE'), $type, xc('CHECKED'), $ln) if $chk;
          $chk = $nameSep.'1';
        }
        $formNames{$name} = $..$nameSep.$type.$chk;
      }
      if ($TAG eq 'INPUT' && $type eq 'TEXT' && !defined($seenAttrs{VALUE})) {
        &Whine($., 'default-text', xc($TAG), xc(' VALUE ').'属性で');
      }
    }
    my $alt = 'ALT';
    if ($tagsAttributes{$atag}->{$alt} ne '' && !defined($seenAttrs{$alt}) &&
        # INPUT は IMAGE のときのみ警告する
        ($TAG ne 'INPUT' || uc($seenAttrs{TYPE}) eq 'IMAGE') &&
        # APPLET は applet-text-equivalent で警告する
        $TAG ne 'APPLET') {
      my $req = $requiredAttrs{$TAG};
      $req =~ s/&/\|/g;
      # %requiredAttrs 中に ALT があるとエラーが重複するのを避ける
      &Whine($., 'img-alt', xc($TAG), xc($alt)) unless $alt =~ /^(?:$req)$/;
    }
    if ($TAG =~ /^(?:$::recommendedWidth)$/o &&
        $tagsAttributes{$TAG}->{WIDTH} ne '' &&
        !($seenAttrs{WIDTH} ne '' && $seenAttrs{HEIGHT} ne '')) {
      &Whine($., 'img-size', xc($TAG), xc('WIDTH'), xc('HEIGHT')) unless $headElements;
    }
    &WhineRecommendedAttribute($., 'TITLE', $::recommendedTitle, 'recommended-title');
    &WhineRecommendedAttribute($., 'TITLE', $::recommendedFrameTitle, 'frame-title');
    &WhineRecommendedAttribute($., 'SUMMARY', $::recommendedSummary, 'table-summary');
    &WhineRecommendedAttribute($., 'ABBR', $::recommendedAbbr, 'abbr-header-label');
    unless ($disabled) {
      &WhineRecommendedAttribute($., 'ACCESSKEY', $::recommendedAccesskey,
                                 ($TAG eq 'A')? 'link-accesskey': 'form-accesskey')
        if $TAG !~ /^(?:$::formControls)$/o && # フォームコントロールは別仕立て
           $tagsAttributes{$TAG}->{HREF} eq '' || $seenAttrs{HREF} ne '';
      &WhineRecommendedAttribute($., 'TABINDEX',
                                 $::recommendedTabindex, 'form-tabindex');
    }
    if ($TAG =~ /^(?:$::cuddleContainers)$/) {
      &Whine($., 'container-whitespace', xc($TAG), '先頭') if $line =~ /^\s/;
    }
    &WhinePairEvent($., 'ONMOUSEDOWN', 'ONKEYDOWN');
    &WhinePairEvent($., 'ONMOUSEUP', 'ONKEYUP');
    &WhinePairEvent($., 'ONCLICK', 'ONKEYPRESS');
    $seenAllTags{$TAG}++;
    $tagscnt++;
  } # $unget
  $lastTag = $TAG;
  if (!($TAG =~ /^(?:$emptyTags)$/ && !$tagsElements{$TAG}) || $xmlns) {
    push(@tagsNest, { tag=>$TAG,
                      n=>$.,
                      lang=>$lang,
                      xmlns=>$xmlns,
                      ahref=>$ahref,
                      attrs=>\%seenAttrs });
    if ($#tagsNest >= 100) {
      &Whine($., 'tags-nest', xc($TAG)) unless $tagsNestWhine++;
    } else {
      $tagsNestWhine = 0;
    }
    push(@inclNest, $includedElems{$TAG});
    push(@exclNest, $excludedElems{$TAG});
    local ($lastPairTag, $lastOmitTag) = ('', $omitstart);
    local (@innerTags, %seenTags, @seq);
    local $seqid = -1;
    my $lastTagElements = $thisTagElements;
    local $thisTagElements = $tagsElements{$TAG};
    if ($headElements && $TAG eq 'OBJECT') {
      # HEAD 中の OBJECT 要素にはほとんど何も書けない
      push(@exclNest, &Join('|', pop(@exclNest),
              grep(!/^(?:$headElements|PARAM)$/, split(/\|/, $thisTagElements))));
    }
    if ($TAG =~ /^(?:INS|DEL)$/ && $#tagsNest > 0) {
      # HTML4.0 での INS と DEL の要素を調整する
      $thisTagElements = &Join('|',
              grep(/^(?:$lastTagElements)$/, split(/\|/, $thisTagElements)));
    }
    @seq = split(/\|/, $thisTagElements) if $TAG =~ /^(?:$sequencialTags)$/;
    my $tableInfoSave = $#tableInfos;
    my $tableCellSave = $tableCell;
    if ($TAG eq 'TABLE') {
      push(@tableInfos, [@tableInfo]);
      @tableInfo = ();
      $tableCell = 0;
    } elsif ($TAG eq 'HEAD') {
      $headElements = $thisTagElements;
    }
    my $headingStartSave = $headingStart;
    $headingStart = $#headingLevel+1 if $TAG =~ /^(?:$::headingBlocks)$/;
    TAGSLOOP:
    while ($whinescnt < $opt_limit) {
      while () {
        last TAGSLOOP if $whinescnt >= $opt_limit;
        local ($ahref, %alt);
#       local $titleattr;
        my $olddisabled = $disabled;
        my ($rln, $read) = &ReadTag($thisTagElements);
        $disabled = $olddisabled;
        $needprchar = $ahref if $read eq 'A';
        last unless $rln;
        if ($read eq '#PCDATA') {
          push(@innerTags, {tag=>$read, data=>$pcdata});
          if ($TAG eq 'TITLE') {
            &Whine($., 'title-length', xc($TAG), 64) if &StrLength($pcdata) > 64;
          }
          foreach (0..$#seenObject) {
            $seenObject[$_]->{app} = $.;
          }
        } else {
          if ($read =~ /^(?:IMG|OBJECT|APPLET)$/) {
            foreach (0..$#seenObject) {
              $seenObject[$_]->{app} = $.;
            }
          }
          push(@innerTags, {tag=>$read, data=>$alt{value}, alt=>\%alt});
          $lastPairTag = $read if $read =~ /^(?:$pairTags)$/;
          my $once = $onceonlyTags{$TAG};
          $once = &ExpandOnceonlyElements($once) if $TAG eq 'RUBY'; # 超下品
          if ($read =~ /^(?:$once)$/) {
            if ($seenTags{$read}) {
              my @once = ($once =~ /\b($read)\b/g);
              if ($#once == 0) {
                &Whine($rln, 'once-only', xc($read), xc($TAG), $seenTags{$read});
                &::PushStat('OnceOnly', $read) if $opt_stat;
              }
            }
          } else {
            ONCELOOP:
            while ($once =~ /($internalElem)(.*)/o) {
              $once = $2;
              my $ext = $tagsElements{$1}; # 一段の展開のみ
              if ($read =~ /^(?:$ext)$/) {
                if ($seenTags{$read}) {
                  if ($read !~ /^(?:COL|COLGROUP)$/) { # 汚いコード
                    &Whine($rln, 'once-only', xc($read), xc($TAG), $seenTags{$read});
                    &::PushStat('OnceOnly', $read) if $opt_stat;
                  }
                  last ONCELOOP;
                }
                foreach (split(/\|/, $ext)) {
                  if ($seenTags{$_}) {
                    if ($read ne $_) {
                      &Whine($rln, 'once-only-group',
                                   xc($read), xc($TAG), $seenTags{$_}, xc($_));
                      &::PushStat('OnceOnlyGroup', (($read lt $_)?
                                  $read.' '.$_: $_.' '.$read).' '.$TAG) if $opt_stat;
                    }
                    last ONCELOOP;
                  }
                }
              }
            }
          }
          $seenTags{$read} = $rln;
        }
      }
      if (&ReadEndTag) {
        foreach (split(/\|/, $requiredTags{$TAG})) {
          my $req = $_;
          if (/^$internalElem$/o) {
            $req = &ExpandInternalElement($req);
            foreach (split(/\|/, $req)) {
              if ($seenTags{$_}) {
                undef $req;
                last;
              }
            }
          } else {
            undef $req if $seenTags{$req};
          }
          if ($req && $req !~ /#PCDATA/) {
            my $msg = &FormatTagGuide($req, '', 5);
            $msg .= ' ' if $msg =~ />$/;
            &Whine($., 'required', xc($TAG), $msg);
            &::PushStat('Required', $TAG.' '.$req) if $opt_stat;
          }
        }
        if (!@innerTags) {
          if ($TAG !~ /^(?:$maybeEmpty)$/ && $tagsElements{$TAG}) {
            &Whine($., 'empty-container', xc($TAG));
            &::PushStat('EmptyContainer', $TAG) if $opt_stat;
          }
          if ($TAG eq 'TEXTAREA') {
            &Whine($., 'default-text', xc($TAG));
#         } elsif ($TAG eq 'OBJECT') {
#           &Whine($., 'recommended-title', xc($TAG), xc('TITLE'),
#                      $headElements? '': 'か内容') unless $titleattr;
          }
        } else {
          if ($#innerTags == 0) {
            if ($TAG eq 'A') {
              my $href = $linkInfo{href};
              if ($href ne '' && $innerTags[0]->{tag} eq '#PCDATA') {
                my $data = $innerTags[0]->{data};
                my $title = $linkInfo{title};
                $title = '' unless defined($title);
                if (defined($linkText{$data}) &&
                    defined($linkText{$data}->{$title}->{href}) &&
                    !CompareURL($linkText{$data}->{$title}->{href}, $href)) {
                  &Whine($., 'same-link-text', xc($TAG), $data, $linkText{$data}->{$title}->{n});
                }
                $linkText{$data}->{$title} = {n=>$., href=>$href};
              }
            }
            my $alt = $innerTags[0]->{alt};
            if ($alt->{n} && $alt->{value} =~ /^\s*$/) {
              if ($TAG eq 'A') {
                &Whine($alt->{n}, 'link-text-equivalent', xc($TAG), xc($alt->{tag}), xc($alt->{attr}));
              }
              if ($TAG =~ /^H\d$/) {
                &Whine($alt->{n}, 'heading-text-equivalent', xc($TAG), xc($alt->{tag}), xc($alt->{attr}));
              }
            }
          }
#         if ($TAG !~ /^(?:$maybeEmpty)$/ && $tagsElements{$TAG}) {
            my $br = 0;
            my $sp = 0;
            my $spaces = &spaces;
            foreach (@innerTags) {
              if ($_->{tag} eq '#PCDATA') {
                my $data = $_->{data};
                $data =~ s/(?:$spaces)//og;
                $sp++ if $data eq '';
              } elsif ($_ eq 'BR') {
                $br++;
              }
            }
            my $in = $#innerTags+1;
            if ($br) {
              &Whine($., 'br-only-container', xc($TAG), xc('BR'))
                if $TAG =~ /^(P|TD|TH)$/ && $br+$sp == $in;
            } else {
              &Whine($., 'space-container', xc($TAG)) if $sp == $in;
            }
#         }
        }
        undef %linkInfo;
        ($_ = $TagClosing{$TAG}) and &$_;
        # 終了タグが処理できたら抜ける
        last;
      }
    } # TAGSLOOP
    if ($headingStart != $headingStartSave) {
      splice(@headingLevel, $headingStart);
      $headingStart = $headingStartSave;
    }
    if ($tableInfoSave != $#tableInfos) {
      @tableInfo = @{pop(@tableInfos)};
      $tableCell = $tableCellSave;
    }
    pop(@exclNest);
    pop(@inclNest);
    pop(@tagsNest);
  } # $emptyTag
  $lang = @tagsNest? $tagsNest[$#tagsNest]{lang}: undef;
  ($ln, $TAG);
}

sub spaces
{
  my $spaces = '\s|&nbsp;|&#0*160;|&#[xX]0*[aA]0;';
  $spaces .= '|'.quotemeta('　') if $textcode ne '';
  $spaces;
}

##################################################
# ラベルとコントロールの関係を調べる補助関数

sub SearchLabel
{
  my $id = $_[2];
  if ($id ne '') {
    foreach (@seenLabels) {
      return @$_ if lc($$_[1]) eq lc($id);
    }
  }
  ();
}

sub CheckAccesskey
{
  my ($label, $ctrl) = @_;
  # @$label == [ ln, for, accesskey ]
  # @$ctrl  == [ ln, tag, id, accesskey ]
  local $TAG = $$ctrl[1];
  if ($$label[2] eq '') {
    &WhineRecommendedAttribute($$ctrl[0], 'ACCESSKEY', $::recommendedAccesskey,
            ($TAG eq 'A')? 'link-accesskey': 'form-accesskey') if $$ctrl[3] eq '';
  } else {
    # if ($$ctrl[3] ne '' && uc($$ctrl[3]) ne uc($$label[2]))
    #   キーが食い違っているがとりあえずは警告しない
  }
}

##################################################
# タグ/属性チェック関数群

sub CheckTagAttrBASE_HREF
{
  &Whine($., 'later-base', xc($TAG), xc($ATTR), $seenRelURL) if $seenRelURL;
  if ($value =~ m#^$RFC2396::scheme://.#o) {
    $baseURL = $value;
  } else {
    &Whine($., 'absolute-base-url', xc($TAG), xc($ATTR));
  }
}

sub CheckTagAttrFRAME_NAME
{
  if ($value ne '') {
    &Whine($., 'existing-target-name', xc($TAG), xc($ATTR), $value,
               $seenFrameName{lc($value)}) if $seenFrameName{lc($value)};
    if ($value =~ /^(?:$::reservedFrameNames)$/oi) {
      &Whine($., 'reserved-target-name', xc($TAG), xc($ATTR), $value);
      &Whine($., 'reserved-target-name-upper', xc($TAG), xc($ATTR), $value)
        unless $value =~ /^(?:$::reservedFrameNames)$/o;
    } elsif ($value !~ /^[A-Za-z]/) {
      &Whine($., 'illegal-target-name', xc($TAG), xc($ATTR), $value);
    }
    $seenFrameName{lc($value)} = $.;
  }
}
sub CheckTagAttrFRAME_SRC
{
  if ($value ne '') {
    my ($scheme, $url) = &SplitFragmentID($value);
    &Whine($., 'same-document-frameset', xc($TAG), xc($ATTR), $value) if $url eq '';
  }
}
sub CheckTagAttrA_HREF
{
  my ($scheme, $url, $frgid) = &SplitFragmentID($value);
  if ($frgid =~ /^#(.*)/) {
    $frgid = $1;
    if ($frgid eq '' ) {
      &Whine($., 'empty-fragment-id', xc($TAG));
    } else {
      $hrefAnchors{$frgid} = [ $., $TAG ] if $url eq '';
      if ($frgid =~ /\s/) {
        &Whine($., 'fragment-id-whitespace', xc($TAG), $frgid);
      } elsif ($frgid =~ /%/ || $frgid !~ /^(?:$RFC2396::fragment)$/o) {
        &Whine($., 'unsafe-fragment-id', xc($TAG), $frgid);
      }
    }
  }
  if ($needprchar) {
    &Whine($., 'link-separation', xc($TAG));
    $needprchar = 0;
  }
  $ahref = 1;
}
  sub CheckTagAttrA_iMode
  {
    if ($rule =~ /^imode/) {
      my $array = shift;
      push @$array, {n=>$., tag=>$TAG, attr=>$ATTR, id=>uc($value)};
    }
  }
sub CheckTagAttrA_IJAM { CheckTagAttrA_iMode(\@ijams); }
sub CheckTagAttrA_ISTA { CheckTagAttrA_iMode(\@istas); }
sub CheckTagAttrA_ILET { CheckTagAttrA_iMode(\@ilets); }
sub CheckTagAttrA_ISWF { CheckTagAttrA_iMode(\@iswfs); }
sub CheckTagAttrA_IRST { CheckTagAttrA_iMode(\@irsts); }
sub CheckTagAttrA_CTI
{
  if ($rule =~ /^imode/) {
    &Whine($., 'attribute-format', xc($TAG), xc($ATTR), $value,
               '/ を連続させることはできません。') if $value =~ m#//#;
  }
}
sub CheckTagAttrA_KANA
{
  if ($rule =~ /^imode/) {
    &Whine($., 'attribute-format', xc($TAG), xc($ATTR), $value,
               '半角カナでなければなりません。')
               if $value !~ /^[\xA0-\xDF]+$/;
  }
}
sub CheckTagAttrA_EMAIL
{
  if ($rule =~ /^imode/) {
    &Whine($., 'attribute-format', xc($TAG), xc($ATTR), $value,
               '英字から始まる 英数字 . - _ の列か 数字列でなければなりません。')
               if $value !~ /^(?:\d+|[A-Z][\w.\-_]*)$/i;
  }
}
sub CheckTagAttrIMG_ALT
{
#  if ($value ne '') {
#    foreach (0..$#seenObject) {
#      $seenObject[$_]->{app} = $.;
#    }
#  }
}
sub CheckTagAttrIMG_USEMAP
{
  my ($scheme, $url, $frgid) = &SplitFragmentID($value);
  if ($frgid =~ /^#(.*)/) {
    $frgid = $1;
    if ($frgid eq '' ) {
      &Whine($., 'empty-fragment-id', xc($TAG));
    } else {
      $mapAnchors{$frgid} = [ $., $TAG ] if $url eq '';
      if ($frgid =~ /\s/) {
        &Whine($., 'fragment-id-whitespace', xc($TAG), $frgid);
      } elsif ($frgid =~ /%/ || $frgid !~ /^(?:$RFC2396::fragment)$/o) {
        &Whine($., 'unsafe-fragment-id', xc($TAG), $frgid);
      }
    }
  }
  foreach (reverse @tagsNest) {
    if ($$_{tag} eq 'BUTTON') {
      &Whine($., 'button-usemap', xc($$_{tag}), xc($TAG), xc($ATTR));
      last;
    }
  }
}
sub CheckTagAttrIMG_ISMAP
{
  foreach (reverse @tagsNest) {
    if ($$_{tag} eq 'BUTTON') {
      &Whine($., 'button-usemap', xc($$_{tag}), xc($TAG), xc($ATTR));
      last;
    }
  }
  my $badInner = 'A';
  foreach (@tagsNest) {
    if ($badInner eq $$_{tag} && $$_{ahref}) {
      $badInner = '';
      last;
    }
  }
  &Whine($., 'misplaced-element', xc("$TAG $ATTR"), xc($badInner), xc(' HREF')) if $badInner ne '';
}
sub CheckTagAttrIMG_MOTION
{
  if ($rule =~ /^jsky/) {
    undef $seenAttrs{MOTION}; # 何度も MOTION を書ける非SGML的仕様
  }
}
sub CheckTagAttrOBJECT_TITLE
{
#  $titleattr = $ln;
}
sub CheckTagAttrOPTION_SELECTED
{
print "$.>$TAG:$seenSelect[1]\n";
  if (@seenSelect) {
    if (@selOption && !$seenSelect[1]) {
      my $msg = ($tagsAttributes{SELECT}->{MULTIPLE} ne '')?
                 $seenSelect[0].'行目の '.xc('<SELECT>').' に '.
                 xc('MULTIPLE').' 属性を指定してください。': '';
      &Whine($., 'multiple-selected', xc($TAG), xc($ATTR), $selOption[0], $msg);
    }
    @selOption = ($., $TAG);
  }
}
sub CheckTagAttrFONT_COLOR
{
  &CheckBgColor($ATTR, $value);
}

sub CheckAttrCLASS
{
  if ($value eq '') {
    my $avals = $tagsAttributes{$TAG}->{$ATTR};
    if ($avals =~ /^%(.*)/ && $refParams{$1} ne 'CDATA+') {
      &Whine($., 'empty-value', xc($TAG), xc($ATTR));
    }
  }
}
sub CheckAttrLANG
{
  $lang = { val=>$value, n=>$., attr=>$ATTR } if !$seenAttrs{'XML:LANG'};
}
sub CheckAttrXMLLANG
{
  $lang = { val=>$value, n=>$., attr=>$ATTR };
}
sub CheckAttrALT
{
  &Whine($., 'alt-spaces', xc($TAG), xc($ATTR)) if $value =~ /^(?:&nbsp;?|\s)+$/;
  if ($tagsNest[$#tagsNest]{tag} =~ /^(A|H\d)$/) {
    if ($1 eq 'A') {
      if ($tagsAttributes{$TAG}->{LONGDESC} ne '' && $value =~ /^D(?:-link)?$/) {
        &Whine($., 'd-link', xc($TAG), xc($ATTR), $value, xc('LONGDESC'));
      }
      if ($value =~ /^\s*($::hereAnchors|$::hereAnchorsJ)\s*$/oi) {
        my $here = $1;
        $here =~ s/^\s+//;
        $here =~ s/\s+$//;
        &Whine($., 'here-anchor-alt', xc('A'), xc($TAG), xc($ATTR), $here);
      }
    }
    %alt = (n=>$., tag=>$TAG, attr=>$ATTR, value=>$value);
  }
}
sub CheckAttrISMAP
{
  &Whine($., 'server-side-image-map', xc($TAG), xc($ATTR));
}
sub CheckAttrTARGET
{
  if ($value =~ /^(?:$::reservedFrameNames)$/oi) {
    &Whine($., 'reserved-target-name-upper', xc($TAG), xc($ATTR), $value)
      unless $value =~ /^(?:$::reservedFrameNames)$/o;
  } else {
    &Whine($., 'illegal-target-name', xc($TAG), xc($ATTR), $value)
      unless $value =~ /^[A-Za-z]/;
  }
}
sub CheckAttrSTYLE
{
  if (!$opt_style && !$seenAllTags{'META'.$nameSep.'CONTENT-STYLE-TYPE'}) {
    &Whine($., 'need-content-xxxx-type', xc($TAG), xc($ATTR), xc('HEAD'),
           xc('<META HTTP-EQUIV="CONTENT-STYLE-TYPE" CONTENT').'="〜"'.xetag()) if !$xml;
  }
#  if ($xml) {
#    &Whine($., 'need-xml-stylesheet', xc($TAG), $opt_mime, 'xml-stylesheet');
#  }
}
sub CheckAttrINTRINSIC
{
  if (!$opt_script && !$seenAllTags{'META'.$nameSep.'CONTENT-SCRIPT-TYPE'}) {
    &Whine($., 'need-content-xxxx-type', xc($TAG), xc($ATTR), xc('HEAD'),
           xc('<META HTTP-EQUIV="CONTENT-SCRIPT-TYPE" CONTENT').'="〜"'.xetag()) if !$xml;
  }
}
sub CheckAttrTABINDEX
{
  &WhineAttributeFormat('[0-32767]') if $value < 0 || $value > 32767;
}
sub CheckAttrDISABLED
{
  $disabled++;
}

sub CheckTagHTML
{
   $seenHtml = $.;
}
sub CloseTagHTML
{
  if (!$opt_lang && !$metaLang) {
    foreach ('LANG', 'XML:LANG') {
      if ($seenAttrs{$_} eq '' && $tagsAttributes{$TAG}->{$_} ne '') {
        &Whine($seenHtml, 'html-lang', xc($TAG), xc($_));
      }
    }
  }
}
sub CheckTagBODY
{
  if (!$multibody++) {
    $bodyline = $.;
    foreach (qw(BGCOLOR TEXT LINK VLINK ALINK)) {
      $seenAllTags{'BODY'.$nameSep.$_}++ if $seenAttrs{$_} ne '';
    }
  }
  if ($tagsAttributes{BODY}->{BGCOLOR} ne '' &&
      $seenAttrs{BACKGROUND} ne '' && $seenAttrs{BGCOLOR} eq '') {
    &Whine($., 'background', xc($TAG), xc('BACKGROUND'), xc('BGCOLOR'));
  }
  $bgcolor = &HexColor($seenAttrs{BGCOLOR}) if $seenAttrs{BGCOLOR} ne '';
  &CheckBgColor('TEXT',  $seenAttrs{TEXT});
  &CheckBgColor('LINK',  $seenAttrs{LINK});
  &CheckBgColor('VLINK', $seenAttrs{VLINK});
  &CheckBgColor('ALINK', $seenAttrs{ALINK});
}
  sub CheckBgColor
  {
    if ($bgcolor ne '') {
      my ($attr, $col) = @_;
      $col = &HexColor($col);
      if ($col ne '') {
        if (hex($col) == hex($bgcolor)) {
          &Whine($., 'same-bgcolor', xc($TAG), xc($attr), xc('<BODY BGCOLOR>'));
        } else {
          my @diff = &NearColor($col, $bgcolor);
          my $b = ($diff[0] < 125)? '明度差('.$diff[0].')': '';
          my $c = ($diff[1] < 500)? '色差('  .$diff[1].')': '';
          &Whine($., 'near-bgcolor', xc($TAG), xc($attr), xc('<BODY BGCOLOR>'),
                   &Join('と', $b, $c)) if $b || $c;
        }
      }
    }
  }
  sub HexColor
  {
    my $col = shift;
    ($col =~ /^#?([0-9A-Fa-f]{6})$/)? $1: $colorTable{lc($col)};
  }
  sub NearColor
  {
    my @x = shift =~ /(..)/g;
    my @y = shift =~ /(..)/g;
    my %rgbX = (R=>hex($x[0]),G=>hex($x[1]),B=>hex($x[2]));
    my %rgbY = (R=>hex($y[0]),G=>hex($y[1]),B=>hex($y[2]));
    my $brightnessX = $rgbX{R}*299+$rgbX{G}*587+$rgbX{B}*114;
    my $brightnessY = $rgbY{R}*299+$rgbY{G}*587+$rgbY{B}*114;
    (abs($brightnessX-$brightnessY)/1000,
     abs($rgbX{R}-$rgbY{R})+abs($rgbX{G}-$rgbY{G})+abs($rgbX{B}-$rgbY{B}));
  }
sub CheckTagLINK
{
  foreach (split(' ', $seenAttrs{REV})) {
    if (/^MADE$/i) {
#     if ($seenAttrs{HREF} =~ /^mailto:/i) {
        $seenTags{'LINK'.$nameSep.'MAILTO'} = $.;
#     }
    }
  }
  foreach (split(' ', $seenAttrs{REL})) {
    if (/^CONTENT$/i) {
      &Whine($., 'mistype-links', xc($TAG), xc('REL'), $_, 'CONTENTS');
    }
    if (/^(?:$::navigationLinks)$/oi) {
      if ($seenAttrs{HREF} ne '') {
        $seenTags{'LINK'.$nameSep.'NAVIGATE'} = $.;
      }
    }
  }
}
  sub CheckMIME
  {
    my ($mime, $here) = @_;
    if ($mime ne '') {
      if ($mime eq 'text/html') {
        if (${$::doctypes{$rule}}{version} >= 4.6) {
          &Whine($., 'unrecommended-mime-slight', $here, $mime, ${$::doctypes{$rule}}{guide});
        }
      } else {
        if (!$xhtml) {
          &Whine($., 'unrecommended-mime', $here, $mime, ${$::doctypes{$rule}}{guide});
        }
      }
    }
  }
  sub CheckCHARSET
  {
    my ($v, $where, $ocs, $seen) = @_;
    if ($v =~ /^(?:$charsets)$/oi) {
      if ($v =~ /^(?:$usascii)$/oi) {
        # US-ASCII
        if ($ocs eq '') {
          $charset = 'usascii';
        } elsif ($ocs !~ /^(?:$usascii)$/oi) {
          # 矛盾したCHARSET
          &Whine($., 'conflict-charset', xc($TAG), $where, $ocs, $seen, $v);
        }
      } else {
        # 日本語CHARSETか調べる
        foreach (keys %japanesesets) {
          if ($v =~ /^(?:$japanesesets{$_})$/i) {
            if ($ocs eq '') {
              $charset = $v;
              $jcharcode = $_;
            } elsif ($ocs !~ /^(?:$japanesesets{$_})$/i) {
              # 矛盾したCHARSET
              &Whine($., 'conflict-charset', xc($TAG), $where, $ocs, $seen, $v);
            }
            last;
          }
        }
      }
    } elsif ($ocs eq '') {
      my $a = ''; # 以下の判定順序注意 (後勝ち)
      if ($Jcode && ($v =~ /utf\W*8/i)) {
        $a = 'UTF-8';
        $jcharcode = 'utf8';
      }
      if ($v =~ /jis|2022|jp/i) {
        $a = 'ISO-2022-JP';
        $charset = $v;
        $jcharcode = 'jis';
      }
      if ($v =~ /s(?:hift)?\W*(?:jis|jp)/i) {
        $a = 'Shift_JIS|MS_Kanji';
        $charset = $v;
        $jcharcode = 'sjis';
      }
      if ($v =~ /euc\W*j/i) {
        $a = 'EUC-JP';
        $charset = $v;
        $jcharcode = 'euc';
      }
      &Whine($., ($v =~ /^x-/i)?
                  'no-registered-charset-ex':
                  'no-registered-charset', '', $seen.'に',
                  $v, &FormatAttrGuide($a, '%s なら登録されています。'));
      &::PushStat('NoRegCharset', $v) if $opt_stat;
    }
  }
sub CheckTagMETA
{
  if ($seenAttrs{'HTTP-EQUIV'} =~ /^(CONTENT-.+-TYPE)$/i) {
    my $content_type = uc($1);
    &Whine($., 'existing-content-type', xc($TAG), xc('HTTP-EQUIV'), xc($content_type),
              $seenTags{$TAG.$nameSep.$content_type})
           if $seenTags{$TAG.$nameSep.$content_type};
    $seenTags{$TAG.$nameSep.$content_type} = $.;
    $seenAllTags{$TAG.$nameSep.$content_type}++;
  } elsif ($seenAttrs{'HTTP-EQUIV'} =~ /^(CONTENT-TYPE)$/i) {
    my $content_type = uc($1);
    &Whine($., 'existing-content-type', xc($TAG), xc('HTTP-EQUIV'), xc($content_type),
              $seenTags{$TAG.$nameSep.$content_type})
           if $seenTags{$TAG.$nameSep.$content_type};
    $seenTags{$TAG.$nameSep.$content_type} = $.;
    if ($seenAttrs{CONTENT} ne '') { # 冗長だが念のため
      $seenAttrs{CONTENT} =~ m#^\s*([^\s;]+)(?:\s*;\s*)?(.*)#;
      my $type = $1;
      my @param = split(/\s*;\s*/, $2);
      if ($type !~ m#^\s*(text/html|application/xhtml\+xml)(?: |;|$)#i) {
        my $mime = ${$::doctypes{$rule}}{version} >= 4.6? 'application/xhtml+xml':
                   $xhtml? 'text/html または application/xhtml+xml': 'text/html';
        &Whine($., 'no-text-html', xc($TAG), xc('CONTENT-TYPE'), $mime);
        &::PushStat('NoTextHtml', $type) if $opt_stat;
      } else {
        my $mime = $1;
        if ($opt_mime ne '' && $opt_mime ne $mime) {
          &Whine($., 'conflict-mime', xc($TAG), 'HTTPレスポンスヘッダ', $opt_mime, $mime);
        }
        &CheckMIME($mime, xc('<META> '));
      }
      while (@param) {
        my ($a, $v) = shift(@param) =~ /^\s*([^\s=]+)\s*=\s*([^"=][^\s=]*|"[^"]+")/;
        $v = $1 if $v =~ /^"(.+)"$/;
        if (uc($a) eq 'CHARSET') {
          &CheckCHARSET($v, 'XML宣言', $xcharset, xc('<META> ')) if $xcharset;
          $seenCharset = $.;
          $charset = $v if $opt_charset eq '';
          &CheckCHARSET($v, 'HTTPレスポンスヘッダ', $opt_charset, xc('<META> '));
        }
      }
      if ($seenCharset) {
        $metaCharset++;
      } else {
        &Whine($., 'no-charset', xc($TAG),
               xc('HTTP-EQUIV="CONTENT-TYPE" CONTENT').'="〜"', xc('CHARSET')) if !$xml;
      }
    }
  } elsif (uc($seenAttrs{'HTTP-EQUIV'}) eq 'REFRESH') {
    &Whine($., 'existing-content-type', xc($TAG), xc('HTTP-EQUIV'), xc('REFRESH'),
              $seenTags{$TAG.$nameSep.'REFRESH'})
           if $seenTags{$TAG.$nameSep.'REFRESH'};
    $seenTags{$TAG.$nameSep.'REFRESH'} = $.;
    if ($seenAttrs{CONTENT} =~ /^\d+(?:\s*(\W)\s*(.+))?/) {
      my ($sep, $href) = ($1, $2);
      if ($sep) {
        $href = $1 if $sep eq ';' && $href =~ /^URL\s*=\s*(.*)/i;
        local $ATTR = 'CONTENT';
        &CheckURL($href);
        @refreshHTML = ($., &NormalizeURL($href)) if $href;
      }
      &Whine($., 'refresh', xc($TAG), xc('HTTP-EQUIV'), xc('REFRESH'));
    }
  } elsif ($seenAttrs{'HTTP-EQUIV'} =~ /^(CONTENT-LANGUAGE)$/i) {
    $metaLang = $seenAttrs{CONTENT};
  }
  if (uc($seenAttrs{NAME}) eq 'ROBOTS') {
#   &Whine($., 'robots-upper', xc($TAG), xc('NAME'), $seenAttrs{NAME})
#     if $seenAttrs{NAME} ne 'ROBOTS';
    if ($::robotsContents ne '') {
      foreach (split(/\s*,\s*/, $seenAttrs{CONTENT})) {
        &Whine($., 'robots-content', xc($TAG), xc('NAME'), $seenAttrs{NAME},
               xc('CONTENT'), $_) unless /^(?:$::robotsContents)$/o;
      }
    }
  }
  if ($seenAttrs{'HTTP-EQUIV'} && $seenAttrs{NAME}) {
    &Whine($., 'meta-http-equiv-name', xc($TAG), xc('HTTP-EQUIV'), xc('NAME'));
  } elsif ($seenAttrs{'CONTENT'} && !$seenAttrs{'HTTP-EQUIV'} && !$seenAttrs{NAME}) {
    &Whine($., 'meta-no-http-equiv-name', xc($TAG), xc('CONTENT'), xc('HTTP-EQUIV'), xc('NAME'));
  }
  if ($xml && $seenAttrs{'HTTP-EQUIV'}) {
    if ($opt_mime) {
      &Whine($., 'xml-http-equiv', xc($TAG), xc('HTTP-EQUIV'), 'メディアタイプ '.$opt_mime)
        if $opt_mime ne 'text/html';
    } else {
      &Whine($., 'xml-http-equiv', xc($TAG), xc('HTTP-EQUIV'), ${$::doctypes{$rule}}{guide});
    }
  }
}
sub CheckTagSCRIPT
{
  if (!$opt_script && !$seenAllTags{SCRIPT} &&
      !$seenAllTags{'META'.$nameSep.'CONTENT-SCRIPT-TYPE'}) {
    &Whine($., 'content-xxxx-type', xc($TAG), xc('HEAD'),
           xc('<META HTTP-EQUIV="CONTENT-SCRIPT-TYPE" CONTENT').'="〜"'.xetag()) if !$xml;
  }
  if ('LANGUAGE' =~ /^(?:$deprecatedAttrs{$TAG})$/ && $seenAttrs{LANGUAGE}) {
    &Whine($., $seenAttrs{TYPE}? 'deprecated-attribute-0': 'deprecated-attribute',
               xc($TAG), xc('LANGUAGE'));
  }
}
sub CheckTagSTYLE
{
  if (!$opt_style && !$seenAllTags{STYLE} &&
      !$seenAllTags{'META'.$nameSep.'CONTENT-STYLE-TYPE'}) {
    &Whine($., 'content-xxxx-type', xc($TAG), xc('HEAD'),
           xc('<META HTTP-EQUIV="CONTENT-STYLE-TYPE" CONTENT').'="〜"'.xetag()) if !$xml;
  }
}
sub CheckTagOLUL
{
  if ($rule =~ /^jsky/) {
    $cntLI = 0 if $nestULOL == 0;
    &Whine($., 'jskyweb-olul', xc($TAG), 3) if $nestULOL++ == 3;
  }
}
sub CheckTagLI
{
  if ($rule =~ /^jsky/) {
    &Whine($., 'jskyweb-li', xc($TAG), xc('<UL>').'、'.xc('<OL>'), 99) if $nestULOL && $cntLI++ == 99;
  }
}
sub CheckTagDD
{
  if ($htmlVer < 4) {
    &Whine($., ($rule =~ /^htmlplus/)? 'must-follow': 'must-follow-slight',
               xc($TAG), xc('</DT>')) if $lastPairTag ne 'DT';
  }
}
sub CheckTagA
{
  if ($seenAttrs{TITLE} eq '') {
    if ($line =~ /^\s*($::hereAnchors|$::hereAnchorsJ)\s*</oi) {
      my $here = $1;
      $here =~ s/^\s+//;
      $here =~ s/\s+$//;
      &Whine($., 'here-anchor', xc($TAG), $here);
      &::PushStat('HereAnchor', $here) if $opt_stat;
    }
  }
  my $href = $seenAttrs{HREF};
  if ($href ne '') {
    my ($scheme, $url, $frgid) = &SplitFragmentID($href);
    $href = &NormalizeURL($url).$frgid if $scheme =~ /^(?:$::httpSchemes)?$/o;
    $seenAllTags{'A'.$nameSep.'HREF'}++;
    undef @refreshHTML if @refreshHTML && $href eq $refreshHTML[1];
  }
  &CheckNameAnchor(\%seenAnchors, \%seenAnchorsU, \%seenAnchorsID);
  %linkInfo = (href=>$href, title=>$seenAttrs{TITLE});
  if ($rule =~ /^imode/) {
    &CheckValueLength('CTI', 128);
    &CheckValueLength('SUBJECT', 30);
    &CheckValueLength('BODY', 500);
    &CheckValueLength('TELBOOK', 20);
    &CheckValueLength('KANA', 18);
    &CheckValueLength('EMAIL', 50);
    if ($seenAttrs{IJAM}) {
      &Whine($., 'required-attribute-pair', xc($TAG), xc('IJAM'), xc('HREF'))
        if !$seenAttrs{HREF};
    }
    if ($seenAttrs{ISTA}) {
      &Whine($., 'required-attribute-pair', xc($TAG), xc('ISTA'), xc('HREF'))
        if !$seenAttrs{HREF};
      &Whine($., 'nomixed-attribute', xc($TAG), xc('ISTA'), xc('IJAM'))
        if $seenAttrs{IJAM};
    }
    my @telbook;
    push @telbook, 'TELBOOK' if $seenAttrs{TELBOOK};
    push @telbook, 'KANA'    if $seenAttrs{KANA};
    push @telbook, 'EMAIL'   if $seenAttrs{EMAIL};
    if (@telbook) {
      my @notuse;
      push @notuse, 'TELBOOK' if !$seenAttrs{TELBOOK};
      push @notuse, 'KANA'    if !$seenAttrs{KANA};
      push @notuse, 'EMAIL'   if !$seenAttrs{EMAIL};
      push @notuse, 'HREF'    if !$seenAttrs{HREF};
      &Whine($., 'required-attribute-pair', xc($TAG),
             join('、', @telbook), join('、', @notuse)) if @notuse;
    }
  }
}
  sub CheckValueLength
  {
    my $attr = shift;
    my $lim = shift;
    &Whine($., 'attribute-length', xc($TAG), xc($attr), $lim)
      if $lim && length($seenAttrs{$attr}) > $lim;
  }
  sub CheckNameAnchor
  {
    my ($seen, $seenU, $seenID) = @_;
    my $name = $seenAttrs{NAME};
    if ($name ne '') {
      &Whine($., 'fragment-id-whitespace', xc($TAG), $name) if $name =~ /\s/;
      my $id = $seenAttrs{ID};
      my $same = 0;
      if ($htmlVer >= 4 && $id ne '') {
        $same = $. if $name eq $id;
      }
      my $uname = uc($name);
      if ($seen->{$name}) {
        &Whine($., 'existing-fragment-id', xc($TAG), $name, $seen->{$name});
        $seen->{$name} = $. unless $same;
        $same = 0;
      } else {
        $seen->{$name} = $.;
        &Whine($., 'case-insensitive-fragment-id',
                   xc($TAG), $name, $seenU->{$uname}) if $seenU->{$uname};
      }
      $seenU->{$uname} = $.;
      if ($xhtml) {
        $seenID->{$name} = $same;
      } else {
        $seenID->{xc($name)} = $seenID->{uc($name)} = $same;
      }
    }
  }
sub CheckTagMAP
{
  &CheckNameAnchor(\%seenMapAnchors, \%seenMapAnchorsU, \%seenMapAnchorsID);
}
sub CheckTagLABEL
{
  @seenLabel = ($., $seenAttrs{FOR}, $seenAttrs{ACCESSKEY});
  push(@seenLabels, [@seenLabel]);
}
sub CheckTagSELECT
{
  @seenSelect = ($., $seenAttrs{MULTIPLE});
}
sub CheckTagOPTION
{
  $selOptions++;
  if ($rule =~ /^imode/) {
    my $lim = 0;
    if ($rule eq 'imode') {
      $lim = 10;
      &Whine($., 'over-select-options', xc($TAG), xc('SELECT'), 20)
        if $selOptions == 21;
    } elsif ($rule eq 'imode20') {
      $lim = 42;
    }
    &CheckValueLength('VALUE', $lim);
  }
}
sub CheckTagINPUT
{
  my $type = $seenAttrs{TYPE};
  if ($type !~ /^(?:IMAGE|SUBMIT|RESET|BUTTON|HIDDEN|TEXT)$/i && $seenAttrs{NAME} eq '') {
    &Whine($., 'required-attribute', xc($TAG), xc('NAME'));
    &::PushStat('RequiredAttr', $TAG.' NAME') if $opt_stat;
  }
  if ($type =~ /^(?:RADIO|CHECKBOX)$/i &&
      !defined($seenAttrs{VALUE}) && $htmlVer == 4) {
    &Whine($., 'required-attribute', xc($TAG), xc('VALUE'));
    &::PushStat('RequiredAttr', $TAG.' VALUE') if $opt_stat;
  }
  if ($rule eq '15445') {
    if ($type =~ /^(?:HIDDEN|TEXT)$/i && !defined($seenAttrs{VALUE})) {
      &Whine($., 'required-attribute', xc($TAG), xc('VALUE'));
      &::PushStat('RequiredAttr', $TAG.' VALUE') if $opt_stat;
    }
    if ($type eq 'SUBMIT' &&
        $seenAttrs{NAME} eq '' && defined($seenAttrs{VALUE})) {
      &Whine($., 'required-attribute', xc($TAG), xc('NAME'));
      &::PushStat('RequiredAttr', $TAG.' NAME') if $opt_stat;
    }
  }
  if ($rule eq 'imode') {
    my ($size, $maxlen);
    if ($type eq 'TEXT') {
      $size = 14;
      $maxlen = 256;
    } elsif ($type eq 'PASSWORD') {
      $size = 14;
      $maxlen = 20;
    }
    local $ATTR = 'SIZE';
    local $value = $seenAttrs{$ATTR};
    &WhineAttributeFormat('<='.$size) if $size && $value > $size;
    $ATTR = 'MAXLENGTH';
    $value = $seenAttrs{$ATTR};
    &WhineAttributeFormat('<='.$maxlen) if $maxlen && $value > $maxlen;
  }
}
sub CheckTagBUTTON
{
  if ($rule eq '15445') {
    my $type = $seenAttrs{TYPE};
    if ($type eq '') {
      &Whine($., 'input-type', xc($TAG), xc('TYPE'));
      $type = 'SUBMIT';
    }
    if ($type eq 'SUBMIT') {
      if ($seenAttrs{NAME} eq '') {
        &Whine($., 'required-attribute', xc($TAG), xc('NAME'));
        &::PushStat('RequiredAttr', $TAG.' NAME') if $opt_stat;
      }
      if (!defined($seenAttrs{VALUE})) {
        &Whine($., 'required-attribute', xc($TAG), xc('VALUE'));
        &::PushStat('RequiredAttr', $TAG.' VALUE') if $opt_stat;
      }
    }
  }
}
sub CheckTagTEXTAREA
{
  if ($rule eq 'imode') {
    local $ATTR = 'COLS';
    local $value = $seenAttrs{$ATTR};
    &WhineAttributeFormat('<=10') if $value > 10;
    $ATTR = 'ROWS';
    $value = $seenAttrs{$ATTR};
    &WhineAttributeFormat('<=6') if $value > 6;
  }
}
sub CheckTagCOL
{
  if ($tagsNest[$#tagsNest]{tag} eq 'COLGROUP' && !$tagsNest[$#tagsNest]{whined} &&
      $tagsNest[$#tagsNest]{attrs}->{SPAN} ne '') {
    &Whine($tagsNest[$#tagsNest]{n}, 'colgroup-span',
           xc($tagsNest[$#tagsNest]{tag}), xc('SPAN'), xc($TAG));
    $tagsNest[$#tagsNest]{whined} = 1;
  }
}
sub CheckTagTR
{
  $tableCell = 0;
  while ($tableInfo[$tableCell][0]) {
    $tableInfo[$tableCell++][0]--;
  }
}
sub CheckTagTHTD
{
  my $row = $seenAttrs{ROWSPAN}-1; $row = 0 if $row < 0;
  my $col = $seenAttrs{COLSPAN}-1; $col = 0 if $col < 0;
  foreach (0..$col) {
    if ($tableInfo[$tableCell][0] && $tableInfo[$tableCell][1] == 0) {
      &Whine($., 'overlap-cells', xc($TAG), xc('COLSPAN'),
                 $tableInfo[$tableCell][2], $tableInfo[$tableCell][3], xc('ROWSPAN'));
    }
    $tableInfo[$tableCell++] = [$row, $_, $., $TAG];
  }
  while ($tableInfo[$tableCell][0]) {
    $tableInfo[$tableCell++][0]--;
  }
}
sub CheckTagBR
{
  if ($contBRs < 0) {
    $contBRs = 0;
  } else {
    ++$contBRs;
    my $whine;
    if ($lastTag eq '#PCDATA') {
      my $spaces = &spaces;
      my $data = $pcdata;
      $data =~ s/(?:$spaces)//og;
      if ($data eq '') {
        # 空白で偽装した悪質な連続
        &Whine($., 'continuous-brs-fake', xc('BR'));
        $whine++;
      }
    }
    if ($lastTag ne 'BR') {
      $contBRs = 0;
    } elsif ($contBRs == 1 && !$whine) {
      &Whine($., 'continuous-brs', xc('BR'));
    }
  }
}
sub CheckTagPRE
{
  $seenPre = $.;
}
sub CheckTagIMG
{
  if ($seenAttrs{ISMAP} ne '' && $seenAttrs{USEMAP} ne '') {
    &Whine($., 'img-map', xc($TAG), xc('ISMAP'), xc('USEMAP'));
  }
}
sub CheckTagAPPLET
{
  push(@seenObject, {n=>$., alt=>$seenAttrs{ALT}});
}
sub CheckTagOBJECT
{
  push(@seenObject, {n=>$., alt=>$seenAttrs{ALT}, id=>$seenAttrs{ID}});
  push(@seenObjects, $seenObject[0]);
  if ($rule =~ /^imode/) {
    $cntPARAM = 0 if $nestOBJECT == 0;
    $nestOBJECT++;
  }
}
sub CheckTagPARAM
{
  if ($rule =~ /^imode/) {
    &Whine($., 'jskyweb-li', xc($TAG), xc('<OBJECT>'), 16) if $nestOBJECT && $cntPARAM++ == 16;
  }
}
sub CheckTagXML
{
  &Whine($., 'unsupported-tag', xc($TAG));
  &Whine($., 'excluded-element', xc($TAG), xc($TAG), $xmlns) if $xmlns;
  $xmlns = $.;
}
sub CloseTagPRE
{
  # PRE は入れ子にできないと仮定
  undef $seenPre;
}
sub CloseTagFORM
{
  # FORM は入れ子にできないと仮定
  foreach (keys %formNames) {
    $formNames{$_} =~ /^(\d+)$nameSep($nameStr)(${nameSep}1)?/;
    if ($2 eq 'RADIO' and !$3) {
      &Whine($1, 'no-checked', xc('INPUT'), xc('TYPE'), xc('RADIO'), xc('NAME'), $_, xc('CHECKED'));
    }
  }
  undef %formNames;
}
sub CloseTagSELECT
{
  # SELECT は入れ子にできないと仮定
  unless (@selOption) {
    &Whine($., 'no-selected', xc('OPTION'), xc('SELECTED'));
  }
  undef @seenSelect;
  undef @selOption;
  undef $selOptions;
}
sub CloseTagLABEL
{
  # LABEL は入れ子にできないと仮定
  if ($seenLabel[1] eq '') {
    &Whine($seenLabel[0], 'label-no-control', xc('LABEL')) if !@ctrlLabel;
  }
  undef @seenLabel;
  undef @ctrlLabel;
}
sub CloseTagHEAD
{
  if ('LINK' =~ /^(?:$allTags)$/) {
    &Whine($., 'mailto-link', xc('HEAD'),
           xc('<LINK REV="MADE" HREF').'="mailto:〜"'.xetag())
               if !$seenTags{'LINK'.$nameSep.'MAILTO'};
    &Whine($., 'navigation-link', xc('HEAD'),
           xc('<LINK REL="NEXT" HREF').'="〜"'.xetag())
               if !$seenTags{'LINK'.$nameSep.'NAVIGATE'};
  }
  if (!$xml) {
    if ('META' =~ /^(?:$allTags)$/ && $opt_charset eq '' &&
        $opt_charset eq '' && !$seenTags{'META'.$nameSep.'CONTENT-TYPE'}) {
      &Whine($., 'content-type', xc('HEAD'),
             xc('<META HTTP-EQUIV="CONTENT-TYPE" CONTENT').'="〜"'.xetag())
        unless $rule =~ /^compact-html/;
    }
  }
  $metaCharset++;
  undef $headElements;
}
sub CloseTagOBJECT
{
  my $obj = pop(@seenObject);
  if ($obj->{app}) {
    &Whine($obj->{n}, 'applet-text-equivalent', xc($TAG), xc('ALT')) if defined($obj->{alt});
  } else {
    &Whine($obj->{n}, 'object-text-equivalent', xc($TAG)) if !defined($obj->{alt}) && !$headElements;
  }
  if ($rule =~ /^imode/) {
    $nestOBJECT--;
  }
}
sub CloseTagOLUL
{
  if ($rule =~ /^jsky/) {
    $nestULOL--;
  }
}

##################################################
# 終了タグを処理する
# この終了タグに対応すると思われる開始タグは $TAG である
# これは $tagsNest[$#tagsNest]{tag} と等しい
# 終了タグの処理をしたとき 1 が返る
# $TAG に対応する終了タグを処理しなかったときは 0 が返る

sub ReadEndTag
{
  my $id = &GetTag;
  my $end = uc($id);
  my $oend = $xhtml? $id: $end;
  if ($id =~ m#^/(.*)#) {
    $id = $1;
    if ($xhtml && $id ne lc($id)) {
      &Whine($., 'lower-case-tag', '', "/$id") if uc($id) =~ /^(?:$allTags)$/;
    }
    $id = uc($id);
    unless ($xmlns) {
      if ($id !~ /^(?:$pairTags)$/) {
        # 不明の終了タグ
        &WhineUnknownElement($id);
        &Whine($., 'closing-attribute', xc($TAG), xc($id))
          if &AdvanceCloseTag($end, $.);
        return 0;
      }
      if ($id =~ /^(?:$emptyTags)$/) {
        # 空要素タグには終了タグはない
        &Whine($., 'illegal-closing', xc($TAG), xc($id));
        &::PushStat('IllegalClosing', $id) if $opt_stat;
        &Whine($., 'closing-attribute', xc($TAG), xc($id))
          if &AdvanceCloseTag($end, $.);
        return 0;
      }
    }
    if ($TAG ne 'BR') {
      $contBRs = -1;
    }
    if ($TAG eq $id) {
      # 正しい終了タグ
      if ($TAG =~ /^(?:$::cuddleContainers)$/) {
        &Whine($., 'container-whitespace', xc($TAG), '末尾') if $token =~ /^\s/;
      }
      &Whine($., 'closing-attribute', xc($TAG), xc($id)) if &AdvanceCloseTag($end, $.);
      &Whine($., 'minimized-endtag', xc($TAG)) if $minetag && !$xml;
    } else {
      my $omit = &OmitEndTag($#tagsNest, $id);
      if ($omit) {
        # 終了タグは省略できる
        &UnGetToken;
        &WhineOmitEndTag($TAG, $end, $omit);
      } else {
        my $oid = $#tagsNest;
        foreach (reverse 0..$#tagsNest-1) {
          if ($id eq $tagsNest[$_]{tag}) {
            if ($_ > 1 && !$xmlns) { # いちばん外側は除く
              if ($tagsNest[$_]{tag} =~ /^(?:$omitEndTags)$/ &&
                  $tagsNest[$_]{tag} =~ /^(?:$tagsElements{$id})$/) {
                &Whine($., 'required-end-tag', xc($TAG));
                &::PushStat('OmitEndTag', $TAG) if $opt_stat;
              } else {
                my $parent = $tagsNest[$oid]{tag};
                if ($xhtml && !$tagsElements{$parent}) {
                  &Whine($tagsNest[$oid]{n}, 'endtag-slash', xc($parent));
                } else {
                  # タグの入れ子がおかしい可能性あり
                  &Whine($., 'element-overlap', xc($TAG), xc($id),
                                      $tagsNest[$oid]{n}, xc($parent));
                  &Whine($., 'omit-end-tag', xc($TAG), xc("</$id>").' の前に');
                # &::PushStat('ElementOverlap', $id.' '.$TAG) if $opt_stat;
                # &::PushStat('OmitEndTag', $TAG) 統計上これは出力してはならない
                }
              }
            } else {
              # 終了タグがない可能性
              &Whine($., 'unclosed-element', xc($TAG), $tagsNest[$#tagsNest]{n});
              &::PushStat('UnclosedElement', $TAG) if !$xmlns && $opt_stat;
            }
            &UnGetToken;
            return 1;
          }
          $oid = $_ if $tagsNest[$_]{tag} =~ /^(?:$omitEndTags)$/;
        }
        # おかしな終了タグ
        ($atag =~ /^(?:$pairTags)$/)? &Whine($., 'mis-match', xc($TAG), xc($id)):
                                      &Whine($., 'unknown-element', $oend);
        &Whine($., 'closing-attribute', xc($TAG), xc($id))
          if &AdvanceCloseTag($end, $.);
        return 0;
      }
    }
  } else {
    # 終了タグが現れなかったとき
    &UnGetToken;
    my $omit = &OmitEndTag($#tagsNest);
    if ($omit) {
      # 終了タグは省略できる
      &WhineOmitEndTag($TAG, $end, $omit);
    } else {
      # 終了タグがない可能性
      if ($TAG eq $HTML && !$reacheof) {
        # 途中で </HTML> は省略されないようにする
        # そのために、<BODY> がまだ現われていないとして処理する
        # この判定は、今では不要かも知れない
        my $rest = $..$nameSep.$line; # 無限ループを防ぐための細工
        if ($omit_html ne $rest) {
          $omit_html = $rest;
          undef $seenTags{BODY};
          return 0;
        }
      }
      &Whine($., 'unclosed-element', xc($TAG), $tagsNest[$#tagsNest]{n});
      &::PushStat('UnclosedElement', $TAG) if !$xmlns && $opt_stat;
    }
  }
  1;
}

##################################################
# 終了タグが省略できるか調べる
#    <A>
#    <B> -- <D> が禁止されている $tagsNest[$pn]{tag}
#    <C>
#    <D> -- これが現在のタグ $TAG
# 現在のタグが終了タグならば第２引数にそれがセットされている (除/)
# そのとき $TAG はそれに対応すると予想される開始タグ
# <D> が空要素タグでなく、省略によって直前のタグ <C> の要素が空にならず、
# </C> </B> が省略可で、<A> 内に <D> が書けるとき、
# </C> が省略できるとする
# また、<C> <D> が順序タグのひとつのときは、省略できそうならできるとする
# 省略できないときは 0 が返る

sub OmitEndTag
{
  my ($pn, $end, $whine) = @_;
  return 0 if $pn < 0 || $xmlns;
  my $last = $tagsNest[$#tagsNest]{tag};
  # まだテキストがあるときは </HTML> を省略できない
  return 0 if $last eq $HTML && !$reacheof;
  return 1 if $#tagsNest == 0;
  # 空要素タグか直前のタグが省略不可のときは省略できない
  return 0 if $TAG =~ /^(?:$emptyTags)$/ || $last !~ /^(?:$omitEndTags)$/;
  # <OBJECT> は <HEAD> にも書けるので、例外扱いしておく
  return 0 if $last eq 'BODY' && $TAG eq 'OBJECT';
  # 前の開始タグが省略されて要素が空のときは省略できない
  # $pn > 1 というのは <HEAD></HEAD> 等の対処
  return 0 if $pn == $#tagsNest && $pn > 1 && !@innerTags && $lastOmitTag;
  my $last1 = $tagsNest[$#tagsNest-1]{tag};
  if ($pn) {
    # 省略したときこのタグが書けるかどうか調べる
    my $ext = &ExpandInternalElements($tagsElements{$tagsNest[$pn-1]{tag}});
    if ($TAG ne $tagsNest[$pn-1]{tag} && $TAG !~ /^(?:$ext)$/) {
      my $omit = 0;
      # 開始タグを省略したときのことも考慮する (とりあえず1段のみ)
      foreach (split(/\|/, $ext)) {
        if (/^($omitStartTags)$/) {
          my $oext = &ExpandInternalElements($tagsElements{$_});
          if ($TAG =~ /^(?:$oext)$/) {
            $omit++;
            last;
          }
        }
      }
      return 0 unless $omit;
    }
  }
  if (!$end && $last1 =~ /^(?:$sequencialTags)$/) {
    # 順序タグのひとつのとき
#   return 1 if $last =~ /^(?:$omitEndTags)$/;
    my $ext = &ExpandInternalElements($onceonlyTags{$last1});
    # 次の判定はあまり正確じゃない
    if ($TAG =~ /^(?:$ext)$/ && $last !~ /^(?:$ext)$/) {
      $ext = &ExpandInternalElements($tagsElements{$last1});
      return 1 if $TAG =~ /^(?:$ext)$/;
    }
  }
# return 0 if $last eq $lastTag; # 直前のタグが空
  foreach (reverse $pn..$#tagsNest-1) {
    # 途中のタグが省略可かどうか調べる
    return 0 unless $tagsNest[$_]{tag} =~ /^(?:$omitEndTags)$/;
  }
  if ($end) {
    # 現れたのが終了タグのとき
    foreach (reverse 0..$#tagsNest-1) {
      # 対応する開始タグが存在するか調べる
      if ($end eq $tagsNest[$_]{tag}) {
        undef $end;
        last;
      }
      next if $_ >= $pn; # すでに次はチェック済み
      # 存在するならそこまでのタグが全部省略可か調べる
      return 0 unless $tagsNest[$_]{tag} =~ /^(?:$omitEndTags)$/;
    }
    return 0 if $end;
  }
  2;
}

##################################################
# #NNN 形式の内部要素を展開する

sub ExpandInternalElement
{
  my $elem = shift;
  &ExpandInternalElements($tagsElements{$elem});
# &ExpandInternalElements($tagsElements{shift}); だとうまくいかない?
}
sub ExpandInternalElements
{
  my $elem = shift;
  $elem =~ s/($internalElem)/&ExpandInternalElement($1)/oge;
  $elem;
}

sub ExpandOnceonlyElement
{
  my $elem = shift;
  $elem = ($onceonlyTags{$elem} or $tagsElements{$elem});
  &ExpandOnceonlyElements($elem);
}
sub ExpandOnceonlyElements
{
  my $elem = shift;
  $elem =~ s/($internalElem)/&ExpandOnceonlyElement($1)/oge;
  $elem;
}

##################################################
# 属性値を調べる
# 不明な属性のとき 0 が返る

sub CheckAttribute
{
  my ($tag, $attr) = @_;
  my $avals = $tagsAttributes{$tag}->{$attr};
  my $fixed = '';
  if ($avals =~ /^([^=]+)(?:=(.*))?/) {
    ($avals, $fixed) = ($1, $2);
  }
  if ($avals eq '') {
    &WhineUnknownAttribute($tag, $attr);
    $quot = '';
    return 0;
  }
  if (StrLength($value) > 1024) {
    &Whine($., 'attribute-length', xc($tag), xc($attr), 1024);
  }
  if ($fixed ne '') {
    if (lc($value) ne lc($fixed)) {
      &Whine($., 'fixed-attribute', xc($tag), xc($attr), $fixed);
    }
    return 1;
  }
  my $icase = '(?i)';  # 大文字小文字を区別しない
  if ($avals =~ /^%(.*)/) {
    $icase = ''; # このときは大文字小文字を区別する
    $avals = $refParams{$1};
  } elsif ($avals !~ /^(?:$charData)$/oi) {
    # 候補値の列挙 (大文字小文字を区別しない/XHTMLではする)
    if ($value eq '') {
      &Whine($., 'empty-value', xc($tag), xc($attr));
    } else {
      &WhineWhiteSpaceInValue;
      if ($value =~ /^(?:$avals)$/i) {
        if ($htmlVer >= 4.5 && $value !~ /^(?:$avals)$/) {
          my $cval;
          foreach (split(/\|/, $avals)) {
            if (/^$value$/i) {
              $cval = $_;
              last;
            }
          }
          &Whine($., 'attribute-value-case', xc($tag), xc($attr), $value, $cval);
        }
        if ($attr =~ /^(?:$avals)$/i && !$xhtml) {
          &Whine($., 'minimized-attribute', xc($tag), xc($attr));
          &::PushStat('MinimizedAttribute', $tag.' '.$attr) if $opt_stat;
        }
        my $dvals = $deprecatedVals{$tag.$nameSep.$attr};
        if ($dvals && $value =~ /^(?:$dvals)$/i) {
          &Whine($., 'deprecated-value', xc($tag), xc($attr), $value);
        }
      } else {
        &WhineAttributeFormat(($attr =~ /^(?:$avals)$/i)? '': $avals);
      }
    }
    $quot = '';
    return 1;
  }
  if ($avals =~ /^&/) {
    eval $avals;
  } elsif ($avals eq 'CDATA') {
    &CDATA;
  } elsif ($avals eq 'CDATA+') {
    if ($value eq '') {
      &Whine($., 'empty-value', xc($tag), xc($attr));
    } else {
      &CDATA;
    }
  } else {
    &WhineWhiteSpaceInValue;
    my $tvals = $tokenizedType{$avals} || $avals;
    if ($value =~ /^(?:$icase$tvals)$/) {
      if ($avals eq 'ID') {
        my $uval = $xhtml? $value: uc($value);
        &Whine($., 'repeated-id', xc($tag), xc($attr), $value, $iddef{$uval}) if $iddef{$uval};
        $iddef{$uval} = $.;
        if ($isohtml) {
          &Whine($., 'lower-id', xc($tag), xc($attr), $value) if $value =~ /[a-z]/;
        }
        if ($xhtml) {
          &Whine($., 'attribute-format', xc($tag), xc($attr), $value, $1.' で始めることはできません。') if $value =~ /^(xml)/i;
          &Whine($., 'unsafe-attribute', xc($tag), xc($attr), $value) if $value =~ /^_/;
        }
      } elsif ($avals eq 'IDREF') {
        my $uval = $xhtml? $value: uc($value);
        $idref{$uval} = $..$nameSep.$tag.$nameSep.$attr;
      } elsif ($avals eq 'IDREFS') {
        foreach (split(/\s*,\s*|\s+/, $value)) {
          my $uval = $xhtml? $_: uc;
          $idref{$uval} = $..$nameSep.$tag.$nameSep.$attr;
        }
      } elsif ($avals eq 'NUMBER+') {
        &WhineAttributeFormat($avals) if $value < 1;
      }
    } elsif ($value eq '') {
      &Whine($., 'empty-value', xc($tag), xc($attr));
    } else {
      &WhineAttributeFormat($avals);
    }
  }
  $quot = '';
  1;
}

##################################################
# テキストの文字コードが日本語かどうか調べる

sub CheckLanguageCode
{
  if ($textcode =~ /^(?:jis|euc|sjis)$/ &&
      ${$lang}{val} ne '' && ${$lang}{val} !~ /^(?:ja|jpn)(?:-JP)?$/i) {
    my $text = shift;
    if ($text =~ /[\x80-\xFF]/) {
      my $code = &Jgetcode(\$text);
      if ($japanesesets{$code} ne '') {
        &Jconvert(\$text, $myCODE, $code) if $myCODE ne $code;
        if ($myCODE eq 'euc') {
          my $c = 0;
          foreach (unpack('C*', $text)) {
            if ($c) {
              if (0x00A1 <= $_ && $_ <= 0x00FE && $c != 0x008E) {
                my $n = ($c<<8)|$_;
                if ((0xA4A1 <= $n && $n <= 0xA5F6) ||
                    (0xB0A1 <= $n && $n <= 0xF4A6)) { return 1; }
              }
              $c = 0;
            } elsif ((0x00A1 <= $_ && $_ <= 0x00FE) || $_ == 0x008E) {
              $c = $_;
            }
          }
        } else {
          my $c = 0;
          foreach (unpack('C*', $text)) {
            if ($c) {
              if ((0x0040 <= $_ && $_ <= 0x007E) ||
                  (0x0080 <= $_ && $_ <= 0x00FC)) {
                my $n = ($c<<8)|$_;
                if ((0x829F <= $n && $n <= 0x8596) ||
                    (0x889F <= $n && $n <= 0xEAA4)) { return 1; }
              } else {
                $c = ((0x0081 <= $_ && $_ <= 0x009F) ||
                      (0x00E0 <= $_ && $_ <= 0x00FC))? $_: 0;
              }
              $c = 0;
            } elsif ((0x0081 <= $_ && $_ <= 0x009F) ||
                     (0x00E0 <= $_ && $_ <= 0x00FC)) {
              $c = $_;
            }
          }
        }
      }
    }
  }
  0;
}
sub WhineLanguageCode
{
  my ($ln, $whine, $tag, $attr) = @_;
  &Whine($ln, $whine, xc($tag), xc($attr), ${$lang}{attr}, ${$lang}{val},
         ${$lang}{n}? ${$lang}{n}.'行目で': 'HTTPレスポンスヘッダに');
}

##################################################
# 必要な属性を付けるよう促がす警告を表示する

sub WhineRecommendedAttribute
{
  my ($ln, $attr, $recommended, $whine) = @_;
  if ($TAG =~ /^(?:$recommended)$/ &&
      $tagsAttributes{$TAG}->{$attr} ne '' && $seenAttrs{$attr} eq '' &&
      # <INPUT TYPE=HIDDEN> は除く
      ($TAG ne 'INPUT' || uc($seenAttrs{TYPE}) ne 'HIDDEN')) {
    my $req = $requiredAttrs{$TAG};
    $req =~ s/&/\|/g;
    &Whine($ln, $whine, xc($TAG), xc($attr)) unless $attr =~ /^(?:$req)$/;
  }
}

##################################################
# イベント対の不備を警告する

sub WhinePairEvent{
  my ($ln, $event1, $event2) = @_;
  if ($tagsAttributes{$TAG}->{$event1} ne '' &&
      $tagsAttributes{$TAG}->{$event2} ne '') {
    if (defined($seenAttrs{$event1}) && !defined($seenAttrs{$event2})) {
      &Whine($ln, 'event-pair', xc($TAG), xc($event1), xc($event2));
    }
    if (defined($seenAttrs{$event2}) && !defined($seenAttrs{$event1})) {
      &Whine($ln, 'event-pair', xc($TAG), xc($event2), xc($event1));
    }
  }
}

##################################################
# 正しくない属性に関する警告を表示する

sub WhineAttributeFormat
{
  my $avals = shift;
  my $cdata ='';
  my $whine = 'attribute-format';
  if ($avals =~ /^($charData)$/oi) {
    $cdata = $1;
    $cdata = ($avals =~ /^CDATA/i)? '': "($cdata)";
    $avals = ($avals =~ /^ID/i)? $xhtml? '英字または_から始まる:を除く名前文字列':
                                         '英字から始まる名前文字列':
             ($avals =~ /^NUMBER/i)? '数値':
             ($avals =~ /^NAME/i)? '英字'.($xhtml?'または_':'').'から始まる名前文字列':
             ($avals =~ /^NMTOKEN/i)? '名前文字列':
             ($avals =~ /^NUTOKEN/i)? '数字から始まる名前文字列':
             '';
  } elsif ($avals =~ /#\[0-9A-F\]\{6\}/i) {
    $whine = 'attribute-color';
    $avals = '';
  } else {
    $avals = ($avals eq 'NUMBER+')? '1以上の数値':
             ($avals eq '\d+')? '数値':
             ($avals eq '\d+%?')? '数値か %付きの数値':
             ($avals eq '(\d+(\.\d+)?(\*|%)?|\*)')? '数値か %付きの数値か *付きの数値':
             ($avals =~ /^\[(\d+)-(\d+)\]$/)? $1.'〜'.$2.' ':
             ($avals =~ /^<=(\d+)$/)? $1.'以下':
             ($avals eq '[+|-]?[1-7]')? '±1〜±7 ':
             ($avals eq '[\x20-\x7E]')? 'ASCII１文字':
             ($avals eq '[0-9#\*]')? '0〜9 # * ':
             ($avals eq '[0-9#\*\/,]')? '0〜9 # * , / ':
             ($avals eq '\w+')? '半角英数字':
             ($avals =~ /^$tokenStr(?:\|$tokenStr)+$/)? &FormatAttrGuide($avals, '%s '):
             '';
  }
  $avals .= ($avals ne '')? $cdata.'でなければなりません。': $cdata;
  &Whine($., $whine, xc($TAG), xc($ATTR), $value, $avals);
}

##################################################
# 空白が含まれる属性値の警告を表示する
# 警告後 $value の先行後行する空白は捨てられる
# 空の場合は除く

sub WhineWhiteSpaceInValue
{
  if ($value =~ /^\s|\s$/) {
    &Whine($., 'whitespace-attribute-value', xc($TAG), xc($ATTR), $value);
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
  }
}

##################################################
# <LI TYPE=> の属性を評価する

sub LIStyle
{
# &CDATA;
  &CheckAttribute($tagsNest[$#tagsNest]{tag}, $ATTR);
}

##################################################
# <OL TYPE=> の属性を評価する

sub OLStyle
{
  &CDATA;
  if ($value eq '') {
     &Whine($., 'empty-value', xc($TAG), xc($ATTR));
  } else {
    &WhineWhiteSpaceInValue;
    my $OLStyle = ($rule =~ /^(?:imode|jsky|doti)/)? '1|a|A': '1|a|A|i|I';
    &WhineAttributeFormat($OLStyle) unless $value =~ /^(?:$OLStyle)$/;
  }
}

##################################################
# <DIR TYPE=> の属性を評価する

sub DIRStyle
{
  &CDATA;
  if ($value eq '') {
     &Whine($., 'empty-value', xc($TAG), xc($ATTR));
  } else {
    &WhineWhiteSpaceInValue;
    my $OLStyle = ($rule =~ /^(?:imode|jsky|doti)/)? '1|a|A': '1|a|A|i|I';
    &WhineAttributeFormat($OLStyle)
      unless $value =~ /^(?:$OLStyle)$/ ||
             $value =~ /^(?:$tagsAttributes{UL}->{TYPE})$/i;
  }
}

##################################################
# URL 属性を評価する
# 属性は $value に入っており、結果もそこに入る

sub URL
{
# &CDATA;
  if (&CheckURL($value)) {
    $seenRelURL = $. if $TAG ne 'BASE';
  }
}

sub URLs
{
# &CDATA;
  my $n = 0;
  foreach (split(/\s+/, $value)) {
    if (&CheckURL($_)) {
      $seenRelURL = $. if $TAG ne 'BASE';
    }
    $n++;
  }
  if ($n > 1 && $ATTR eq 'PROFILE') {
    &Whine($., 'profile-uri', xc($TAG), xc($ATTR));
  }
}

sub CheckURL
{
  my $value = shift;
  my $reluri = 0;
  if ($value =~ /^\s*$/) {
    &Whine($., 'empty-url', xc($TAG), xc($ATTR));
  } else {
    my ($scheme, $url) = &SplitFragmentID($value);
    if ($scheme eq '') {
      $reluri = 1;
    } else {
      if ($scheme =~ /^(?:$::allSchemes)$/oi ||
          $scheme =~ /^(?:${$::doctypes{$rule}}{scheme})$/i) {
        &Whine($., 'upper-protocol', xc($TAG), xc($ATTR), $scheme)
          if $scheme ne lc($scheme);
        if (${$::doctypes{$rule}}{allschemes} &&
            $scheme !~ /^(?:${$::doctypes{$rule}}{allschemes})$/i) {
          &Whine($., 'cantuse-protocol', xc($TAG), xc($ATTR), $scheme);
        }
      } elsif ($scheme =~ /^(?:$RFC2396::scheme)$/o) {
        &Whine($., 'upper-protocol', xc($TAG), xc($ATTR), $scheme)
          if $scheme ne lc($scheme);
        &Whine($., 'unknown-protocol', xc($TAG), xc($ATTR), $scheme);
        &::PushStat('UnknownProtocol', $scheme) if $opt_stat;
      } else {
        &Whine($., 'illegal-protocol', xc($TAG), xc($ATTR), $scheme);
      }
      $scheme =~ tr/A-Z/a-z/;
      if ($scheme eq 'javascript') {
        &Whine($., 'javascript-url', xc($TAG), xc($ATTR), $scheme);
      }
    }
    my $whine = 0;
    my $illchar = 0;
    my $ok = 1;
    my $urlorg = $url;
    my $http   = $scheme =~ /^(?:$::httpSchemes)?$/o; # 空のときも http
    $URLcollection{&AbsoluteURL(($baseURL ne '')? $baseURL: $opt_base, $url)}++
      if $opt_linklist && $http;
    my $syntax = \&{'RFC2396::URL_'.($http? 'http': $scheme)};
    my $chkurl = ($opt_base ne '' && defined(&::AskHTML) && $http &&
                 ($enabled{'cant-get-url'} > 0.0 || $opt_pedantic));
    if ($http || defined(&$syntax)) {
      &Whine($., 'url-whitespace', xc($TAG), xc($ATTR), $url), $whine++
        if $url =~ /\s/;
      &Whine($., 'url-backslash', xc($TAG), xc($ATTR), $url), $whine++
        if $url =~ /\\/;
      if ($url =~ /$RFC2396::control/o) {
        &Whine($., 'no-corresponding-url', xc($TAG), xc($ATTR), $url);
        &Whine($., 'illegal-format-url', xc($TAG), xc($ATTR), $url);
        $whine++;
      }
      if ($ok = !$whine) {
        # URL 中の実体参照をチェックしてデコードする (このチェック不完全)
        my $urlscan = $url;
        my $exurl = '';
        while ($urlscan =~ /^([^&]*)(&.*)/) {
          my ($scanned, $c) = ($1);
          ($urlscan, $c) = &CheckRefEntities($2, 1, 1);
          $exurl .= $scanned.$c;
          $illchar += &CheckCharURL($scanned, $url);
        }
        $illchar += &CheckCharURL($urlscan, $url);
        $url = $exurl.$urlscan;
        $ok = !$whine;
      }
      if ($ok) {
        if ($scheme eq '') {
          $ok = $url =~ /^$RFC2396::relativeURI$/o if $url ne '';
          &Whine($., 'net-path', xc($TAG), xc($ATTR), $url) if $ok && $http && $url =~ m#^//#;
        } else {
          # URL中のスキームを小文字にする
          substr($url, 0, length($scheme)) = $scheme;
          if ($http) {
            $ok = $url =~ /^$RFC2396::URL_http$/o;
            if ($ok) {
              my ($path) = $url =~ m#^\w+://(?:[^/]+)(.*)$#;
              if (!$chkurl) {
                &Whine($., 'trailing-slash', xc($TAG), xc($ATTR), $urlorg)
                  if $path =~ m#^/(?:~|%7E)[^/]+$#i;
              }
              # index.html の省略を調べる
              my $urlxquery = $1 if $url =~ /^([^?]*)[?]/;
              my $filespec = &NormalizeURL($urlxquery);
              if ($filespec =~ m#^(.*?)/$#) {
                &Whine($., 'conflict-directory', xc($TAG), xc($ATTR), $urlorg,
                       $indexhtml{$1}[0], $indexhtml{$1}[1]) if $indexhtml{$1};
                foreach (keys %indexhtml) {
                  if (m#^$filespec$::INDEXHTML$#i) {
                    &Whine($., 'index-html', xc($TAG), xc($ATTR), $urlorg,
                           $indexhtml{$_}[0], $indexhtml{$_}[1]);
                    last;
                  }
                }
              } else {
                my $dir = $filespec.'/';
                &Whine($., 'conflict-directory', xc($TAG), xc($ATTR), $urlorg,
                       $indexhtml{$dir}[0], $indexhtml{$dir}[1]) if $indexhtml{$dir};
                if ($filespec =~ m#(?:^|/)($::INDEXHTML)$#oi) {
                  substr($dir = $filespec, -length($1)) = '';
                  &Whine($., 'index-html', xc($TAG), xc($ATTR), $urlorg,
                         $indexhtml{$dir}[0], $indexhtml{$dir}[1]) if $indexhtml{$dir};
                }
              }
              $indexhtml{$filespec} = [ $., $urlxquery ];
            }
          } elsif (defined(&$syntax)) {
            if ($ok) {
              $ok = $url =~ /^$RFC2396::absoluteURI$/o && &$syntax($url);
            }
            if ($scheme eq 'file') {
              # file:/// まで見た方がいいかも
              &Whine($., 'local-protocol', xc($TAG), xc($ATTR), $urlorg)
                unless $opt_local;
            }
          }
        }
      }
    } else {
#     $ok = $url =~ /^$RFC2396::absoluteURI$/o;
      # 知らないスキームはチェックしない方がよい
      # 例えば javascript: などはネットワーク上を流れないので
      # RFC の守備範囲外かも知れず、どんな文字でも書けそうだ
      # 現に javascript:document.write("xxxx") などと普通に使われるだろう
    }
    if ($ok) {
      # URL が実存するか調べる (いつもチェックすると時間がかかる)
      if ($url ne '') {
        if ($chkurl) {
          defined($stathtml{$url}) or
          ($stathtml{$url} = &::AskHTML(($baseURL ne '')? $baseURL: $opt_base, $url));
          my ($stat, $rurl, $ctype, $length, $msg) = @{$stathtml{$url}};
          if ($stat < 200 || $stat >= 400) {
            $msg = join(' ', $stat, $msg);
            &Whine($., 'cant-get-url', xc($TAG), xc($ATTR), $url, 'インタネット上に', $msg);
          }
          &Whine($., 'trailing-slash', xc($TAG), xc($ATTR), $url)
            if $stat == 200 && $rurl =~ m#$url/$#i &&
               $url !~ m#^\w+://[^/]+$#; # ドメイン名だけの場合は除く
          if ($TAG eq 'IMG') {
            if ($ATTR eq 'SRC') {
              if ($rule =~ /^imode/) {
                &Whine($., 'unsupported-image', xc($TAG), xc($ATTR), $url,
                       ${$::doctypes{$rule}}{guide}, 'GIF')
                       if $ctype ne '' && $ctype ne 'image/gif';
                $readsize += $length;
              } elsif ($rule =~ /^jsky/) {
                &Whine($., 'unsupported-image', xc($TAG), xc($ATTR), $url,
                       ${$::doctypes{$rule}}{guide}, 'PNG')
                       if $ctype ne '' && $ctype ne 'image/png';
                $readsize += $length;
              } elsif ($rule =~ /^doti/) {
                &Whine($., 'unsupported-image', xc($TAG), xc($ATTR), $url,
                       ${$::doctypes{$rule}}{guide}, 'GIF または PNG')
                       if $ctype ne '' && $ctype !~ m#^image/(?:gif|png)$#;
                $readsize += $length;
              }
            }
          } elsif ($TAG eq 'FRAME') {
            if ($ATTR eq 'SRC') {
              &Whine($., 'frame-image', xc($TAG), xc($ATTR))
                if $ctype ne '' && $ctype !~ m#^\s*text/html( |;|$)#i;
            }
          }
        } elsif (!&CallCGI() && ($enabled{'cant-get-url'} > 0.0 || $opt_pedantic) &&
                 $scheme eq '') {
          # 暫定 ($opt_base とか見ていない)
          $url =~ s|\?.+$||; # queryを捨てる
          my $file = $htmlfile;
          $file =~ s|\\|/|g;
          $file =~ s|[^/]+$||;
          $file .= $url;
          unless (-e $file) {
            &Whine($., 'cant-get-url', xc($TAG), xc($ATTR), $url);
          }
        }
      }
    } elsif (!$whine) {
      &Whine($., 'illegal-format-url', xc($TAG), xc($ATTR), $urlorg);
    # &::PushStat('IllegalFormatURL', $urlorg) if !$illchar && $opt_stat;
    }
  }
  $reluri;
}

# 使えない文字をチェックする
sub CheckCharURL
{
  my ($urlscan, $url, $nowhine) = @_;
  my $whine = 0;
  while ($urlscan =~ /($RFC2396::delimunwise|$unsafeuri)(.*)/o) {
    $urlscan = $2;
    my $c = substr($1, 0, 1);
    next if $1 eq '\\'; # すでに警告済み
    next if $1 eq '%' && $urlscan =~ /^$RFC2396::hex2/o;
    unless ($nowhine) {
      my $x = sprintf('%%%02X', ord($c));
      &Whine($., ($c =~ /$unsafeuri/o)? 'unsafe-url': 'excluded-url',
                 xc($TAG), xc($ATTR), $url, $c, $x);
      $whine++;
    }
  }
  $whine;
}

##################################################
# URL を分解する (http のみ)

sub ParseURL
{
  my $url = shift;
  $url =~ s/^\s*//;
  my $proto = ($url =~ s#^(\w*:)##)? lc($1): '';
  my $host = ($url =~ s#^(//[^/]*)##)? $1: '';
  my $port = '';
  ($host, $port) = ($1, $2) if $host =~ /^((?:[^@]+\@)?.+)(:\d+)$/;
  my $path;
  my ($file, $flgid)  = $url =~ /^([^#]*)(#.*)?$/;
  ($path, $file) = ($1, $2) if $file =~ m#^(/(?:[^/]*/)*)([^/]*)$#;
  ($proto eq ':' || $host eq '//' || $port eq ':')?
    undef: ($proto, $host, $port, $path, $file, $flgid);
}

##################################################
# URL を絶対パスにする (http のみ)

sub AbsoluteURL
{
  my ($base, $url, $dport) = @_;
  my ($bproto, $bhost, $bport, $bpath, $bfile) = &ParseURL($base);
  my ($uproto, $uhost, $uport, $upath, $ufile, $flgid) = &ParseURL($url);
  if ($dport) {  # ==80
    $bport =~ s/^://;
    $uport =~ s/^://;
    $bport = $dport if $bhost ne '' && $bport eq '';
    $uport = $dport if $uhost ne '' && $uport eq '';
    $bport = ':'.($bport+0);
    $uport = ':'.($uport+0);
  } else {
    $flgid = ''; # 通常は捨てる
  }
  &NormalizeDots(
    (!($url ne '' && $upath eq '' && $ufile eq '') &&
     (($uproto eq '' || $uproto =~ /^http/i) && $bproto =~ /^http/i))?
        (($uproto ne '')? $uproto: $bproto).
        (($uhost  ne '')? $uhost.$uport: $bhost.$bport).
        (($upath  ne '')? $upath.$ufile: ($bpath.
        (($ufile  ne '')? $ufile: $bfile))).$flgid: $url);
}

##################################################
# URL 中の . を解決する
                            BEGIN {
sub NormalizeDots
{
  my @files;
  my ($domain, $filespec) = ('', shift);
  if ($filespec =~ m#^(\w+://(?:[^/]+))(.*)$#) {
    ($domain, $filespec) = ($1, $2);
  }
  $filespec .= '/' if $filespec =~ m#(?:^|/)\.\.?$#;
  foreach (split(m#/+#, $filespec, -1)) {
    next if $_ eq '.';
    if ($_ eq '..' && @files) {
      my $parent = pop(@files);
      next if $parent ne '' && $parent ne $_;
      push(@files, $parent);
    }
    push(@files, $_);
  }
  $domain.join('/', @files);
}
                                  }

##################################################
# URL を正規化する (httpのみ)

sub NormalizeURL
{
  my $url = shift;
  my ($domain, $filespec) = $url =~ m@^(\w+://[^/]+)?([^#\?]*)$@;
  $filespec = '/' if $domain !~ m#/$# && $filespec eq '';
  $domain =~ s#^(\w+://)#\L$1\E#;
  $filespec = &NormalizeDots($filespec);
  if ($filespec eq '' || ($domain eq '' && $filespec =~ m#^[^/.]#)) {
    $filespec = './'.$filespec;
  }
  $domain.$filespec;
}

##################################################
# URL を比較する

sub CompareURL
{
  my ($url1, $url2) = @_;
  my $base = ($baseURL ne '')? $baseURL: $opt_base;
  &AbsoluteURL($base, $url1, 80) eq &AbsoluteURL($base, $url2, 80);
}

##################################################
# URL からアンカー名を分離する

sub SplitFragmentID
{
  my $url = shift;
  my $scheme;
  { # scheme のところまで実体参照を解決する
    my $urlscan = $url;
    my $exurl = '';
    while ($urlscan =~ /^([^&]*)(&.*)/) {
      my ($scanned, $c) = ($1, $2);
      last if $scanned =~ /[:?#]/;
      ($urlscan, $c) = &CheckRefEntities($c, 1);
      $exurl .= $scanned.$c;
      last if $c eq ':';
    }
    $urlscan = $exurl.$urlscan;
    if ($urlscan =~ /^([^:?#]*):/) {
      $scheme = $1;
      if ($scheme !~ /^($RFC2396::scheme)$/o) {
        $scheme = substr($url, 0, length($url)-length($urlscan)+length($scheme)-1);
      }
    }
    $url = $urlscan if $scheme ne '';
  }
  my $spurl = $url;
  my $frgid;
  if ($scheme eq '' || $scheme =~ /^(?:$::httpSchemes)?$/oi) {
    my ($cref, $sharp) = ($htmlVer >= 4)? ('\d|x[0-9A-F]', '23|x17'): ('\d', '23');
    { # # の実体参照を解決する
      my $urlscan = $url;
      while ($urlscan =~ /^([^&]*)(&.*)/g) {
        my ($scanned, $ref) = ($1, $2);
        my $c;
        ($urlscan, $c) = &CheckRefEntities($ref, 2);
        if ($c eq '#') {
          $ref =~ /^([^;]+;)(.*)/;
          $url =~ s/$1/#/;
          last;
        }
        last if $c eq ':';
      }
    }
    if ($url =~ /#/) {
      my @parts = split(/#/, $url);
      $spurl = @parts? shift(@parts): '';
      if (@parts) {
        foreach (@parts) {
          my $amp = $spurl =~ /&$/;
          unless ($amp && /^$cref/i) {
            $frgid = '#'.substr($url, length($spurl)+1);
            last;
          }
          if (/^((?:$sharp)(?:;|$|(?=\D)))/i) {
            my $splen = length($1)+2;
            $spurl = substr($spurl, 0, length($spurl)-1);
            $frgid = '#'.substr($url, length($spurl)+$splen);
            last;
          }
          $spurl = $spurl.'#'.$_;
        }
      } else {
        $frgid = '#';
      }
    }
  }
  ($scheme, $spurl, $frgid);
}

##################################################
# CDATA 属性を評価する
# 属性は $value に入っており、結果もそこに入る

sub CDATA
{
# unless ($quot) {
    my $c;
    my $value2 = '';
    while ($value =~ /^([^<&>]*)([<&>])(.*)$/) {
      $value2 .= $1;
      if ($2 eq '&') {
        ($value, $c) = &CheckRefEntities($2.$3);
        $value2 .= $c;
      } else {
        $value2 .= $2;
        $value = $3;
        &WhineRefEntities($2);
      }
    }
    $value = $value2.$value;
# }
}

##################################################
# CDATA/RCDATA を読む
# CDATA/RCDATA の終了は、本来 </ であるがそうはしていない
# 読まれた文字列は捨てられる

sub ReadCDATA
{
  my $type = shift; # CDATA or RCDATA
  my $tag = $tagsNest[$#tagsNest]{tag};
  my ($start, $last, $pend);
  if (&GetLine =~ /^(<!--)($allc*)/o) {
    ($start, $line) = ($., $2);
  }
  my $elem = 0;
  while (&GetLine ne '') {
    my ($etag, $rest) = ('', '');
    ($line, $etag, $rest) = split(m#(</)#, $line, 2) if $line =~ m#</#;
    if ($line =~ /\S/ && $type eq 'CDATA' && $tag =~ /^${stylescript}$/oi) {
      if ($line =~ /^(.*)--\s*>\s*$/) {
        # --> を保留する
        ($line, $pend) = ($1, $.);
      } else {
        if ($pend) {
          &Whine($pend, ($htmlVer >= 4.5)? 'embedded-in-cdata': 'embedded-in-cdata-0', xc($tag), '--', &StyleOrScript($tag));
          undef $pend;
        }
      }
      while ($line =~ /(<|&|]]>|--)/g) {
        my $str = $1;
        &Whine($., ($htmlVer >= 4.5)? 'embedded-in-cdata': 'embedded-in-cdata-0', xc($tag), $str, &StyleOrScript($tag));
      }
    }
    if ($line =~ /\S/) {
      $elem++;
      $last = $line;
      if ($type eq 'RCDATA') {
        while ($line =~ /(&$allc*)/o) {
          ($line) = &CheckRefEntities($1);
        }
      }
    }
    if ($etag) {
      if ($rest =~ m#$tag[\s>]#i) {
        # 終わり
        $line = $etag.$rest;
        last;
      }
      &Whine($., 'etago-in-cdata', xc($tag)) if $type eq 'CDATA';
    }
    $line = $rest;
  }
  if ($elem && $tag =~ /^(?:$::commentedElement)$/oi) {
    if ($start) {
      &Whine($., 'unclosed-comment', xc($tag), $start) unless ($pend || $last =~ /--\s*>\s*$/);
    } else {
      &Whine($., 'comment-element', xc($tag));
    }
  }
}
sub StyleOrScript { (shift eq 'STYLE')? 'スタイルシート': 'スクリプト'; }

##################################################
# #PCDATA を読む
# 読まれた文字列は $pcdata にセットされる

sub ReadPCDATA
{
  $pcdata = '';
  my ($ln, $lnja);
  while () {
    if ($seenPre && $pretab) {
      &Whine($ln = $., 'tab-in-pre', xc('PRE'), $seenPre) if $ln != $.;
      $pcdata =~ s/\t/ /;
    }
    $pretab = 0;
    $pcdata .= ' ' if $line =~ /^\s+/;
    &SkipComment;
    last if $line eq '';
    if ($line =~ /^([^<&">]*)([<&">])($allc*)/o) {
      my ($pre, $delim, $rest) = ($1, $2, $3);
      $line = $delim.$rest;
      if ($delim eq '<' && $pre =~ /\S/ && $p_isnot_br != $. && 'P' =~ /^(?:$pairTags)$/) {
        my $chlin = uc($line);
        chomp($chlin);
        if ($chlin eq '<P>') {
          &Whine($., 'p-isnot-br', xc('P'), xc('BR'));
          $p_isnot_br = $.;
        }
      }
      if ($enabled{'lang-pcdata'} > 0.0 || $opt_pedantic) {
        if ($lnja != $. && &CheckLanguageCode($pre)) {
          &WhineLanguageCode($., 'lang-pcdata');
          $lnja = $.;
        }
      }
      $pcdata .= $pre;
      if ($delim eq '&') {
        $pcdata .= $line;
        ($line) = &CheckRefEntities($line);
        substr($pcdata, -length($line)) = '';
      } else {
        last if $delim ne '"' && &CheckTag ne '';
        &WhineRefEntities($delim);
        $pcdata .= $delim;
        $line = $rest;
      }
    } else {
      if ($enabled{'lang-pcdata'} > 0.0 || $opt_pedantic) {
        if ($lnja != $. && &CheckLanguageCode($line)) {
          &WhineLanguageCode($., 'lang-pcdata');
          $lnja = $.;
        }
      }
      $pcdata .= $line;
      $line = '';
    }
    $pretab++ if $pcdata =~ /\t/;
  }
  if ($pcdata =~ /^(.*?)(\s+)$/) {
    # 後行する空白は戻す
    $line = $2.$line;
    $pcdata = $1;
  }
}

##################################################
# 開きタグかどうかチェックする
# $line が開きタグなら < から始まる文字列が返る

sub CheckTag
{
  my $tag = '';
  if ($line =~ m#^(<(?:(\s*)/?($nameStr)|!(?:$nameStr)?))#) {
    $tag = $1;
    # 空白が含まれているときは正しいタグのみ通す
    $tag = '' if $2 ne '' && $3 !~ /^(?:$allTags)$/i;
  }
  $tag;
}

##################################################
# 開きタグを得る
# $token に < を含む文字列が求まる
# < と空白を取り除いて大文字にした文字列が返る
# 次のトークンが開きタグでない場合は空文字列

sub GetTag
{
  my $tag = '';
  my $leadingspace = &SkipComment;
  if (($token = &CheckTag) =~ /^<(.*)/) {
    $tag = $1;
    &Whine($., 'leading-whitespace', '', xc(uc($tag))) if $tag =~ s/\s+//g;
    &CheckCase($tag, 0) unless $tag =~ /!/;
    $line = substr($line, length($token));
  }
  $token = ' '.$token if $leadingspace;
  $tag;
}

##################################################
# $token を $line に戻す

sub UnGetToken
{
  $line = $token.$line;
}

##################################################
# 閉じタグ > まで読み飛ばす
# 途中に何か文字があれば 1 が返る

sub AdvanceCloseTag
{
  my ($tag, $ln) = @_;
  if (&GetLine =~ m#^>($allc*)#o) {
    $line = $1;
    return 0;
  }
  my $ret = $line ne '';
  if ($ret) {
    while (&GetLine ne '') {
      if ($line =~ m#([<>])($allc*)#o) {
        if ($1 eq '<') {
          &Whine($., 'unexpected-open', xc($tag));
        } else {
          $line = $2;
        }
        return 1;
      }
      $line = '';
    }
  }
  &Whine($., 'unclosed-tag', xc($tag), $ln);
  $ret;
}

##################################################
# 文字数を勘定する

sub StrLength
{
  my $str = shift;
  my $len = 0;
  my $dbcs;
  $str =~ s/^&($nameStr|#\d+)/a/g; # 実体参照を1文字に勘定
  $str =~ s/^&(#x[0-9A-F]+)/x/gi if $htmlVer >= 4;
  foreach (unpack('C*', $str)) {
    if ($dbcs) {
      undef $dbcs;
    } else {
      $len++;
      $dbcs = $_ >= 0x0080; # sjis/euc の DBCS を想定
    }
  }
  $len;
}

##################################################
# 大文字小文字をチェックする

sub CheckCase
{
  my ($id, $typ) = @_; # $typ=0:TAG =1:ATTR
  if    ($id eq lc($id)) { $lcase[$typ]++; $lcaseln[$typ] = $.; }
  elsif ($id eq uc($id)) { $ucase[$typ]++; $ucaseln[$typ] = $.; }
  else                   { $xcase[$typ]++; $xcaseln[$typ] = $.; }
}

##################################################
# $TAG の属性名を $token と $ATTR に得る

sub GetAttrName
{
  $token = $ATTR = $subATTR = '';
  my $leadingspace = $line =~ /^(?:\s|$)/;
  while (&GetLine ne '') {
    if ($xhtml && $line =~ m#^(/?)(>$allc*)#) {
      if ($1) {
        $line = '></'.xc($TAG).$2;
        if (!$xml) {
          if (!$tagsElements{$TAG}) {
            unless ($leadingspace) {
              &Whine($., 'leading-space-endtag-slash', xc($TAG));
            }
          } else {
            &Whine($., 'noempty-endtag-slash', xc($TAG));
          }
        }
      } else {
        if (!$tagsElements{$TAG}) {
          $minetag = $TAG;
          &Whine($., 'contain-no-space', xc($TAG)) if $line =~ m#^>\s#;
        }
      }
    }
    if ($line =~ m#^($nameStr|>)($allc*)#) {
      ($token, $line) = ($1, $2);
      if ($token ne '>') {
        &CheckCase($token, 1);
        if ($xhtml && $token ne lc($token)) {
          &Whine($., 'lower-case-attribute', xc($TAG), $token) if $TAG =~ /^(?:$allTags)$/ && $tagsAttributes{$TAG}->{uc($token)} ne '';
        }
        $ATTR = $token;
        if ($xhtml) {
          $ATTR =~ s/^\s+//;
          $ATTR =~ s/\s+$//;
          $ATTR =~ s/\s+/ /;
          $oATTR = $ATTR;
        } else {
          $oATTR = uc($ATTR);
        }
        $ATTR = uc($ATTR);
        if (!$leadingspace) {
          &Whine($., $xhtml? 'leading-space-attribute': 'leading-space-attribute-html', xc($TAG), xc($oATTR))
        }
        if ($ATTR =~ /^([^:]+:)(.*)/) {
          # IE5 の XMLNS:namespace 対応
          my ($xmlns, $suffix) = ($1, $2);
          foreach (keys %tagsAttributes) {
            if ($tagsAttributes{$_}->{$xmlns} ne '') {
              &Whine($., 'unsupported-attribute', xc($TAG), xc($ATTR));
              ($ATTR, $subATTR) = ($xmlns, $suffix);
              push(@xmlns, $subATTR);
              last;
            }
          }
        }
      }
      last;
    }
    chomp($line);
    my ($rest, $mid);
    if ($line =~ /^([^\s\x21-\x2F\x3A-\x3F]*)([\s\x21-\x2F\x3A-\x3F])($allc*)/o) {
      ($rest, $mid, $line) = ($1, $2, $3);
      if ($mid =~ /[<\s>]/) {
        $line = $mid.$line;
      } else {
        $rest .= $mid;
      }
      if ($line =~ /^</) {
        &Whine($., 'unexpected-open', xc($TAG));
        $line = '>'.$line;
      } else {
        if (!$xhtml && $rest eq '/' && $line =~ /^>/) {
          &Whine($., 'xhtml-emptytag', ${$::doctypes{$rule}}{guide}, xc($TAG));
        } else {
          &Whine($., 'illegal-attribute', xc($TAG), $rest);
        }
      }
    } else {
      $rest = $line;
      $line = '';
      &Whine($., 'illegal-attribute', xc($TAG), $rest);
    }
  }
  $ATTR;
}

##################################################
# $TAG の属性 $ATTR の属性値を $token に得る
# $quot に引用符の種類が入る

sub
GetAttrValue
{
  $quot = '';
  $token = '';
  if (&GetLine =~ /^(["'])($allc*)/o) {
    ($quot, $line) = ($1, $2);
    my $quotregexp = "[<$quot>]";
    my $notquotregexp = "[^<$quot>]";
    my $across = 0;
    while () {
      if ($line =~ /^($notquotregexp*)($quotregexp)($allc*)/) {
        if ($2 eq $quot) {
          $token .= $1;
          $line = $3;
#         if ($token eq '') {
#           &Whine($., 'empty-value', xc($TAG), xc($ATTR));
#         }
          if ($quot eq "'") {
            ($quot = $token) =~ s/"/&quot;/g;
            &Whine($., 'attribute-delimiter', xc($TAG), xc($ATTR), $token, $quot);
          }
          last;
        } elsif ($2 eq '>') {
          $token .= $1;
          $line = $3;
#         if ($line =~ /^[^<"'>]*$quot/) {
#           後続に引用符があり、< も > もそれ以前に現われないときは
#           引用符が閉じられているとみなしてもよい
#           $token .= '>';
#           &WhineRefEntities('>');
#         } else {
            $line = '>'.$line;
            &Whine($., 'unclosed-quotes', xc($TAG), xc($ATTR));
            last;
#         }
        } else {
          $token .= $1.$2;
          $line = $3;
          &WhineRefEntities($2);
        }
      } else {
        chomp($line);
        $token .= $line.' ';
        $line = '';
        if (&GetLine eq '') {
          &Whine($., 'unclosed-quotes', xc($TAG), xc($ATTR));
          last;
        }
        $across++;
      }
    }
    &Whine($., 'across-lines-attribute', xc($TAG), xc($ATTR)) if $across;
  } else {
    $line =~ /^([^<\s>]+)($allc*)/o;
    ($token, $line) = ($1, $2);
    &Whine($., ($token eq '')? 'no-attribute-value':
               ($token !~ /^$tokenStr$/ || &StrLength($token) > 72 || $xhtml)?
                 'quote-attribute-value':
               ($token !~ /^$stdTokenStr$/)?
                 'recommend-quote-attribute-value': 'bare-attribute-value',
                 $oTAG, $oATTR, $token)
  }
  $token;
}

##################################################
# コメント <!-- --> を読み飛ばす
# <!SGML...> 等の SGML宣言/DTD宣言も読み飛ばす
# <?...> 等の XML宣言も読み飛ばす
# <![CDATA[...]]> 等のマーク区間をある程度考慮する

sub SkipComment
{
  my $leadingspace = $line =~ /^\s/;
  while (@markedSection && &GetLine =~ /^(.*?)]\s*]\s*>($allc*)/o) {
    $line = $1.$2;
    &CheckMarkedSection($1);
    $leadingspace = $line =~ /^\s/;
    pop(@markedSection);
  }
  while (&GetLine ne '') {
    if ($line =~ /^(<!(-{0,3}(\s*)!?)>)($allc*)/o) {
      $line = $4;
      if ($2 eq '') {
        &Whine($., 'empty-comment', $1);
        &Whine($., 'title-comment', xc($TAG)) if $TAG eq 'TITLE';
      } else {
        &Whine($., 'illegal-comment', $1);
      }
      &Whine($., 'space-in-closed-comment') if $3 ne '';
      next;
    }
    if ($line =~ /^<(![A-Za-z]+|\?)($allc*)/o) {
      my $token = uc($1);
      if ($token ne '!DOCTYPE') {
        my $tof = $readsize == length($line);
        $line = $2;
        if ($token eq '?') {
          $seenXml = ($line =~ /^xml[^\w\.\-]/)? $.: 0;
          #$seenXmlStylesheet = ($line =~ /^xml-stylesheet[^\w\.\-]/)? $.: 0;
          &Whine($., 'processing-instruction') unless $seenXml;
          &Whine($., 'misplaced-xmldecl') if $seenXml && !$tof;
        } else {
          &Whine($., 'ignore-declaration', '', $token);
#         &::PushStat('IgnoreDeclaration', $token) if $opt_stat;
        }
        while (&GetLine ne '') {
          if ($line =~ /^([^>]*)>($allc*)/o) {
            $line = $2;
            if ($seenXml) {
              $xmldecl .= $1;
              if ($xmldecl =~ /^(.*)\?$/) {
                $xmldecl = $1;
              } else {
                &Whine($., 'end-xmldecl');
              }
              &Whine($., 'bad-xmldecl') if $xmldecl !~ /^xml\s+version\s*=\s*(?:'1\.0'|"1\.0")(?:\s+encoding\s*=\s*(?:'[A-Za-z][A-Za-z0-9._\-]*'|"[A-Za-z][A-Za-z0-9._\-]*"))?(?:\s+standalone\s*=\s*(?:'(?:yes|no)'|"(?:yes|no)"))?\s*$/;
              if ($xmldecl =~ /\bencoding\s*=\s*["']([^"']+)["']/) {
                my $xc = $1;
                &CheckCHARSET($xc, 'HTTPレスポンスヘッダ', $opt_charset, 'XML宣言');
                $xcharset = $xc;
                $seenCharset = $.;
              }
            }
            return &SkipComment;
          } else {
            if ($seenXml) {
              chomp($line);
              $xmldecl .= $line.' ';
            }
          }
          $line = '';
        }
      }
    }
    if ($line =~ /^<!\[\s*([^\[\]]+)\s*\[?($allc*)/o) {
      my $mark = $1;
      $line = $2;
      &Whine($., 'marked-section', '', $mark);
      push(@markedSection, [ $mark, $., $#tagsNest ]);
      if ($htmlVer >= 4) {
        if (uc($mark) eq 'CDATA') {
          while (&GetLine ne '') {
            if ($line =~ /^(.*?)]]>($allc*)/o) {
              $line = $2;
              &CheckMarkedSection($1);
              pop(@markedSection);
              return &SkipComment;
            }
            &CheckMarkedSection($line);
            $line = '';
          }
        }
      }
      last;
    }
    last if $line =~ /^(?:[^<]|<[^!]|<![A-Za-z])/;
    my $ln = $.;
#   my ($whine_hyphens, $hyphen);
    my ($whine_markup, $markup, $closed);
    $line =~ /^(<!-{0,2})($allc*)/o;
    $line = $2;
    my $ill = $1 eq '<!';
    if ($1 ne '<!--') {
      &Whine($., 'illegal-comment', $1)
    } else {
      &Whine($., 'title-comment', xc($TAG)) if $TAG eq 'TITLE';
      if ($htmlVer >= 4.5 && $TAG =~ /^${stylescript}$/oi) {
        &Whine($., 'comment-in-stylescript', xc($TAG));
      }
    }
    while (&GetLine ne '') {
      unless ($line =~ /(<|--|-?>)($allc*)/o) {
        $line = '';
        next;
      }
      my $pre = $1;
      $line = $2;
      if ($pre eq '--') {
        if ($line =~ /^(!?)(\s*)>($allc*)/o) {
          $line = $3;
          &Whine($., 'space-in-closed-comment') if $2 ne '';
          &Whine($., 'illegal-closed-comment', '--!>') if $1 ne '';
          $closed = 1;
          $leadingspace++ if $line =~ /^\s/;
          last;
        }
        $line = '--'.$1 if $line =~ /^-+($allc*)/o;
#       if (!$whine_hyphens && $. != $hyphen) {
          &Whine($., ($htmlVer >= 4)? 'excluded-w-hyphens-in-comment':
                                               'w-hyphens-in-comment');
#       }
#       $whine_hyphens = $hyphen = $.;
      } elsif ($pre eq '->') {
        &Whine($., 'illegal-closed-comment', '', $pre);
        $closed = 1;
        last;
      } elsif ($ill && $pre =~ />$/) {
        $closed = 1;
        last;
      } else {
        if ($pre eq '<' && $htmlVer >= 4.5 && $TAG =~ /^${stylescript}$/oi) {
          my $etag;
          { local $line = '<'.$line; $etag = &CheckTag; }
          if (uc($etag) eq "</$TAG") {
            # <STYLE><SCRIPT> ではコメント閉じ忘れとみなす
            $line = '<'.$line;
            last;
          }
        }
        if ($pre eq '<' && $line =~ /^!--($allc*)/o) {
          $line = $1;
          &Whine($., 'nested-comment');
        } elsif (!$whine_markup && $. != $markup) {
          &Whine($., 'markup-in-comment');
        }
        $whine_markup = $markup = $.;
      }
    }
    &Whine($., 'unclosed-comment', '', $ln) unless $closed;
  }
  $leadingspace;
}

sub CheckMarkedSection
{
  my $line = shift;
  my $section = $markedSection[0]->[0];
  my $parent = $tagsNest[$#tagsNest]{tag};
  my %checked;
  if ($section ne 'CDATA') {
    while ($line =~ /(<|&)/g) {
      my $str = $1;
      &Whine($., 'badstr-in-marked-section', '', $str) if !$checked{$str}++;
    }
  } elsif ($parent =~ /^${stylescript}$/oi) {
    while ($line =~ /(<|&|--)/g) {
      my $str = $1;
      &Whine($., 'embedded-in-cdata', xc($parent), $str,
             &StyleOrScript($parent), 'のマーク区間 <![CDATA 〜 ]]> 内') if !$checked{$str}++;
    }
  }
}

##################################################
# <!DOCTYPE...>

sub Doctype
{
  $HTML = 'HTML';
  my ($type, @whines, $tag, $lwspace, $doctypeline, $dln, $predoctype, $orgdoctype);
  my ($guide0, $guide1, $guide2, $guide3, $guide4);
  my ($expired, $obsoleted);
  if ($line eq '') {
    $line = <HTML>;
    $readsize += length($line);
  }
  my $firstline = $line;
  &SkipComment;
  undef $xhtml;
  $procdoctype = 1;
  if ($line =~ /^([^<]*)<(!DOCTYPE)($allc*)/oi) {
    $predoctype = $1;
    $orgdoctype = $2;
    $line = $3;
    if ($predoctype ne '') {
      if ($predoctype =~ /[\00-\x08\x0B\x0C\x0E-\x1F\x7F]/) {
        push(@whines, 'prectrl-doctype');
      }
      push(@whines, 'required-doctype');
    }
  }
  if ($orgdoctype eq '') {
    push(@whines, 'required-doctype');
    &UnGetToken;
  } else {
    $tag = uc($orgdoctype);
    $dln = $.;
    while (&GetLine ne '') {
      if ($line =~ /^([^<>]*)([<>])($allc*)/o) {
        $line = $2.$3;
        $doctypeline = &Join(' ', $doctypeline, $1);
        last;
      }
      chomp($line);
      $doctypeline = &Join(' ', $doctypeline, $line);
      $line = '';
    }
    $doctypeline =~ s/^\s+//;
    foreach my $guess (0..1) {
      foreach (keys %::doctypes) {
        my $doctype = ${$::doctypes{$_}}{doctype};
        if ($doctype ne '' && $doctypeline =~ /^($doctype)/i) {
          my $sysid = substr($doctypeline, length($1));
          $sysid = ($sysid =~ /^\s*["'](.+)["']/)? $1: '';
          my $rulsysid = ${$::doctypes{$_}}{system};
          if ($guess == 0 && $rulsysid) {
            if (${$::doctypes{$_}}{version} >= 4.5 || $sysid ne '') {
#             next if $sysid eq '' || ($rulsysid !~ /$sysid$/i && $sysid !~ /$rulsysid$/i);
              next if $sysid eq '' || $sysid !~ /$rulsysid$/i;
            }
          }
          my $sep = q|\[\"\'\]|;
          my ($public, $pubid) = $doctype =~ /(PUBLIC)?\\s\+($sep.+$sep)/oi;
          $type = $_;
          $obsoleted = ${$::doctypes{$_}}{obsoleted};
          $expired = ${$::doctypes{$_}}{expired};
          push(@whines, 'doctype-case-mismatch') if $public && $doctypeline !~ /$pubid/;
          if ($guess) {
            push(@whines, ($sysid eq '')? 'empty-systemid': 'illegal-systemid');
          } elsif ($sysid ne '' && $rulsysid !~ /$sysid$/ && $sysid !~ /$rulsysid$/) {
            push(@whines, 'systemid-case-mismatch');
          }
          last;
        }
      }
      last if $type;
    }
    unless ($type) {
      foreach (keys %::xdoctypes) {
        my $doctype = ${$::xdoctypes{$_}}{doctype};
        if ($doctype ne '' && $doctypeline =~ /^(?:$doctype)/i) {
          $type   = ${$::xdoctypes{$_}}{subst};
          $guide3 = ${$::xdoctypes{$_}}{guide};
          last;
        }
      }
      if ($type) {
        $expired = ${$::doctypes{$type}}{expired};
        $guide2 = ${$::doctypes{$type}}{abbr}.' とみなします。';
        push(@whines, 'unsupported-doctype');
      } else {
        unless ($opt_igndoctype) {
          foreach (keys %::xdoctypes) {
            my $doctype = ${$::xdoctypes{$_}}{guess};
            if ($doctype ne '' && $doctypeline =~ /(?:$doctype)/i) {
              $type = ${$::xdoctypes{$_}}{subst};
              last;
            }
          }
          unless ($type) {
            foreach (keys %::doctypes) {
              my $doctype = ${$::doctypes{$_}}{guess};
              if ($doctype ne '' && $doctypeline =~ /(?:$doctype)/i) {
                $type = $_;
                last;
              }
            }
          }
          if ($type) {
            $expired = ${$::doctypes{$type}}{expired};
            $guide2 = ${$::doctypes{$type}}{abbr}.' とみなします。';
          }
        }
        push(@whines, 'unknown-doctype');
      # &::PushStat('UnknownDoctype', $doctypeline) if $opt_stat;
      }
    }
  }
  if ($opt_x) {
    foreach (keys %::doctypes) {
      if ($opt_x =~ /^(?:${$::doctypes{$_}}{name})$/i) {
        $rule = $_;
        $guide2 = '';
        last;
      }
    }
    print '規則ファイル '.$opt_x.' は登録されていません。'."\n" unless $rule;
  }
  $rule = $type if !$opt_igndoctype && $type;
  my $mismatch = !@whines && $rule && $type ne $rule;
  if ($mismatch) {
    my $superset = ${$::doctypes{$rule}}{superset};
    foreach (split(/\|/, $superset)) {
      my $doctype = ${$::doctypes{$_}}{doctype};
      if ($doctype ne '' && $doctypeline =~ /^(?:$doctype)/i) {
        $mismatch = 0;
        last;
      }
    }
  }
  if ($obsoleted) {
    push(@whines, 'obsoleted-doctype');
    $guide0 = ${$::doctypes{$type}}{guide};
    $guide4 = ${$::doctypes{$obsoleted}}{guide}
  } elsif ($expired) {
    push(@whines, 'expired-doctype');
    $guide0 = $expired;
  }
  $rule = $type unless $rule;
  $rule = $::defaultrule unless $rule;
  # 各 DOCTYPE に対応した規則
  my $file = $rule.'.rul';
  if ($file ne $rulefile && !&ReadRule($file)) {
    print '指定された DOCTYPE に対応する規則ファイルが見つかりません。'."\n";
    $rule = ($rule eq $type)? '': $type;
    $rule = $::defaultrule unless $rule;
    $file = $rule.'.rul';
    $mismatch = 0;
    return 1 unless &ReadRule($file);
  }
  $allTags = &Join('|', $emptyTags, $pairTags);
  push(@whines, 'doctype-mismatch') if $mismatch;
  print STDERR "$htmlfile\n" if $opt_echoname;
  $guide1 = ${$::doctypes{$rule}}{guide};
  print $htmlfile.' を '.$guide1.' としてチェックします。'."\n" if $opt_banner;
  foreach (@whines) { &Whine($., $_, $guide0, $guide1, $guide2, $guide3, $guide4); }
  &AdvanceCloseTag($tag, $.) if $tag ne '';
  # HTML4 では名前文字に _ と : が追加されている
  $htmlVer = ${$::doctypes{$rule}}{version};
  $xhtml = $htmlVer >= 4.5;
  $xml = ($xhtml && $opt_mime eq 'application/xhtml+xml') || ($htmlVer >= 4.6);
  $isohtml = ${$::doctypes{$rule}}{group} eq 'ISO15445';
  $nameChr    = ($htmlVer >= 4)? '[A-Za-z0-9\.\-_:]': $stdNameChr;
  $nameStr    = ($xhtml? '[A-Za-z_]': '[A-Za-z]').$nameChr.'*';
  $idStr      = $xhtml? '[A-Za-z_][A-Za-z0-9\.\-_]*': $nameStr;
  $tokenStr   = $nameChr.'+';
  $nutokenStr = '\d'.$nameChr.'*';
  %tokenizedType = (
    NAME     => $nameStr,
    NAMES    => $nameStr.'(\s+'.$nameStr.')*',
    NMTOKEN  => $tokenStr,
    NMTOKENS => $tokenStr.'(\s+'.$tokenStr.')*',
    NUTOKEN  => $nutokenStr,
    NUTOKENS => $nutokenStr.'(\s+'.$nutokenStr.')*',
    NUMBER   => $digits,
    'NUMBER+'=> $digits,
    NUMBERS  => $digits.'(\s+'.$digits.')*',
    ENTITY   => $nameStr,
    ENTITIES => $nameStr.'(\s+'.$nameStr.')*',
    ID       => $idStr,
    IDREF    => $idStr,
    IDREFS   => $idStr.'(\s+'.$idStr.')*',
  );
  $noOmitEtag = $::noOmissibleEndTags;
  if (${$::doctypes{$rule}}{doctype} =~ /^([\w\.\-]+)/) {
    $HTML = uc($1);
  }
  if ($rule =~ /^mozilla/) {
    $noOmitEtag .= '|TD|TH';
  }
  if ($rule =~ /^jpo/) {
    &Whine($., 'jpo-no-html', xc($HTML), ${$::doctypes{$rule}}{guide})
      unless $firstline =~ /^<\s*HTML\s*>/i;
  }
  my ($html, $public) = $doctypeline =~ /^([\w\.\-]+)\s+(\w+)/;
  if ($xhtml) {
    &Whine($dln, 'xhtml-xmldecl', '', ${$::doctypes{$rule}}{group}) unless $xmldecl;
    &Whine($dln, 'lower-case-doctype', '', $html) if $html ne lc($html);
    $omitStartTags = $omitEndTags = '';
  }
  if ($htmlVer >= 4.5) {
    my @nouc;
    push @nouc, "`$orgdoctype`" if $orgdoctype ne uc($orgdoctype);
    push @nouc, "`$public`" if $public ne uc($public);
    &Whine($dln, 'upper-case-doctype', '', join(' や ', @nouc)) if @nouc;
  }
  0;
}

##################################################
# 行を $line に読む。EOF なら空文字列が返る。

sub GetLine
{
  for (;;) {
    # 先行空白を捨てる
    $line =~ s/^(\s+)//;
    $pretab += $1 =~ /\t/;
    last if $line ne '';
    $line = ($ungetl ne '')? $ungetl: <HTML>;
    $ungetl = '';
    $readsize += length($line);
    if ($line eq '' && eof) {
      unless ($reacheof) {
        $.++;
        $reacheof = 1;
      }
      last;
    }
    if (!defined($textcode)) {
      if (!defined($charset) || $jcharcode) {
        if ($bom) {
          if ($bom eq "\xEF\xBB\xBF") { # UTF-8 以外は無視
            $textcode = 'utf8';
          } else {
            $textcode = '';
          }
        } else {
#         # 日本語のときのみ $textcode が設定される ⇒ やめ
#         if (${$lang}{val} ne '' && ${$lang}{val} !~ /^(?:ja|jpn)(?:-JP)?$/i) {
#           $textcode = '';
#         } else {
           $textcode = &DetectEncoding(\$line);
           if ($fromfile && $textcode =~ /^(?:euc|sjis|utf8)$/) {
             # 誤判定を回避しようと努力してみる
             my $tell = tell(HTML);
             my $buff;
             my %app = ( $textcode=>1 );
             foreach (1..10) { # 10回程度でよかろう
               read(HTML, $buff, 1024) or last;
               my $code = &DetectEncoding(\$buff);
               next unless $code;
               if ($app{$code}++) {
                 $textcode = $code;
                 last;
               }
             }
             seek(HTML, $tell, 0);
           }
#         }
        }
        if ($textcode ne '' && &CallCGI()) {
          # 注意 : CGIからの呼び出しのとき
          $::TXTCODE = $textcode;
        }
      } else {
        $textcode = '';
      }
    }
    if ($nonAsciiEarly == 0 && !$metaCharset && !$xcharset && $textcode ne 'jis' && 'META' =~ /^(?:$allTags)$/) {
      my @s = split(/(<META\s[^>]*>)/i, $line, 2);
      $line = $s[0].$s[1];
      $ungetl = $s[2];
      if ($line =~ /[^\x09\x0A\x0D\x20-\x7E]/) {
        &Whine($., 'non-ascii-early', xc('META'),
               xc('HTTP-EQUIV="CONTENT-TYPE" CONTENT').'="〜"', xc('CHARSET'));
        $nonAsciiEarly++; # 一度にしないと悲惨
      }
    }
    if (!$opt_igncharset) {
      if (($charset eq 'usascii' || $textcode eq 'jis') && $line =~ /[\x7F-\xFF]/) {
        &Whine($., 'non-ascii');
      }
      if ($textcode eq 'jis' && $line =~ /\e\(I/) {
        &Whine($., (${$::doctypes{$rule}}{restrict} & $::restrictkana)?
                                'han-katakana-0': 'han-katakana');
      } elsif ($textcode eq 'sjis' && $line =~ /[\xA0-\xDF]/) {
        my $esc = 0;
        foreach (unpack('C*', $line)) {
          $esc = 2 if $esc <= 0 && ((0x0081 <= $_ && $_ <= 0x009F) ||
                                    (0x00E0 <= $_ && $_ <= 0x00FC));
          if ($esc-- <= 0) {
            if (0x00A0 <= $_ && $_ <= 0x00DF) {
              &Whine($., (${$::doctypes{$rule}}{restrict} & $::restrictkana)?
                                'han-katakana-0': 'han-katakana');
              last;
            }
          }
        }
      }
      my $deesc = $line;
      if ($textcode && $escapeseq{$textcode}) {
        $deesc =~ s/$escapeseq{$textcode}//og;
      }
      if ($deesc =~ /([\x00-\x08\x0B\x0C\x0E-\x1F])/) {
        &Whine($., 'ctrl-character', '', $1); # 代表一文字でよかろう
      }
    }
    if ($Jcode && $textcode =~ /^(?:utf8)$/) {
      &Jconvert(\$line, $myCODE, $textcode);
    } elsif ($textcode =~ /^(?:jis|euc|sjis)$/) {
      &Jconvert(\$line, $myCODE, $textcode) if $myCODE ne $textcode;
      if ($line =~ /[\x80-\xFF]/) {
        my $bad = '';
        if ($myCODE eq 'euc') {
          # G3 は考慮しない
          my $c = 0;
          foreach (unpack('C*', $line)) {
            if ($c) {
              if (0x00A1 <= $_ && $_ <= 0x00FE && $c != 0x008E) {
                my $n = ($c<<8)|$_;
                if ($rule =~ /^jpo/ && $n == 0xA2A3) {
                  &Whine($., 'jpo-bad-char', '', ${$::doctypes{$rule}}{guide}, '■');
                }
                unless (($n < 0xB0A1)?
                          ($n < 0xA4A1)?
                            ($n < 0xA3B0)?
                              ($n < 0xA2DC)?
                                ($n < 0xA2BA)? (0xA1A1 <= $n && $n <= 0xA2AE):
                                ($n < 0xA2CA)? ($n <= 0xA2C1):
                                               ($n <= 0xA2D0):
                                ($n < 0xA2F2)? ($n <= 0xA2EA):
                                               ($n <= 0xA2F9 || $n == 0xA2FE):
                              ($n < 0xA3C1)? ($n <= 0xA3B9): # 数字
                              ($n < 0xA3E1)? ($n <= 0xA3DA): # 英大文字
                                             ($n <= 0xA3FA): # 英小文字
                            ($n < 0xA6A1)?
                              ($n < 0xA5A1)? ($n <= 0xA4F3): # ひらがな
                                             ($n <= 0xA5F6): # カタカナ
                              ($n < 0xA7A1)?
                                ($n < 0xA6C1)? ($n <= 0xA6B8): # ギリシャ大文字
                                               ($n <= 0xA6D8): # ギリシャ小文字
                                ($n < 0xA8A1)?
                                  ($n < 0xA7D1)? ($n <= 0xA7C1): # ロシア大文字
                                                 ($n <= 0xA7F1): # ロシア小文字
                                                 ($n <= 0xA8C0): # 罫線素片
                          ($n < 0xD0A1)? ($n <= 0xCFD3):   # 第一水準漢字
                                         ($n <= 0xF4A6)) { # 第二水準漢字
                  $c = pack('CC', $c, $_);
                  foreach (keys %{${$::doctypes{$rule}}{alloweuc}}) {
                    if ($n >= $_ && $n <= ${$::doctypes{$rule}}{alloweuc}{$_}) {
                      $c = '';
                      last;
                    }
                  }
                  if ($c ne '') {
                    $bad .= $c;
                    &::PushStat('BadJISX0208', $c) if $opt_stat;
                  }
                }
              }
              $c = 0;
            } elsif ((0x00A1 <= $_ && $_ <= 0x00FE) || $_ == 0x008E) {
              $c = $_;
            }
          }
        } elsif ($myCODE eq 'sjis') {
          my $c = 0;
          foreach (unpack('C*', $line)) {
            if ($c) {
              if ((0x0040 <= $_ && $_ <= 0x007E) ||
                  (0x0080 <= $_ && $_ <= 0x00FC)) {
                my $n = ($c<<8)|$_;
                if ($rule =~ /^jpo/ && $n == 0x81A1) {
                  &Whine($., 'jpo-bad-char', '', ${$::doctypes{$rule}}{guide}, '■');
                }
                unless (($n < 0x889F)?
                          ($n < 0x829F)?
                            ($n < 0x824F)?
                              ($n < 0x81DA)?
                                ($n < 0x81B8)? (0x8140 <= $n && $n <= 0x81AC):
                                ($n < 0x81C8)? ($n <= 0x81BF):
                                               ($n <= 0x81CE):
                                ($n < 0x81F0)? ($n <= 0x81E8):
                                               ($n <= 0x81F7 || $n == 0x81FC):
                              ($n < 0x8260)? ($n <= 0x8258): # 数字
                              ($n < 0x8281)? ($n <= 0x8279): # 英大文字
                                             ($n <= 0x829A): # 英小文字
                            ($n < 0x839F)?
                              ($n < 0x8340)? ($n <= 0x82F1): # ひらがな
                                             ($n <= 0x8396): # カタカナ
                              ($n < 0x8440)?
                                ($n < 0x83BF)? ($n <= 0x83B6): # ギリシャ大文字
                                               ($n <= 0x83D6): # ギリシャ小文字
                                ($n < 0x849F)?
                                  ($n < 0x8470)? ($n <= 0x8460): # ロシア大文字
                                                 ($n <= 0x8491): # ロシア小文字
                                                 ($n <= 0x84BE): # 罫線素片
                          ($n < 0x989F)? ($n <= 0x9872):   # 第一水準漢字
                                         ($n <= 0xEAA4)) { # 第二水準漢字
                  $c = pack('CC', $c, $_);
                  foreach (keys %{${$::doctypes{$rule}}{allowsjis}}) {
                    if ($n >= $_ && $n <= ${$::doctypes{$rule}}{allowsjis}{$_}) {
                      $c = '';
                      last;
                    }
                  }
                  if ($c ne '') {
                    $bad .= $c;
                    &::PushStat('BadJISX0208', $c) if $opt_stat;
                  }
                }
                $c = 0;
              } else {
                $c = ((0x0081 <= $_ && $_ <= 0x009F) ||
                      (0x00E0 <= $_ && $_ <= 0x00FC))? $_: 0;
              }
            } elsif ((0x0081 <= $_ && $_ <= 0x009F) ||
                     (0x00E0 <= $_ && $_ <= 0x00FC)) {
              $c = $_;
            }
          }
        }
        &Whine($., 'bad-jis-x0208', '', $bad) if $bad ne '';
      }
    }
  }
  $line;
}

##################################################
# 文字列を連結する
# join() では空文字列も連結してしまうがこれは空文字列は捨てる

sub Join
{
  my $sep = shift;
  my $str = '';
  foreach (@_) { $str = ($str ne '')? $str.$sep.$_: $_ if $_ ne ''; }
  $str;
}

##################################################
# 警告に付加するタグ列/属性値列のガイド文字列を作る

sub FormatGuide
{
  my ($s, $e, $aval, $format, $limit) = @_;
  my $msg = '';
  if ($aval ne '') {
    my @v = split(/\|/, $aval);
    my $x = ($s ne '' && $e ne '')? '': ',';
    if ($limit && $limit <= $#v) {
      splice(@v, $limit);
      $msg = join(',', map { ($_ eq '#PCDATA')? '普通のテキスト':
                                                ($s eq '<')? xc("$s$_$e"): "$s$_$e" } @v);
      $msg =~ s/,($s[^$s$e$x]+$e)$/ や $1/;
      $msg .= ' など';
    } else {
      $msg = join(',', map { ($_ eq '#PCDATA')? '普通のテキスト':
                                                ($s eq '<')? xc("$s$_$e"): "$s$_$e" } @v);
      $msg =~ s/,($s[^$s$e$x]+$e)$/ または $1/;
    }
    $msg =~ s/,/、/g;
    $msg = sprintf($format, $msg) if $format ne '';
  }
  $msg;
}

sub FormatTagGuide
{
  &FormatGuide('<', '>', @_);
}

sub FormatAttrGuide
{
  &FormatGuide('`', '`', @_);
}

sub FormatOtherHTMLsGuide
{
# if ($#_ > 4) {
#   &FormatGuide('', '', '他のHTML');
# } else {
    my @htmls;
    my $last;
    foreach (sort {${$::doctypes{$a}}{order} <=> ${$::doctypes{$b}}{order}} @_) {
      my $html = (${$::doctypes{$rule}}{group} eq ${$::doctypes{$_}}{group})?
                  ${$::doctypes{$_}}{abbr}: ${$::doctypes{$_}}{group};
      push(@htmls, $last = $html) if $last ne $html;
    }
    ' '.&FormatGuide('', '', join('|', @htmls)).' ';
# }
}

##################################################
# 実体参照をチェックする
# & で始まる文字列を調べ、適当に警告を発して調べた次の文字列と
# デコードした実体参照をリストで返す

sub CheckRefEntities
{
  my ($line, $urichk, $refchk) = @_; # $urichk : 0=全警告 1=一部警告 2=無警告
  my $orgline = $line;
  my $pcode;
  if ($line =~ /^&($nameStr|#\d+)($allc*)/ ||
      # HTML4 では 16進の文字参照が可能
      ($htmlVer >= 4 && $line =~ /^&(#x[0-9A-F]+)($allc*)/oi)) {
    $line = $2;
    my $ref = $1;
    my $code;
    if ($ref =~ /^#(.*)/) {
      $code = $1;
      if ($code =~ /^x(.*)/i) {
        $code = hex($1);
        if ($xhtml && $ref =~ /^#X/) {
          $ref =~ s/^#X/#x/;
          &Whine($., 'lower-x', ${$::doctypes{$rule}}{guide}, '&'.$ref.';') if $urichk < 2;
        }
      }
      if ($line =~ /^;($allc*)/o) {
        $line = $1;
        $ref .= ';';
      } else {
        &Whine($., 'required-semicolon', '&'.$ref) if $urichk < 2;
      }
      if ($urichk < 2) {
        my $limit = ${$::doctypes{$rule}}{charref};
        if (defined($limit) && $code >= $limit) {
          if ($limit) {
            $limit--;
            $limit = sprintf('x%lX', $limit) if $ref =~ /^#x/i;
            &Whine($., 'over-ref-charset', '&'.$ref, '&#'.$limit.';');
          } else {
            &Whine($., 'no-ref-charset', '&'.$ref);
          }
        }
      }
    } else {
      if ($code = $refEntities{$ref}) {
        if ($line =~ /^;($allc*)/o) {
          $line = $1;
          $ref .= ';';
        } else {
          &Whine($., 'required-semicolon', '&'.$ref) if $urichk < 2;
        }
        if ($ref =~ /^apos;?$/) {
          &Whine($., 'apos') if $urichk < 2;
        }
        $code =~ /^&#([^;]*)/;
        $code = $1;
      } else {
        my $cand;
        foreach (keys %refEntities) {
          if (lc($ref) eq lc) {
            # 大文字小文字が違うだけのケース
            $cand = $_;
            last;
          } elsif ($ref =~ /^$_/i) {
            # 先頭一致するケース
            $cand = $_;
          }
        }
        if ($line =~ /^;($allc*)/o) {
          $line = $1;
          $ref .= ';';
        }
        if ($urichk < 2) {
          &Whine($., 'bad-entity',
                     '&'.$ref, $cand? '&'.$cand.'; なら正しいのですが。': '');
#         &::PushStat('BadEntity', '&'.$ref) if $opt_stat;
       }
      }
    }
    if ($code ne '') {
      $pcode = chr($code);
      if ($urichk && $refchk && $pcode =~ /($RFC2396::spdelimunwise)/o) {
        if ($1 ne '%') {
          &Whine($., 'excluded-url-ref', xc($TAG), xc($ATTR), '&'.$ref, $1);
          &::PushStat('ExcludedURLRef', '&'.$ref) if $opt_stat;
        }
      }
    }
  } else {
    $line = substr($line, 1);
    &WhineRefEntities($pcode = '&') if $urichk < 2;
  }
  if ($pcode eq '') {
    $pcode = substr($orgline, 0, length($orgline)-length($line));
  }
  ($line, $pcode);
}

##################################################
# 実体参照に関する警告を表示する

sub WhineRefEntities
{
  my $c = shift;
  &Whine($., 'literal-metacharacter', '&', '&amp;'), return if $c eq '&';
  &Whine($., 'literal-metacharacter', '<', '&lt;') , return if $c eq '<';
  &Whine($., 'literal-metacharacter', '>', '&gt;') , return if $c eq '>';
  if ($quot eq '') {
    &Whine($., 'double-quote-in-text',  '"', '&quot;'), return if $c eq '"';
  } elsif ($quot eq '"') {
    &Whine($., 'literal-metacharacter', '"', '&quot;'), return if $c eq '"';
  }
}

##################################################
# 書けないタグに関する警告を表示する

sub WhineExcludedElement
{
  unless ($xmlns) {
    my ($tag, $parent, $pln, $msg) = @_;
    my $inhead;
    if ($headElements && $tag =~ /^(?:$thisTagElements)$/) {
      $inhead = xc('<HEAD>〜</HEAD>').' 内では、';
      $msg = '';
    }
    if ($xhtml && !$tagsElements{$parent}) {
      &Whine($pln, 'endtag-slash', xc($parent));
      return 1;
    }
    ($tag eq '#PCDATA')?
      &Whine($., 'unexpected-pcdata', '', xc($parent), $inhead):
      &Whine($., 'excluded-element', xc($tag), xc($parent), $pln, $msg, $inhead);
  }
  0;
}

##################################################
# 不正なタグに関する警告を表示する

sub WhineUnknownElement
{
  my $tag = shift;
  my $TAG = uc($tag);
  my $id = ($TAG =~ m#^/(.*)#)? $1: $TAG;
  if (!$xmlns) {
    if ($TAG ne $id && $id !~ /^(?:$pairTags)$/ && $id =~ /^(?:$emptyTags)$/) {
      &Whine($., 'illegal-closing', xc($TAG), xc($id));
      &::PushStat('IllegalClosing', $id) if $opt_stat;
    } else {
      if ($TAG !~ /^(?:[^:]+):/) { # IE5 の XMLNS:namespace 対応
        my @htmls = grep($id =~ /^(?:$pairTags{$_})$/, keys %pairTags);
        if ($id eq $TAG) {
          push(@htmls, grep($id =~ /^(?:$emptyTags{$_})$/, keys %emptyTags));
        }
        if (@htmls) {
          &Whine($., 'other-html-element', xc($TAG), &FormatOtherHTMLsGuide(@htmls));
          return 1;
        }
      }
      &Whine($., 'unknown-element', $tag);
      &::PushStat('UnknownElement', $tag) if $opt_stat;
    }
  }
  0;
}

##################################################
# 不正な属性に関する警告を表示する

sub WhineUnknownAttribute
{
  my ($tag, $attr) = @_;
  if ($xmlns) {
    return if $tag !~ /^(?:$allTags)$/;
  }
  my @htmls = grep { $attr =~ /^(?:$attributes{$_}->{$tag})$/ } keys %attributes;
  if (@htmls) {
    &Whine($., 'other-html-attribute', xc($tag), xc($attr),
               &FormatOtherHTMLsGuide(@htmls)) if $unknownTag != 2;
  } else {
    if ($tag =~ /^(?:$allTags)$/) {
      &Whine($., 'unknown-attribute', xc($tag), $oATTR); # この $oATTR はうまないかも
      &::PushStat('UnknownAttribute', $tag.' '.$attr) if $opt_stat;
    }
  }
}

##################################################
# 終了タグの省略に関する警告を表示する
# 第3引数は &OmitEndTag の結果で != 0

sub WhineOmitEndTag
{
  my ($tag, $end, $omit) = @_;
  my $whine = 0;
  if ($tag eq $lastTag && $tag !~ /^(?:$maybeEmpty)$/) {
    # 要素が空なら警告を出す
    $whine = 1;
  } elsif ($omit == 1) {
    # 順序タグのとき
    my $last = &ExpandInternalElements($onceonlyTags{$tagsNest[$#tagsNest-1]{tag}});
    $whine = 1 if $#tagsNest == 0 || ($tag =~ /^(?:$last)$/ &&
                                      $tag !~ /^(?:$omitStartTags)$/);
  } elsif ($tag =~ /^(?:$noOmitEtag)$/) {
    $whine = 1;
  } elsif ($omit == 2 && $tag ne $end) { # <P>〜<P> のようなときは省略が自明とみなす
    # 要素に $tag が含まれていて
    # #PCDATA が含まれていないときは、普通は省略される終了タグだとみなす
    my $last = &ExpandInternalElements($tagsElements{$tagsNest[$#tagsNest-1]{tag}});
    $whine = 1 unless $tag =~ /^(?:$last)$/ && '#PCDATA' !~ /^(?:$last)$/;
  }
  &Whine($., $whine? ($tag !~ /^($omitEndTags)$/)?
             'required-end-tag': 'omit-end-tag': 'omit-end-tag-trivial',
             xc($tag), $end? xc("<$end>").' の前に': 'ここに');
  &::PushStat('OmitEndTag', $tag) if $opt_stat && $whine;
}

##################################################
# 警告メッセージを表示する

sub Whine
{
  unless (defined(%messages)) { # デバグ用
    print @_, "\n";
    return;
  }
  my ($ln, $id, @argv) = @_;
  # $argv[0] は要素名か、まったく無関係な文字列
  if ($analizing && uc($argv[0]) eq 'INPUT' && $seenAttrs{TYPE} ne '') {
    $argv[0] = xc(qq|INPUT TYPE="\U$seenAttrs{TYPE}"|);
  }
  my $oid = $id;
  my $msg = ${$messages{$id}}[0];
  my $pnt = $enabled{$id};
  unless ($msg) {
    $oid = $alias_messages{$id};
    $msg = ${$messages{$oid}}[0];
    $pnt = -$pnt if $enabled{$oid} < 0.0;
  }
  if ($msg) {
    $::whinesStat{$id}++;
    return if (!$opt_religious     && $religious{$oid}) ||
              (!$opt_accessibility && $accessibility{$oid});
    if ($pnt >= 0.1) {
      $uniquewhine{$id}? ($upenalty += $pnt): ($penalty += $pnt);
      $pwhinescnt++;
    } elsif ($pnt < -0.01 && $opt_pedantic) {
      $uniquewhine{$id}? ($upenalty -= $pnt): ($penalty -= $pnt);
      $pwhinescnt++;
    }
    return unless $pnt > 0.0 || $opt_pedantic;
    $maxpnt = $pnt if $maxpnt < $pnt;
  } else {
    $pnt = 1; # 加算量は適当
    $penalty += $pnt;
    $msg = '不明なメッセージ要求 : '.$id;
  }
  if ($opt_warnings) {
    my $file = $htmlfile;
#   $file =~ s#/#\\#g if $WIN;
    $file =~ s/\\/\\\\/g;
    $file =~ s/\$/\\\$/g;
    $file =~ s/\@/\\\@/g;
    $file =~ s/\%/\\\%/g;
    unless (&CallCGI()) {
      my $n = int(&WhineScore($id)+0.9);
      $n = 9 if $n > 9;
      $msg = "$n: $msg";
    }
    if ($opt_w eq 'long') {
      $msg = "$ln: $id: $msg";
    } elsif ($opt_w eq 'short') {
      $msg = "$ln: $msg";
    } elsif ($opt_w eq 'verbose') {
      $msg = "$file: $ln: $oid: $msg";
    } elsif ($opt_w eq 'terse') {
      $msg = "$file:$ln:$oid";
    } else { # 'lint'
      $msg = "$file($ln): $msg";
    }
    if ($pnt < 0.1) {
      return if $::whinesStat{$id} > $opt_omit;
      if ($::whinesStat{$id} == $opt_omit) {
        my $addmsg = 'これ以降この警告は表示しません。';
        $addmsg =~ s/\\/\\\\/g;
        $msg .= $addmsg;
      }
    }
    $msg = eval qq|"$msg"|;
    $msg =~ s/\\([\[\]\{\}])/$1/g;
    unless (&CallCGI()) {
      # CGIからの呼び出しのときはエスケープ処理はCGI側で行なう
      $msg =~ s/([\x00-\x08\x0B\x0C\x0E-\x1F])/'^'.chr(ord($1)+0x40)/eg;
    }
    print "$msg\n";
  }
  $whinescnt++;
}

##################################################
# 警告の有効無効を設定する

sub EnableWarning
{
   my ($id, $en) = @_;
   $id = $shortid{$id} if $shortid{$id};
   if (${$messages{$id}}[0]) {
     my $n = $enabled{$id};
     $n = -$n if $n < 0.0;
     $enabled{$id} = $en? $n: -$n if $n < 100;
     return 1;
   }
#  print "$configfile: $.: " if $configfile ne '';
   print "Unknown warning id `$id`.\n";
   0;
}

##################################################
# タグセットを読み込む
# &ReadRule よりも一部を読む方が速い

sub ReadTagsSet
{
  local $/ = ';';
  local *RULE;
  foreach my $file (keys %::doctypes) {
    if (open(RULE, $ruledir.$file.'.rul')) {
      my ($line, $appear);
      while ($line = <RULE>) {
        if ($line =~ /\$emptyTags/) {
          local $emptyTags;
          eval $line;
          $emptyTags{$file} = $emptyTags;
          $appear |= 1;
        } elsif ($line =~ /\$pairTags/) {
          local $pairTags;
          eval $line;
          $pairTags{$file} = $pairTags;
          $appear |= 2;
        } elsif ($line =~ /\%tagsAttributes/) {
          local %tagsAttributes;
          eval $line;
          foreach (keys %tagsAttributes) {
            $attributes{$file}->{$_} = &Join('|', keys %{$tagsAttributes{$_}});
          }
          $appear |= 4;
        }
        last if $appear == 7;
      }
      close(RULE);
    }
  }
}

##################################################
# 規則ファイルを読み込む
# require ではだめ

sub ReadRule
{
  my $file = shift;
  $file = $ruledir.$file;
  return 0 unless -f $file;
  do $file;
  $rulefile = $file;
  1;
}

##################################################
# 設定ファイルを読み込む

sub ReadConfigFile
{
  my $configfile = '';
  if ($opt_f) {
    $configfile = $opt_f;
  } elsif ($ENV{HTMLLINTRC} && -f $ENV{HTMLLINTRC}) {
    $configfile = $ENV{HTMLLINTRC};
  } elsif ($::HTMLLINTRC ne '') {
    if ($::HTMLLINTRC !~ /^\./) {
      $configfile = $PROGDIR.$::HTMLLINTRC if -e $PROGDIR.$::HTMLLINTRC;
    } elsif ($UNIX) {
      my $user = eval 'getlogin() || (getpwuid($<))[0]' || $ENV{USER};
      my $home = eval '(getpwnam($user))[7]' || $ENV{HOME} || '/';
      $home .= '/' unless $home =~ m#/$#;
      $configfile = $home.$::HTMLLINTRC if -e $home.$::HTMLLINTRC;
    }
  }
  if ($configfile ne '') {
    local *CONFIG;
    local ($cnf_style, $cnf_html, $cnf_limit, $cnf_omit);
    my ($keyword, $arglist);
    open(CONFIG, "<$configfile") || die "Can't open config file `$configfile`.\n";
    while (<CONFIG>) {
      chomp;
      s/#.*$//;
      next if /^\s*$/;
      if (/^\s*(\S+)(?:\s+(.+))?$/i) {
        local @ARGV = ("-$1");
        push(@ARGV, $2) if $2 ne '';
        &GetOptions('disable=s'      => \&cnf_ed,
                    'enable=s'       => \&cnf_ed,
                    'style=s'        => \$cnf_style,
                    'html=s'         => \$cnf_html,
                    'limit=i'        => \$cnf_limit,
                    'omit=i'         => \$cnf_omit,
                    'pedantic!'      => \&cnf_noval,
                    'banner!'        => \&cnf_noval,
                    'echoname!'      => \&cnf_noval,
                    'score!'         => \&cnf_noval,
                    'scorenowhines'  => \&cnf_noval,
                    'scoreonly'      => \&cnf_noval,
                    'local!'         => \&cnf_noval,
                    'religious!'     => \&cnf_noval,
                    'accessibility!' => \&cnf_noval,
                    'warnings!'      => \&cnf_noval,
                    'prune!'         => \&cnf_noval,
                    'lc'             => \&cnf_lcuc,
                    'uc'             => \&cnf_lcuc,
                    'igndoctype'     => \&cnf_ignuse,
                    'usedoctype'     => \&cnf_ignuse,
                    'igncharset'     => \&cnf_ignuse,
                    'usecharset'     => \&cnf_ignuse);
      } else {
        print "$configfile: $.: Illegal line.\n";
      }
    }
    close(CONFIG);
    $opt_w     = $cnf_style if !defined($opt_w);
    $opt_x     = $cnf_html  if !defined($opt_x);
    $opt_limit = $cnf_limit if !defined($opt_limit);
    $opt_omit  = $cnf_omit  if !defined($opt_omit);
  }
}

  sub cnf_ed
  {
    my ($ed, $ids) = @_;
    while ($ids =~ /^\s*(\S+)(.*)/) {
      $ids = $2;
      my $id = $shortid{$1}? $shortid{$1}: $1;
      $cnf_e{$id} = $ed =~ /^e/i;
    }
  }

  sub cnf_lcuc
  {
    if (!defined($opt_lc)) {
      $opt_lc = (shift =~ /^l/i)? 1: 0;
    }
  }

  sub cnf_noval
  {
    my $opt = shift;
    my $val = shift;
    $opt = lc("opt_$opt");
    ${"$opt"} = $val if !defined(${"$opt"});
  }

  sub cnf_ignuse
  {
    my $opt = shift;
    if ($opt =~ /^use(.+)$/i) {
      $opt = lc("opt_ign$1");
      ${"$opt"} = 0 if !defined(${"$opt"});
    } else {
      $opt = lc("opt_$opt");
      ${"$opt"} = 1 if !defined(${"$opt"});
    }
  }

##################################################
# 起動時オプションを読み込む

  sub opt_ed
  {
    my ($ed, $ids) = @_;
    foreach (split(/[,;:]/, $ids)) {
      my $id = $shortid{$_}? $shortid{$_}: $_;
      $opt_e{$id} = $ed =~ /^e/i;
    }
  }

  sub opt_lcuc
  {
    $opt_lc = (shift =~ /^l/)? 1: 0;
  }

  sub opt_ignuse
  {
    my $opt = shift;
    if ($opt =~ /^use(.+)$/) {
      ${"opt_ign$1"} = 0;
    } else {
      ${"opt_$opt"} = 1;
    }
  }

sub ReadOptions
{
  local (%cnf_e, %opt_e, $opt_r, $opt_listwarnings, $opt_version, $opt_help);
  &ReadWarnings();
  grep(s/^-$/$stdio/, @ARGV); # ファイル名 '-' (stdin/out) を GetOptions の評価から守る
  # オプションの増減に伴なって HTMLlint() にある local $opt_xxx の調整もすること
  &GetOptions('d=s' => \&opt_ed,
              'e=s' => \&opt_ed,
              'w=s',
              'f=s',
              'x=s',
              'r=s',
              'stat=s',    # CGI用
              'lang=s',    # CGI用
              'charset=s', # CGI用
              'mime=s',    # CGI用
              'style=s',   # CGI用
              'script=s',  # CGI用
              'base=s',    # CGI用
              'limit=i',
              'omit=i',
              'help|u',
              'version|v',
              'listwarnings',
              'linklist!',
              'pedantic!',
              'banner!',
              'echoname!',
              'score!',
              'scorenowhines',
              'scoreonly',
              'local!',
              'religious!',
              'accessibility!',
              'warnings!',
              'prune!',
              'after=s',
              'lc'         => \&opt_lcuc,
              'uc'         => \&opt_lcuc,
              'igndoctype' => \&opt_ignuse,
              'usedoctype' => \&opt_ignuse,
              'igncharset' => \&opt_ignuse,
              'usecharset' => \&opt_ignuse,
#             'j=s',  # 未使用
#             'cr',   # 未使用
              'dbg')
            || die '使い方は -U オプションを指定すると表示されます。'."\n";
  &ReadConfigFile();
  $opt_charset = '' if $opt_igncharset;
  $opt_charset = $1 if $opt_charset =~ /^"(.+)"$/;
  $opt_limit = 999       if !defined($opt_limit); # 打ち切り限界警告数
  $opt_omit  = 20        if !defined($opt_omit);  # 無減点同一警告の省略
  $opt_banner = 1        if !defined($opt_banner);
  $opt_score = 1         if !defined($opt_score);
  $opt_score = 1         if  defined($opt_scorenowhines);
  $opt_local = 1         if !defined($opt_local);
  $opt_warnings = 1      if !defined($opt_warnings);
  $opt_religious = 1     if !defined($opt_religious);
  $opt_accessibility = 1 if !defined($opt_accessibility);
  $opt_igndoctype = 1    if !defined($opt_igndoctype) && defined($opt_x);
  $opt_stat = ''         if !defined(&::TakeStatistics);
  foreach (keys %cnf_e) { &EnableWarning($_, $cnf_e{$_}); }
  foreach (keys %opt_e) { &EnableWarning($_, $opt_e{$_}); }
  if ($opt_listwarnings) {
    &ListWarnings();
    return 1;
  }
  if ($opt_v || $opt_version) {
    print $version;
    return 1;
  }
  if ($opt_u || $opt_help || !@ARGV) {
    print $version;
    unless ($opt_x) { $opt_x = ${$::doctypes{$::defaultrule}}{name}; }
    unless ($opt_w) { $opt_w = 'lint'; }
    foreach (split(/\n/, $usage)) {
      print;
      foreach my $opt (qw(pedantic banner religious accessibility echoname score prune warnings linklist local)) {
        if (${"opt_$opt"}? /-$opt\b/: /-no$opt\b/) { print '(*)'; }
      }
      foreach my $opt (qw(doctype charset)) {
        if (${"opt_ign$opt"}? /-ign$opt\b/: /-use$opt\b/) { print '(*)'; }
      }
      if ($opt_lc? /-lc\b/: /-uc\b/) { print '(*)'; }
      if (/= $opt_w\b/) { print '  (*)'; }
      if (/=.+\b(?:$opt_x)\b/) { print '  (*)'; }
      if (/-limit\b/) { print "($opt_limit)"; }
      if (/-omit\b/) { print "($opt_omit)"; }
      print "\n";
    }
    return 1;
  }
  $opt_after =~ s/^\s+//g;
  $opt_after =~ s/\s+$//g;
  if ($opt_after ne '') {
    if ($opt_after =~ /^\@(.*)$/) {
      $opt_after = ($1 ne '')? [stat $1]->[9]: 0;
    } else {
      # yyyy-mm-dd-hh-mm-ss
      my @tm = map($_+0, split(/\D/, $opt_after));
      $opt_after = timelocal(($tm[5]>=0 && $tm[5]<60)? $tm[5]:0,
                             ($tm[4]>=0 && $tm[4]<60)? $tm[4]:0,
                             ($tm[3]>=0 && $tm[3]<24)? $tm[3]:0,
                             ($tm[2]>=1 && $tm[2]<=31)? $tm[2]:1,
                             ($tm[1]>=1 && $tm[1]<=12)? $tm[1]-1:0,
                             ($tm[0]>=1900)? $tm[0]-1900:0);
    }
    $opt_after = 0 if $opt_after < 0;
  }
  $opt_w =~ tr/A-Z/a-z/;
  $ruledir = $::RULEDIR;
  $ruledir = $opt_r if $opt_r;
  $ruledir .= $SEP if $ruledir ne '' && $ruledir !~ m#$SEP$#o;
  $ruledir = $PROGDIR.$ruledir if $ruledir eq '' || $ruledir =~ /^\./;
  $ruledir =~ s#\\#/#g if $WIN;
  0;
}

##################################################
# 全警告を表示する

sub ListWarnings(;\@)
{
  &ReadWarnings unless defined(%messages);
  my $aref = shift;
  my %msgshort;
  foreach my $id (keys %shortid) { $msgshort{$shortid{$id}} = $id; }
  foreach my $id (sort keys %messages) {
    my $msg = ${$messages{$id}}[0];
    $msg =~ s#<\$argv\[\d+\]>#<TAG>#g;
    $msg =~ s#</\$argv\[\d+\]>#</TAG>#g;
    $msg =~ s#\$argv\[\d+\] 属性#ATTR 属性#g;
    $msg =~ s#\$argv\[\d+\] の属性値#ATTR の属性値#g;
    $msg =~ s#\$argv\[\d+\]行目#NN行目#g;
    $msg =~ s#\$argv\[\d+\]#XXXX#g;
    $msg =~ s#\\"#"#g;
    $msg =~ s#\\\\#\\#g;
    my $n = &WhineScore($id);
    my $str = $id.' '.($msgshort{$id}? $msgshort{$id}: '-').
                  ' '.(($enabled{$id} > 0.0)? 'ENABLED': 'DISABLED').
                  ' '.$n;
    foreach (keys %alias_messages) {
      if ($alias_messages{$_} eq $id) {
        $n = $enabled{$_};
        $n = 0 if $n < 0.1;
        $str .= " $_ $n";
      }
    }
    if (defined($aref)) {
      push(@$aref, $str);
    } else {
      print "$str\n$msg\n";
    }
  }
}

sub WhineScore
{
  my $id = shift;
  my $n = $enabled{$id};
  $n = -$n if $n < 0.0;
  $n < 0.1? 0: $n;
}

sub CallCGI
{
  # CGI(htmllint.pm)からの呼び出しか
  defined(&::AskHTML); # これで代用
}

##################################################
# 組み込み警告メッセージと既定値を読み込む

sub ReadWarnings
{
# return if defined(%messages);
  my (@elem, $rel, $acc, $id, $default, $msg, $alias, $n, $nalias);
  my $i = 0;
  while (<DATA>) {
    chomp;
    s/^\s*//;
    s/\s*$//;
    next if !$_ || /^#/;
    push(@elem, $_);
    next unless @elem == 3;
    ($id, $default, $msg) = @elem;
    $id = $1 if $rel = $id =~ /^\*(.*)/;
    $id = $1 if $acc = $id =~ /^\@(.*)/;
    ($id, $alias) = split(' ', $id);
    if ($id =~ /^([^:]+):(.*)/) {
      $id = $1;
      die "Already used short name '$2'.\n" if $shortid{$2};
      $shortid{$2} = $id;
    }
    ($default, $n, $nalias) = split(' ', $default);
    $religious{$id} = 1 if $rel;
    $accessibility{$id} = 1 if $acc;
    if ($n =~ /^\*(.*)/) {
      $n = $1;
      $uniquewhine{$id}++;
    }
    $enabled{$id} = ($default =~ /^(?:E|ON|1)/i)? $n: -$n;
    $msg =~ s/\\/\\\\/g;
    $msg =~ s/"/\\"/g;
    ${$messages{$id}}[0] and die "Already used message id '$id'.\n";
    ${$messages{$id}}[0] = $msg;
    ${$messages{$id}}[1] = $i++;
    if ($alias) {
      $alias_messages{$alias} = $id;
      $enabled{$alias} = $nalias? $nalias: $n;
    }
    undef @elem;
  }
}

1;

__DATA__

# 点数は 0 より大きいこと。0.1未満の点数は加算されない。100以上は DISABLE にできない。
# 警告には、同一メッセージで点数の異なる別名を(今のところひとつ)指定できる。
# 名前と点数を空白で区切って並べればよい。
# 名前の頭の * は宗教的なもの、@ は必須でないアクセス性に関するものを示す。
# 点数頭の * は、その点数がそのまま減点される (0.1以上のとき)。
# そうでない場合は、だいたい 1/タグ数 されて減点される。

# 警告の増減に対して以下の調整を行なう
#     htmllint.html のチェックを調整する
#     explain.html の解説を調整する
#     htmllintrc を調整する
#     stat-whines.dat を調整する (optional)

over-limit-whines
  ENABLE 100
  エラーの数が $argv[0]個を超えたのでチェックを打ち切ります。
cant-get-url:u
  DISABLE 5
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` は$argv[3]存在しないかアクセスできません。$argv[4]
required-doctype:qd
  ENABLE *8
  最初の記述が DOCTYPE宣言ではありません。
prectrl-doctype:pcd
  ENABLE *3
  DOCTYPE宣言の前に何か制御文字が含まれています。
unknown-doctype:ud
  ENABLE *6
  不明な DOCTYPE宣言です。$argv[2]
doctype-case-mismatch:dcm
  ENABLE *8
  DOCTYPE宣言に指定されている公開識別子の大文字小文字が正しくありません。
unsupported-doctype:usd
  ENABLE *1
  $argv[3] は Another HTML-lint ではサポートされていない DOCTYPE宣言です。$argv[2]
expired-doctype:xd
  ENABLE *6
  $argv[0] はすでに廃棄されたHTMLです。使わないようにしましょう。
obsoleted-doctype:od
  ENABLE *0.01
  $argv[0] はあまり薦められないHTMLです。$argv[4] を使いましょう。
doctype-mismatch:dm
  ENABLE *0.01
  指定されている $argv[1] は DOCTYPE宣言と一致しません。DOCTYPE宣言を無視します。
misplaced-doctype:md
  ENABLE *9
  DOCTYPE宣言は文書の先頭でなければなりません。
lower-case-doctype:lcd
  ENABLE *7
  DOCTYPE宣言中の `$argv[1]` は小文字で書かなければなりません。
upper-case-doctype:ucd
  ENABLE *7
  DOCTYPE宣言中の $argv[1] は大文字で書かなければなりません。
empty-systemid:esi
  ENABLE *8
  DOCTYPE宣言にはシステム識別子が必要です。
illegal-systemid:isi
  ENABLE *8
  DOCTYPE宣言に指定されているシステム識別子が正しくありません。
systemid-case-mismatch:sicm
  ENABLE *7
  DOCTYPE宣言に指定されているシステム識別子の大文字小文字が正しくありません。
ignore-declaration:id
  ENABLE 1
  SGML宣言や DTD宣言などと思われる <$argv[1] 〜> は無視します。
marked-section:mks
  ENABLE 0.01
  マーク区間 <!\[$argv[1]\[ 〜 \]\]> は、多くのブラウザは理解できません。
badstr-in-marked-section:bsmk
  ENABLE 9
  マーク区間中に `$argv[1]` を書くことはできません。
unclosed-marked-section:ucmk
  ENABLE 9
  $argv[1]行目のマーク区間 <!\[$argv[2]\[ が閉じられていません。
misplaced-xmldecl:mxml
  ENABLE *9
  XML宣言は文書の先頭でなければなりません。
xhtml-xmldecl:xxd
  ENABLE *6
  $argv[1] では XML宣言をすることが強く求められています。
end-xmldecl:exd
  ENABLE *9
  XML宣言を閉じるのは `?>` です。
bad-xmldecl:bxd
  ENABLE *9
  このXML宣言は正しくありません。
processing-instruction:pi
  ENABLE 0.01
  処理命令 `<?〜>` は理解できません。
w-hyphens-in-comment:hy
  ENABLE 2
  コメント中に `--` は書かない方が安全です。
excluded-w-hyphens-in-comment:xhy
  ENABLE 9
  コメント中に `--` を書くことはできません。
*empty-comment:ecm
  ENABLE 2
  空のコメント `<!>` は書かない方が安全です。
illegal-comment:icm
  ENABLE 9
  このコメントのような記述 `$argv[0]` は正しくありません。
title-comment:tm
  ENABLE 3
  <$argv[0]> 中にはコメントを書かないようにしましょう。
*markup-in-comment:mk
  ENABLE 0.01
  コメント中に `<` や `>` を書くと、いくつかのブラウザを混乱させることがあります。
nested-comment:ncm
  ENABLE 3
  コメントを入れ子にすることはできません。
*space-in-closed-comment:scc
  ENABLE 2
  閉じコメントの `--` と `>` の間には空白を入れないようにしましょう。
illegal-closed-comment:icc
  ENABLE 8
  閉じコメントは `$argv[1]` ではなく `-->` です。
unclosed-comment:ucc
  ENABLE 9
  $argv[1]行目のコメントが閉じられていません。
unclosed-tag:ut
  ENABLE *9
  $argv[1]行目の <$argv[0] が閉じられていません。
leading-whitespace:lw
  ENABLE 9
  `<` と `$argv[1]` の間には空白を入れてはいけません。
unexpected-open:uo
  ENABLE 7
  予期せぬ `<` が <$argv[0]> 内にあります。閉じられていないタグの可能性があります。
endtag-slash:es
  ENABLE 8
  空要素タグ <$argv[0]> は <$argv[0] /> として閉じなければなりません。
leading-space-endtag-slash:les
  ENABLE 1
  空要素タグ <$argv[0]> を閉じるときは `/>` に空白を先行させましょう。
contain-no-space:cns
  ENABLE 9
  空要素タグ <$argv[0]> の要素には空白さえも含めることはできません。
minimized-endtag:met
  ENABLE 1
  空要素タグは <$argv[0] /> と書くようにしましょう。
noempty-endtag-slash:nes
  ENABLE 9
  非空要素タグ <$argv[0]> を `/>` で閉じることはできません。
excluded-element:xe
  ENABLE 9
  $argv[4]<$argv[0]> を $argv[2]行目の <$argv[1]>〜</$argv[1]> 内に書くことはできません。$argv[3]
deprecated-element:de
  DISABLE 0.01
  $argv[1]を $argv[3]行目の <$argv[2]>〜</$argv[2]> 内に書くことはあまり薦められません。
misplaced-element:me
  ENABLE 9
  <$argv[0]> を <$argv[1]$argv[2]>〜</$argv[1]> の外に書くことはできません。
once-only:oo
  ENABLE 8
  <$argv[0]> は <$argv[1]>〜</$argv[1]> 内に1度しか書けません。$argv[2]行目にもありました。
once-only-group:oog
  ENABLE 8
  <$argv[0]> は $argv[2]行目の <$argv[3]> と同時に <$argv[1]>〜</$argv[1]> 内に書くことはできません。
must-follow:mf
  ENABLE 8
  <$argv[0]> は $argv[1] の直後に続かなければなりません。
must-follow-slight:mfs
  ENABLE 1
  <$argv[0]> は $argv[1] の直後に続かなければなりません。
required:q
  ENABLE 9
  <$argv[0]>〜</$argv[0]> 内には $argv[1]が必要です。
*empty-container:ec
  ENABLE 1
  <$argv[0]> と </$argv[0]> の間が空です。
@space-container:sc
  ENABLE 0.01
  <$argv[0]> と </$argv[0]> の間に空白文字しか含まれていません。
*br-only-container:boc
  ENABLE 0.01
  <$argv[0]>〜</$argv[0]> 内には空白以外に <$argv[1]> しか含まれていません。
unknown-element:ue
  ENABLE 8
  <$argv[0]> は不明なタグです。
other-html-element:he
  ENABLE 7
  <$argv[0]> は$argv[1]用のタグです。
deprecated-tag:dt deprecated-tag-0
  ENABLE 1        0.01
  <$argv[0]> はあまり薦められないタグです。$argv[1]
deprecated-tag-css:dtc  deprecated-tag-css2
  ENABLE 0.01           0.02
  <$argv[0]> はあまり薦められないタグです。スタイルシートを使いましょう。
unsupported-tag:ust
  ENABLE 0.01
  <$argv[0]> は Another HTML-lint では正確な評価はできません。
should-not-use:snu
  ENABLE 6
  <$argv[0]> は使うべきでありません。
required-start-tag:qst
  ENABLE 9
  ここには <$argv[0]> が必要です。
omit-start-tag:os
  ENABLE 4
  ここに <$argv[0]> が省略されているようです。省略しないようにしましょう。
omit-start-tag-trivial:ost
  DISABLE 0.01
  ここに <$argv[0]> が省略されているようです。
required-end-tag:qet
  ENABLE 9
  ここには </$argv[0]> が必要です。
omit-end-tag:oe
  ENABLE 2
  $argv[1] </$argv[0]> が省略されているとみなします。
omit-end-tag-trivial:oet
  DISABLE 0.01
  $argv[1] </$argv[0]> が省略されているとみなします。
closing-attribute:ca
  ENABLE 9
  終了タグ </$argv[1]> には属性を指定することはできません。
illegal-closing:ic
  ENABLE 7
  <$argv[1]> には終了タグ </$argv[1]> はありません。
*container-whitespace:cw
  DISABLE 0.01
  <$argv[0]>〜</$argv[0]> 内の$argv[1]に空白文字があります。
mis-match:m
  ENABLE 9
  </$argv[1]> に対応する開始タグ <$argv[1]> が見つかりません。
element-overlap:eo
  ENABLE 9
  </$argv[1]> は $argv[2]行目の <$argv[3]> と重なり合っているようです。
tags-nest:tn
  ENABLE 6
  <$argv[0]> タグの入れ子が深過ぎます。
unclosed-element:uce
  ENABLE 9
  $argv[1]行目の <$argv[0]> に対応する終了タグ </$argv[0]> が見つかりません。
unexpected-pcdata:xp
  ENABLE 9
  $argv[2]<$argv[1]>〜</$argv[1]> 内に普通のテキストを書くことはできません。
illegal-attribute:ia
  ENABLE 8
  <$argv[0]> 内におかしな文字列 `$argv[1]` があります。
xhtml-emptytag:xet
  ENABLE 7
  $argv[0] では空要素タグを `<$argv[1] />` と書くことはできません。
*mixed-case:mx
  DISABLE 0.01
  $argv[0]の大文字小文字を統一するようにしましょう。
lower-case-tag:lct
  ENABLE 9
  タグ <$argv[1]> は小文字で書かなければなりません。
lower-case-attribute:lca
  ENABLE 9
  <$argv[0]> の属性 `$argv[1]` は小文字で書かなければなりません。
unknown-attribute:ua
  ENABLE 6
  <$argv[0]> に不明な属性 `$argv[1]` が指定されています。
other-html-attribute:oa
  ENABLE 5
  <$argv[0]> に$argv[2]用の属性 `$argv[1]` が指定されています。
deprecated-attribute:da deprecated-attribute-0
  ENABLE 0.1              0.01
  <$argv[0]> の属性 `$argv[1]` はあまり薦められない属性です。$argv[2]
deprecated-attribute-css:dac
  ENABLE 0.01
  <$argv[0]> の属性 `$argv[1]` はあまり薦められない属性です。スタイルシートを使いましょう。
unsupported-attribute:usa
  ENABLE 0.01
  <$argv[0]> の属性 `$argv[1]` は Another HTML-lint では正確な評価はできません。
leading-space-attribute:la leading-space-attribute-html
  ENABLE 6                 2
  <$argv[0]> の $argv[1] 属性の前には空白が必要です。
repeated-attribute:ra
  ENABLE 7
  <$argv[0]> で $argv[1] 属性の指定が繰り返されています。
required-attribute:qa
  ENABLE 6
  <$argv[0]> には $argv[1] 属性が必要です。
required-attribute-pair:qap
  ENABLE 5
  <$argv[0]> で $argv[1] 属性を使うときは $argv[2] 属性も必要です。
nomixed-attribute:nma
  ENABLE 5
  <$argv[0]> で $argv[1] 属性と $argv[2] 属性を同時に指定することはできません。
required-value:qv
  ENABLE 5
  <$argv[0]> の $argv[1] 属性には属性値が必要です。
no-attribute-value:nv
  ENABLE 7
  <$argv[0]> の $argv[1] の属性値が指定されていません。
*across-lines-attribute:xl
  ENABLE 0.01
  <$argv[0]> の $argv[1] の属性値が複数行に渡っています。
*space-around-equal:sq
  DISABLE 0.01
  <$argv[0]> の $argv[1] の属性値区切りの = 前後に空白が含まれています。
unclosed-quotes:uq
  ENABLE 9
  <$argv[0]> の $argv[1] の属性値の引用符が閉じられていません。
*attribute-delimiter:ad
  DISABLE 0.01
  <$argv[0]> の $argv[1] の属性値が '$argv[2]' と書かれていますが、"$argv[3]" の方が安全です。
quote-attribute-value:qu
  ENABLE 8
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は引用符で囲まなければなりません。
recommend-quote-attribute-value:rq
  ENABLE 1
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は引用符で囲んだ方が安全です。
*bare-attribute-value:bv
  DISABLE 0.01
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` が引用符で囲まれていません。
*whitespace-attribute-value:wv
  ENABLE 1
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は空白文字が先行または後行しています。
deprecated-value:dv deprecated-value-0
  ENABLE 1          0.01
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` はあまり薦められない値です。
empty-value:ev
  ENABLE 7
  <$argv[0]> の $argv[1] の属性値に空の値を指定することはできません。
attribute-length:al
  ENABLE 4
  <$argv[0]> の $argv[1] の属性値が $argv[2]文字を超えています。
attribute-format:af
  ENABLE 7
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は正しくありません。$argv[3]
attribute-color:ac
  ENABLE 7
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は正しくありません。#RRGGBB の形式か決められた色の名前でなければなりません。
profile-uri:pu
  ENABLE 0.01
  <$argv[0]> の $argv[1] の属性値は、DTD上は単一のURIとされています。
unsafe-attribute:usfa
  ENABLE 0.01
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は使わない方が安全です。
attribute-value-case:avc
  ENABLE 7
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は `$argv[3]` でなければなりません。
fixed-attribute:fa
  ENABLE 7
  <$argv[0]> の $argv[1] の属性値は `$argv[2]` でなければなりません。
minimized-attribute:ma
  ENABLE 2
  <$argv[0]> の $argv[1] は属性名と属性値が同一です。属性名を省略して属性値だけの指定にしましょう。
no-minimization:nom
  ENABLE 8
  <$argv[0]> の属性 `$argv[1]` で属性名を省略することはできません。
omit-attribute-name:on
  ENABLE 3
  <$argv[0]> の `$argv[2]` は属性名 $argv[1] が省略されていますが、うまく評価されないかも知れません。
required-semicolon:qs
  ENABLE 7
  実体参照 `$argv[0]` の後ろには `;` を書きましょう。
apos
  ENABLE 1
  実体参照 `&apos;` は `&#39;` と書くようにしましょう。
lower-x:lx
  ENABLE 7
  $argv[0] では 16進数の文字参照は `$argv[1]` と小文字で始めなければなりません。
bad-entity:be
  ENABLE 3
  `$argv[0]` は不明な実体参照です。$argv[1]
over-ref-charset:orc
  ENABLE 3
  文字参照 `$argv[0]` は限界を超えた文字コードです。参照できるのは `$argv[1]` までです。
no-ref-charset:nrc
  ENABLE 3
  文字参照 `$argv[0]` を使用することはできません。
literal-metacharacter:lm
  ENABLE 5
  メタ文字 `$argv[0]` は `$argv[1]` と書かなければなりません。
*double-quote-in-text:dq
  DISABLE 0.01
  テキスト中の `$argv[0]` は `$argv[1]` と書きましょう。
@html-lang:hl
  ENABLE 2
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
lang:l
  ENABLE 2
  <$argv[0]> に $argv[1] 属性を指定するときは $argv[2] 属性も指定するようにしましょう。
lang-mismatch:lmis
  ENABLE 4
  <$argv[0]> に指定されている $argv[1] 属性の値と $argv[2] 属性の値が食い違っています。
lang-attribute:laa
  ENABLE 0.01
  $argv[4]指定されている $argv[2] 属性は `$argv[3]` ですが、<$argv[0]> の $argv[1] の属性値に日本語のような文字が含まれています。
lang-pcdata:lap
  ENABLE 0.01
  $argv[4]指定されている $argv[2] 属性は `$argv[3]` ですが、テキストに日本語のような文字が含まれています。
*mailto-link:ml
  ENABLE *0.01
  <$argv[0]>〜</$argv[0]> 内に $argv[1] が含まれていません。
@navigation-link:nl
  ENABLE *0.01
  <$argv[0]>〜</$argv[0]> 内に $argv[1] などのナヴィゲーション用のリンクが含まれていません。
mistype-links:mtl
  ENABLE 0.1
  <$argv[0]> の $argv[1] の属性値 `$argv[2]` は `$argv[3]` の誤りだと思われます。
#robots-upper:rou
#  ENABLE 0.1
#  <$argv[0] $argv[1]="$argv[2]"> は大文字で `ROBOTS` でなければなりません。
*robots-content:roc
  ENABLE 0.01
  <$argv[0] $argv[1]="$argv[2]"> に指定されている $argv[3] 属性の値 `$argv[4]` はあまり薦められません。
content-type:ct
  ENABLE *4
  <$argv[0]>〜</$argv[0]> 内に $argv[1] が含まれていません。
no-registered-charset:rc no-registered-charset-ex
  ENABLE 1               0.01
  $argv[1]指定されている文字コードセット `$argv[2]` は IANA に登録されていません。$argv[3]
no-charset:nc
  ENABLE 3
  <$argv[0] $argv[1]> に $argv[2] を指定するようにしましょう。
non-ascii-early:nae
  ENABLE *39
  <$argv[0] $argv[1]> で $argv[2] が指定されるより前に非ASCII文字が含まれています。
non-ascii:na
  ENABLE 0.9
  非ASCII文字が含まれています。
ctrl-character:ctl
  ENABLE 0.8
  制御文字 `$argv[1]` が含まれています。
han-katakana:hk han-katakana-0
  ENABLE 0.7    0.01
  半角カタカナが含まれています。
bad-jis-x0208:jx
  ENABLE 1
  機種依存全角文字 `$argv[1]` が含まれています。
bom
  DISABLE 0.01
  文書の先頭に BOM が含まれています。
xml-encoding:xen
  ENABLE *5
  $argv[0] では XML宣言中に encoding 指定をしましょう。
charset-mismatch:cm
  ENABLE *66
  $argv[2]指定されている文字コードセットは `$argv[0]` ですが、実際のコードは $argv[1] のようです。
conflict-charset:cc
  ENABLE *11
  $argv[1]に指定されている文字コードセットは `$argv[2]` ですが、$argv[3]に指定されているのは `$argv[4]` です。
http-head-charset:hhc
  ENABLE 5
  HTTPレスポンスヘッダに $argv[1] 指定が含まれていません。
no-text-html:th
  ENABLE *7
  <$argv[0]> に指定されている $argv[1] が $argv[2] ではありません。
conflict-mime:cmi
  ENABLE *8
  $argv[1]に指定されているメディアタイプは `$argv[2]` ですが、<$argv[0]> に指定されているのは `$argv[3]` です。
unrecommended-mime:urmi unrecommended-mime-slight
  ENABLE 5              0.5
  $argv[0]に指定されているメディアタイプ $argv[1] は $argv[2] には指定しないようにしましょう。
xml-http-equiv:xhq
  ENABLE 5
  $argv[2] では <$argv[0] $argv[1]> を記述すべきではありません。
existing-content-type:xc
  ENABLE 4
  <$argv[0] $argv[1]="$argv[2]"> は $argv[3]行目にもありました。
content-xxxx-type:cxt
  ENABLE *1
  <$argv[0]> を使うときは <$argv[1]>〜</$argv[1]> 内に $argv[2] を指定するようにしましょう。
need-content-xxxx-type:nxt
  ENABLE 3
  $argv[1] 属性を使うときは <$argv[2]>〜</$argv[2]> 内に $argv[3] を指定しなければなりません。
#need-xml-stylesheet:nxs
#  ENABLE 2
#  メディアタイプ $argv[1] では スタイルシートを使うときは $argv[2] 処理命令を使いましょう。
meta-http-equiv-name:mhn
  ENABLE 5
  <$argv[0]> に $argv[1] 属性と $argv[2] 属性の両方を指定することはできません。
meta-no-http-equiv-name:mnhn
  ENABLE 5
  <$argv[0]> に $argv[1] 属性を指定するときは $argv[2] 属性か $argv[3] 属性を指定しなければなりません。
@event-pair:ep
  ENABLE 1
  $argv[1] 属性を使うときは $argv[2] 属性も指定しましょう。
refresh:r
  ENABLE *2
  <$argv[0] $argv[1]="$argv[2]"> を利用しての自動的なページ更新は避けましょう。
refresh-link:rl
  ENABLE *3
  <$argv[0] $argv[1]="$argv[2]" $argv[3]> を利用するときは同等のリンクも用意しましょう。
comment-element:ce
  ENABLE 3
  <$argv[0]>〜</$argv[0]> 内の要素はすべてコメントで囲んだ方が安全です。
etago-in-cdata:et
  ENABLE *7
  <$argv[0]>〜</$argv[0]> 内に `</` を直接書くことはできません。
embedded-in-cdata:em embedded-in-cdata-0
  ENABLE 2           0.01
  <$argv[0]>〜</$argv[0]> 内$argv[3]に `$argv[1]` を書くときは外部に$argv[2]を用意しましょう。
comment-in-stylescript:cis
  ENABLE 0.1
  <$argv[0]>〜</$argv[0]> 内にコメントを書くと、本当にコメントとして扱われます。
@no-noscript:ns
  DISABLE 0.01
  <$argv[0]> タグがありますが、<$argv[1]> タグがありません。
title-length:tl
  ENABLE 1
  <$argv[0]> の内容は $argv[1]文字以内に収めるようにしましょう。
body-color:bc
  ENABLE 1
  <$argv[0]> での色指定が不完全です。$argv[1] 属性も含めるようにしましょう。
background:bg
  ENABLE 1
  <$argv[0]> で $argv[1] 属性を指定したときは $argv[2] 属性も指定するようにしましょう。
same-bgcolor:sbg
  ENABLE 3
  <$argv[0]> の $argv[1] 属性の色指定が $argv[2] の色と同じです。
near-bgcolor:nbg
  ENABLE 3
  <$argv[0]> の $argv[1] 属性の色指定と $argv[2] の色は$argv[3]が不十分です。
repeated-id:ri
  ENABLE 7
  <$argv[0]> の $argv[1] 属性の値 `$argv[2]` は $argv[3]行目ですでに使われています。
undef-id:ui
  ENABLE 7
  $argv[3]行目で参照されている <$argv[0]> の $argv[1] 属性の ID `$argv[2]` は定義されていません。
repeated-name:rn
  ENABLE 2
  <$argv[0]> の $argv[1] 属性の値 `$argv[2]` は $argv[3]行目ですでに使われています。
fieldset-whitespace:fsw
  ENABLE 3
  <$argv[1]> の直後に空白以外のテキストを書くことはできません。
multiple-checked:mc
  ENABLE 4
  <$argv[0] $argv[1]="$argv[2]"> に $argv[3] 属性が指定されていますが、$argv[4]行目ですでに指定されています。
no-checked:noc
  ENABLE 1
  どの <$argv[0] $argv[1]="$argv[2]" $argv[3]="$argv[4]"> にも $argv[5] 属性が指定されていません。
no-selected:nos
  ENABLE 1
  どの <$argv[0]> にも $argv[1] 属性が指定されていません。
multiple-selected:ms
  ENABLE 4
  <$argv[0]> に $argv[1] 属性が指定されていますが、$argv[2]行目ですでに指定されています。$argv[3]
over-select-options:oso
  ENABLE 4
  ひとつの <$argv[1]> 中に指定できる <$argv[0]> は $argv[2]件までです。
@default-text:dtx
  ENABLE 0.1
  <$argv[0]> には$argv[1]初期値となるテキストを指定しておきましょう。
input-type:int
  ENABLE 2
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
button-usemap:bu
  ENABLE 6
  <$argv[0]> に用いる <$argv[1]> には $argv[2] 属性を指定することはできません。
label-control:lc
  ENABLE 7
  <$argv[0]> をここに書くことはできません。$argv[1]行目の <$argv[2]>〜</$argv[2]> 内には $argv[3]行目に <$argv[4]> が含まれています。
label-no-control:lnc
  ENABLE 7
  FOR 属性の含まれない <$argv[0]>〜</$argv[0]> 内にはフォームコントロールを指定しなければなりません。
label-for-control:lfc
  ENABLE 1
  <$argv[0]> の$argv[4] 属性の値と $argv[1]行目の <$argv[2]> の $argv[3] 属性の値が食い違っています。
@form-tabindex:tb
  ENABLE 0.01
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
@form-accesskey:fak
  ENABLE 0.01
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
@recommended-title:t
  ENABLE 0.01
  <$argv[0]> には $argv[1] 属性$argv[2]を指定するようにしましょう。
object-text-equivalent:oq
  ENABLE 3
  <$argv[0]> には等価な内容を書くようにしましょう。
applet-text-equivalent:aq
  ENABLE 1
  <$argv[0]> に $argv[1] 属性と等価な内容の両方を書くことは薦められていません。
@alt-spaces:as
  ENABLE 2
  <$argv[0]> の $argv[1] 属性に空白だけの文字列を指定することは薦められていません。
img-alt:a
  ENABLE 7
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
*img-size:z
  ENABLE 0.01
  <$argv[0]> には $argv[1] と $argv[2] 属性を指定するようにしましょう。
img-map:im
  ENABLE 5
  <$argv[0]> には $argv[1] と $argv[2] 属性の両方を指定することはできません。
server-side-image-map:sm
  ENABLE 5
  <$argv[0] $argv[1]> でのサーバサイドイメージマップは使わず、クライアントサイドイメージマップを使いましょう。
@table-summary:su
  ENABLE 1
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
@abbr-header-label:ab
  ENABLE 0.01
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
colgroup-span:cgs
  ENABLE 4
  <$argv[2]> を要素に持つ <$argv[0]> には $argv[1] 属性を指定すべきではありません。
overlap-cells:oc
  ENABLE 8
  <$argv[0]> の $argv[1] 属性の指定と、$argv[2]行目の <$argv[3]> の $argv[4] 属性の指定が重なり合っています。
no-noframes:nf
  ENABLE 6
  <$argv[0]> タグがありますが、<$argv[1]> タグがありません。
same-document-frameset:sd
  ENABLE 8
  <$argv[0]> の $argv[1] 属性に自分自身を指す URI `$argv[2]` を指定することはできません。
frame-image:fi
  ENABLE 6
  <$argv[0]> の $argv[1] 属性で直接イメージなどを指定することは薦められていません。
frame-title:ft
  ENABLE 4
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
existing-target-name:xt
  ENABLE 5
  <$argv[0]> の $argv[1] 属性のフレームターゲット名 `$argv[2]` は $argv[3]行目ですでに指定されています。
reserved-target-name:rt
  ENABLE 5
  <$argv[0]> の $argv[1] 属性のフレームターゲット名 `$argv[2]` は予約されています。
reserved-target-name-upper:rtu
  ENABLE 0.1
  <$argv[0]> の $argv[1] 属性のフレームターゲット名 `$argv[2]` は小文字で書いたほうが安全です。
illegal-target-name:it
  ENABLE 6
  <$argv[0]> の $argv[1] 属性のフレームターゲット名 `$argv[2]` は正しくありません。
@physical-font:pf
  ENABLE 0.01
  <$argv[0]> は物理的フォントタグです。論理的タグを使うようにしましょう。$argv[1]
p-isnot-br:p
  ENABLE 4
  <$argv[0]> は段落のためのタグです。改行するタグは <$argv[1]> です。
continuous-brs:brs continuous-brs-fake
  ENABLE 0.8       7
  <$argv[0]> が多数連続しています。
tab-in-pre:tp
  ENABLE 3
  $argv[1]行目の <$argv[0]> 内にはタブ文字を書かないようにしましょう。
heading-order:ho
  ENABLE 4
  <$argv[0]> が $argv[2]行目の <$argv[1]> に続いていますが好ましくありません。
@heading-text-equivalent:hq
  ENABLE 1
  <$argv[0]>〜</$argv[0]> 内の <$argv[1]> の $argv[2] 属性には何か説明を書きましょう。
@link-accesskey:ak
  DISABLE 0.01
  <$argv[0]> には $argv[1] 属性を指定するようにしましょう。
@link-separation:ls
  ENABLE 0.9
  リンクとリンクの間は適当な文字で区切りましょう。
@link-text-equivalent:lq
  ENABLE 2
  リンクイメージの <$argv[1]> の $argv[2] 属性には何か説明を書きましょう。
@d-link:dl
  DISABLE 0.1
  <$argv[0]> の $argv[1] 属性の値 `$argv[2]` はあまり薦められません。$argv[3] 属性を利用しましょう。
@same-link-text:slt
  ENABLE 1
  <$argv[0]> のアンカー `$argv[1]` は $argv[2]行目で異なるリンク先を指しています。
@here-anchor:h
  ENABLE 1
  <$argv[0]> のアンカーとして `$argv[1]` などを使うのは好ましくありません。
@here-anchor-alt:ha
  ENABLE 1
  <$argv[0]> のアンカーとして <$argv[1]> の $argv[2] 属性の値に `$argv[3]` などを使うのは好ましくありません。
fragment-id-whitespace:fw
  ENABLE 1
  <$argv[0]> のアンカー名 `$argv[1]` 中に空白文字が含まれています。
unsafe-fragment-id:uf
  ENABLE 1
  <$argv[0]> のアンカー名 `$argv[1]` 中に安全でない文字が含まれています。
empty-fragment-id:ef
  ENABLE 5
  <$argv[0]> のアンカー名が空です。
existing-fragment-id:xf
  ENABLE 5
  <$argv[0]> のアンカー名 `$argv[1]` は $argv[2]行目にもありました。
case-insensitive-fragment-id:cf
  ENABLE 2
  <$argv[0]> のアンカー名 `$argv[1]` は $argv[2]行目にもありました。大文字小文字は区別されない可能性があります。
same-fragment-id:sf
  ENABLE 5
  <$argv[0]> のアンカー名 `$argv[1]` は $argv[2]行目で $argv[3] 属性としても指定されています。
*id-link:il
  ENABLE 0.01
  <$argv[0]> のアンカー名 `$argv[1]` は $argv[2]行目で $argv[3] 属性として定義されています。
diff-id-link:dil
  ENABLE 4
  <$argv[0]> の $argv[1] 属性の値 `$argv[2]` と $argv[3] 属性の値 `$argv[4]` は、同一タグ中では同じでなければなりません。
need-id-name:nin
  ENABLE 0.3
  <$argv[0]> には $argv[1] 属性と $argv[2] 属性の両方を指定するようにしましょう。
lower-id:lid
  ENABLE 2
  <$argv[0]> の $argv[1] 属性の値 `$argv[2]` には小文字を含めないようにしましょう。
bad-link:bl
  ENABLE 6
  <$argv[0]> のアンカー名 `$argv[1]` が見つかりませんでした。
*unref-link:ul
  DISABLE 0.01
  <$argv[0]> のアンカー名 `$argv[1]` は参照されていません。
empty-url:eu
  ENABLE 5
  <$argv[0]> の $argv[1] 属性の URI が空です。
url-whitespace:uw
  ENABLE 3
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` 中に空白文字が含まれています。
url-backslash:ub
  ENABLE 3
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` 中に `\` が含まれています。パスの区切りは `/` でなければなりません。
*unsafe-url:uu
  DISABLE 0.01
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` 中に `$argv[3]` が含まれています。$argv[4] と書いた方が安全です。
excluded-url:xu
  ENABLE 1
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` 中に使用できない文字 `$argv[3]` が含まれています。$argv[4] と書かなければなりません。
excluded-url-ref:xur
  ENABLE 1
  <$argv[0]> の $argv[1] 属性の URI 中の実体参照 `$argv[2]` は使用できない文字 `$argv[3]` です。
no-corresponding-url:nu
  ENABLE 7
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` 中に ASCII以外の文字が含まれています。
illegal-protocol:ip
  ENABLE 7
  <$argv[0]> の $argv[1] 属性の URI に指定されているスキーム名 `$argv[2]` は正しくありません。
upper-protocol:upp
  ENABLE 0.3
  <$argv[0]> の $argv[1] 属性の URI のスキーム名 `$argv[2]` は小文字で指定しましょう。
unknown-protocol:up
  ENABLE 1
  <$argv[0]> の $argv[1] 属性の URI に不明のスキーム名 `$argv[2]` が指定されています。
local-protocol:lp
  ENABLE 5
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` はインタネット上から参照できないかも知れません。
cantuse-protocol:cup
  ENABLE 5
  <$argv[0]> の $argv[1] 属性の URI のスキーム `$argv[2]` は利用できません。
@javascript-url:js
  ENABLE 0.01
  <$argv[0]> の $argv[1] 属性の URI に指定されているスキーム `$argv[2]` の利用は薦められていません。
illegal-format-url:if
  ENABLE 4
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` は正しくない書式です。
trailing-slash:ts
  ENABLE 2
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` は `/` で終わらせるようにしましょう。
net-path:np
  ENABLE 3
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` はうまく評価されないかも知れません。
*conflict-directory:cd
  DISABLE 0.01
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` は $argv[3]行目で `$argv[4]` と指定されています。
*index-html:ih
  ENABLE 1
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` は $argv[3]行目で `$argv[4]` と指定されています。
later-base:lb
  ENABLE 5
  <$argv[0]> の $argv[1] 属性で指定するより前に $argv[2]行目で相対 URI が指定されています。
absolute-base-url:abu
  ENABLE 6
  <$argv[0]> の $argv[1] 属性の URI は絶対位置で指定しなければなりません。
unexpected-end-of-html:xh
  ENABLE *9
  </$argv[0]> の後にまだ何かテキストがあります。
over-file-size:ofs
  ENABLE *9
  $argv[1] では、HTML文書は $argv[2]Kバイト以内でなければなりません。
unsupported-image:uim
  ENABLE 5
  <$argv[0]> の $argv[1] 属性の URI `$argv[2]` が $argv[4] ではありません。$argv[3] ではイメージは $argv[4] でなければなりません。
jskyweb-olul:jolul
  ENABLE 8
  <$argv[0]> の入れ子が深過ぎます。<UL>、<OL> の入れ子は $argv[1]階層以内でなければなりません。
jskyweb-li:jli
  ENABLE 8
  $argv[1] 中に指定できる <$argv[0]> は $argv[2]個までです。
jpo-no-html:jnh
  ENABLE *9
  $argv[1] は <$argv[0]> から始まらなければなりません。
jpo-shift-jis:jsj
  ENABLE *9
  $argv[1] は $argv[2] で記述しなければなりません。
jpo-bad-char:jbc
  ENABLE 1
  $argv[1] では `$argv[2]` を使うことはできません。
