#!/usr/local/bin/perl

# 規則ファイルから要素一覧HTMLを生成する

# history : 0.00 1997/08/14 着手
#           0.10 1997/08/18 最初のリリース
#           0.11 1997/08/20 省略可能タグに <FONT COLOR=GRAY>
#           0.12 1997/08/24 実体宣言
#           0.13 1997/08/28 htmllint.env
#           0.14 1997/10/15 Mnemonic Entities 出力をちょっと修正
#           0.15 1997/11/02 Cougar 1997/10/25
#           0.16 1997/12/03 ALL
#           0.17 1997/12/15 属性値の表示
#           0.18 1997/12/26 スペルミス (suzuki kazuaki)
#           0.19 1998/02/03 Cougar の Transitional/Frameset の分離
#           0.20 1998/02/05 Cougar Strict の追加
#           0.21 1998/03/05 IE3.0 beta
#           0.22 1998/04/01 TAG:ATTR から TAG/ATTR に変更
#           0.23 1998/05/06 CDATA+
#           0.24 1998/06/03 BODY に色属性追加
#           0.25 1998/07/04 CGI パラメータを common.rul 依存に変更
#           0.26 1998/08/22 nkf は使わないようにした
#           0.27 1998/09/02 拡張子を .cgi に変更
#           0.28 1998/09/10 $HTMLDIR を参照していない個所があった (前仲 Tetsu)
#           0.29 1998/10/08 親の要素も表示するようにした
#           0.30 1998/11/29 生成HTMLをキャッシュできるようにした
#           0.31 1999/07/15 CGI.pm Jcode.pm
#           0.32 1999/07/29 ナヴィゲーション情報
#           0.33 1999/09/04 $& $' $` の排除
#           0.34 1999/11/01 IE5 custom Element
#           0.35 1999/11/03 %attrValues 廃止、%tagsAttributes に統合
#           0.36 1999/11/08 属性出力の調整
#           0.37 2000/01/03 HTML4.01
#           0.38 2000/01/30 #FIXED属性用の調整
#           0.39 2000/02/01 XHTML
#           0.40 2000/10/19 J-SkyWeb Station
#           0.41 2001/01/07 "./xxx.html" -> "${HTMLDIR}xxx.html" (草野貴之)
#           0.42 2001/01/13 <tag />
#           0.43 2001/01/16 表の色分け、要素名属性名を小文字に
#           0.44 2001/03/06 実体参照がどう表示されるのかも出力
#           0.45 2001/03/29 NUMBER+
#           0.46 2003/02/11 XHTMLかどうかの判定修正
#           0.47 2004/04/17 非CGIの判定に$ENV{QUERY_STRING}も利用 (半田哲夫)
#           0.48 2004/12/14 軽い→簡易
#           0.49 2005/04/24 Character Mnemonic Entities の表示不正 (水無月ばけら)
$VERSION = '0.49';

$myADDRESS = 'k16@chiba.email.ne.jp';

$version = <<EndOfVersion;
  Another HTML-lint Tags list script ver$VERSION
    Copyright (c) 1997-2006 by ISHINO Keiichiro <$myADDRESS>.
    All rights reserved.
EndOfVersion

use File::Basename;
$CGI_NAME = &basename($0);

$WIN = $^O =~ /Win32/oi;
$MAC = $^O =~ /MacOS/oi;
#$OS2 = UNSUPPORTED;
$UNIX = !($WIN || $MAC || $OS2);
#$SEP = $MAC? ':': '/';

require 'htmllint.env';
require 'common.rul';
use CGI qw(:cgi-lib);
if ($Jcode = (!$NOUSEJCODE && eval('require Jcode'))) {
  *Jgetcode = \&Jcode::getcode;
  *Jconvert = \&Jcode::convert;
} else {
  require 'jcode.pl';
  *Jgetcode = \&jcode::getcode;
  *Jconvert = sub { &jcode::to($_[1], $_[0], $_[2]); }
}
  $USERAGENT = ($ENV{'HTTP_USER_AGENT'} =~ /Mozilla/)?
               ($ENV{'HTTP_USER_AGENT'} =~ /MSIE/)? 'MSIE':
               ($ENV{'HTTP_USER_AGENT'} =~ /iCab/)? 'iCab':
                                                    'Mozilla': '';
  ($USERAGENTVER) = ($ENV{'HTTP_USER_AGENT'} =~ /$USERAGENT\D+(\d+(?:\.\d+)?)/o);
$gw = ($USERAGENT eq 'MSIE' && $USERAGENTVER >= 4.0)? 'htmllinte.html': 'htmllint.html';

undef $TAGSLIST unless $TAGSLIST && -d $TAGSLIST;

$gray        = '#666666';
$altcolcolor = '#CCFFFF';
$altrowcolor = '#FFFFCC';
$TagHeader = <<EndOfTagHeader;
<table width="100%" border="0">
<tr><td align="right" valign="top" rowspan="5">凡例　</td><td align="center">◎</td><td>　サポートされているタグ (終了タグあり)</td><td align="right">　<a href="${HTMLDIR}index.html">Another HTML-lint について</a></td></tr>
<tr><td align="center">○</td><td>　サポートされているタグ (終了タグなし)</td><td align="right">　<a href="${HTMLDIR}$gw">ゲートウェイサーヴィス</a></td></tr>
<tr><td align="center">×</td><td>　サポートされていないタグ</td><td align="right">　<a href="${HTMLDIR}htmllintl.html">簡易ゲートウェイ</a></td></tr>
<tr><td align="center"><font color="$gray">[　]</font></td><td>　薦められないタグ</td><td align="right">　<a href="${HTMLDIR}explain.html">結果の解説</a></td></tr>
</table><br>
EndOfTagHeader
$AttrHeader = <<EndOfAttrHeader;
<table width="100%" border="0">
<tr><td align="right" valign="top" rowspan="6">凡例　</td><td align="center">◎</td><td>　サポートされているタグ (終了タグあり)</td><td align="right">　<a href="${HTMLDIR}index.html">Another HTML-lint について</a></td></tr>
<tr><td align="center">○</td><td>　サポートされているタグ (終了タグなし)</td><td align="right">　<a href="${HTMLDIR}$gw">ゲートウェイサーヴィス</a></td></tr>
<tr><td align="center">◎</td><td>　サポートされている必須属性</td><td align="right">　<a href="${HTMLDIR}htmllintl.html">簡易ゲートウェイ</a></td></tr>
<tr><td align="center">○</td><td>　サポートされている属性</td><td align="right">　<a href="${HTMLDIR}explain.html">結果の解説</a></td></tr>
<tr><td align="center">×</td><td>　サポートされていないタグ/属性</td></tr>
<tr><td align="center"><font color="$gray">[　]</font></td><td>　薦められないタグ/属性</td></tr>
</table><br>
EndOfAttrHeader
$myCODE = &Jgetcode(\$AttrHeader); # euc または sjis
my $bannerCommercial = $NOCOMMERCIAL? '': '';

$rule = shift(@ARGV);
if ($nocgi = ($ENV{QUERY_STRING} eq '' && $rule ne '')) {
  # 非 CGI インタフェース
  if ($rule eq '-v') {
    print $version;
    exit;
  }
  $CHARSET = ($myCODE eq 'sjis')? 'Shift_JIS': 'EUC-JP';
  $outCODE = $myCODE;
  if ($rule =~ /^v=(.*)/oi) {
    $tag = '';
    $rule = $1;
  }
  if ($rule =~ /^a=(.*)/oi) {
    $tag = $1;
    $rule = '';
  }
} else {
  &ReadParse(); # GET/POST データを %in に読む
  # HTMLヴァージョン
  $rule = '';
  foreach (keys %doctypes) {
    if ($in{'HTMLVersion'} =~ /^(${$doctypes{$_}}{'name'})$/i) {
      $rule = $_;
      last;
    }
  }
  $tag = $in{'Element'};
  # 出力する漢字コードの選択
  my $ccode = ($in{'CharCode'} or $KANJICODE or 'JIS');
  if ($ccode =~ /^EUC$/oi) {
    $outCODE = 'euc';
    $CHARSET = 'EUC-JP';
  } elsif ($ccode =~ /^SJIS$/oi) {
    $outCODE = 'sjis';
    $CHARSET = 'Shift_JIS';
  } else { # $ccode =~ /^JIS$/oi
    $outCODE = 'jis';
    $CHARSET = 'ISO-2022-JP';
  }
}
if ($TAGSLIST) {
  # 規則ファイルの日付を調べる
  $RULETIME = (stat($0))[9];
  foreach (keys %doctypes) {
    my $t = (stat($RULEDIR.$_.'.rul'))[9];
    $RULETIME = $t if $RULETIME < $t;
  }
}
$rule = 'all' unless $rule;
$| = 1;

$charData = 'CDATA|NUMBER|NAME|NMTOKEN|NUTOKEN'.
            '|NUMBERS|NAMES|NMTOKENS|NUTOKENS|ID|IDREF|ENTITY';
$internalElem = '#\d+';

if ($tag) {
  $tag = "\U$tag";
  &SelectTAGSLIST($tag);
  &PrintHTTPHeader unless $TAGSLIST;
  &PrintHTMLHeader("All of ${tag}'s Attributes");
  &Jprint(qq|<h2>&lt;\L$tag&gt; |, 'の属性一覧', qq|</H2>\n|, $AttrHeader,
          qq|<table border="1" cellspacing="0" cellpadding="1" class="border">\n|);
  &Jprint(q|<col><col>|);
  my $n = 0;
  foreach $rule (keys %doctypes) {
    &Jprint((++$n&1)? qq|<col bgcolor="$altcolcolor">|: '<col>');
  }
  &Jprint(qq|\n<tr><td><th>\n|);
  foreach $rule (sort { ${$doctypes{$a}}{'order'} <=> ${$doctypes{$b}}{'order'} }
                 keys %doctypes) {
    local($emptyTags, $pairTags, $deprecatedTags);
    local(%tagsAttributes, %requiredAttrs,
          %deprecatedElems, %deprecatedAttrs, %deprecatedAttrsCss, %deprecatedVals);
    do $rule.'.rul';
    &RuleName($rule);
    $empty{$rule} = $emptyTags;
    $pair{$rule}  = $pairTags;
    $attrs{$rule} = join('|', sort keys %{$tagsAttributes{$tag}});
    $deprecatedTag{$rule}  = $deprecatedTags;
#   $deprecatedElem{$rule} = $deprecatedElems{$tag};
    $deprecatedAttr{$rule} = ($deprecatedAttrs{$tag} eq '')?
                                $deprecatedAttrsCss{$tag}:
                             ($deprecatedAttrsCss{$tag} eq '')?
                                $deprecatedAttrs{$tag}:
                                $deprecatedAttrs{$tag}.'|'.$deprecatedAttrsCss{$tag};
    foreach (split(/&/, $requiredAttrs{$tag})) {
      next if /\|/;
      $required{$rule}? ($required{$rule} .= '|'.$_): ($required{$rule} = $_);
    }
    foreach $attr (split(/\|/, $attrs{$rule})) {
      $attr{$attr}++;
      my $val = $tagsAttributes{$tag}->{$attr};
      if ($val !~ /^%/o && $val !~ /^($charData)$/o && $val ne 'CDATA+') {
        foreach (split(/\|/, $val)) {
          my $v = "$attr=\L$_";
          $attr{$v}++;
          $attrs{$rule} = join('|', $attrs{$rule}, $v);
        }
      }
    }
  }
  &Jprint(qq|</tr>\n|);
  &PrintTag(0, $tag, $rule);
  $n = 0;
  foreach $attr (sort keys %attr) {
    my $va = '';
    my $v = '';
    if ($attr =~ /^([^=]*)(=.*)/o) {
      $v = $2;
      $va = $1;
      &Jprint(($n&1)? qq|<tr bgcolor="$altrowcolor">|: '<tr>');
      &Jprint(qq|<td align="right" nowrap><a name="$attr">$v</a></td>|);
    } else {
      $n++;
      my $i = 0;
      foreach (keys %attr) { $i++ if /^$attr=/; }
      &Jprint(($n&1)? qq|<tr bgcolor="$altrowcolor">|: '<tr>');
      &Jprint(qq|<td align="right"|);
      &Jprint(qq| valign="top" rowspan="$i"|) if $i++;
      &Jprint(qq|>$n<td nowrap><a name="$attr">\L$attr</a></td>|);
    }
    foreach $rule (sort { ${$doctypes{$a}}{'order'} <=> ${$doctypes{$b}}{'order'} }
                   keys %doctypes) {
      &Jprint(q|<td align="center">|);
      my $ar = $attrs{$rule};
      my $mark = ($v && $va !~ /^($ar)$/)? '　':
                 ($attr =~ /^($ar)$/)?
                 ($attr =~ /^($required{$rule})$/)? '◎': '○':
                 ($attr =~ /^([^=]*)=/o)? ($ar =~ /(^|\|)$1=/)? '×': '　': '×';
      if ($attr =~ /^($deprecatedAttr{$rule})$/ ||
          ($va && $va =~ /^($deprecatedAttr{$rule})$/)) {
        my $m = ($mark eq '×')? $mark: "[$mark]";
        &Jprint(qq|<font color="$gray">$m</font>|);
      } else {
        &Jprint($mark);
      }
      &Jprint(q|</td>|);
    }
    &Jprint(qq|</tr>\n|);
  }
  &Jprint(qq|</table>\n|);
  &PrintHTMLFooter;
  &CloseTAGSLIST;
} elsif ($rule =~ /^ALL$/oi) {
  &SelectTAGSLIST('_all');
  &PrintHTTPHeader unless $TAGSLIST;
  &PrintHTMLHeader('All of TAGs');
  &Jprint(qq|<h2>Another HTML-lint |, 'が知っているタグ一覧', qq|</h2>\n|, $TagHeader,
          qq|<table border="1" cellspacing="0" cellpadding="1" class="border">\n|);
  &Jprint(q|<col><col>|);
  my $n = 0;
  foreach $rule (keys %doctypes) {
    &Jprint((++$n&1)? qq|<col bgcolor="$altcolcolor">|: '<col>');
  }
  &Jprint(qq|\n<tr><td><th>\n|);
  my $n = 0;
  foreach $rule (sort { ${$doctypes{$a}}{'order'} <=> ${$doctypes{$b}}{'order'} }
                 keys %doctypes) {
    local($emptyTags, $pairTags, $deprecatedTags);
    do $rule.'.rul';
    &RuleName($rule);
    $empty{$rule} = $emptyTags;
    $pair{$rule}  = $pairTags;
    $deprecatedTag{$rule} = $deprecatedTags;
    foreach (split(/\|/, $empty{$rule})) { $tag{$_}++ if /^\w/; }
    foreach (split(/\|/, $pair{$rule}))  { $tag{$_}++ if /^\w/; }
  }
  &Jprint(qq|</tr>\n|);
  $n = 0;
  foreach (sort keys %tag) { &PrintTag(++$n, $_, $rule); }
  &Jprint(q|<tr><td><th>|);
  foreach $rule (sort { ${$doctypes{$a}}{'order'} <=> ${$doctypes{$b}}{'order'} }
                 keys %doctypes) {
    @tmp = (split(/\|/, $pair{$rule}), split(/\|/, $empty{$rule}));
    &Jprint(q|<td align="center">|, $#tmp+1);
  }
  &Jprint(qq|</tr>\n</table>\n|);
  &PrintHTMLFooter;
  &CloseTAGSLIST;
} else {
  &SelectTAGSLIST($rule);
  require $rule.'.rul';
  $html = ${$doctypes{$rule}}{'guide'};
  $xhtml = ${$doctypes{$rule}}{'version'} >= 5.0;
  &PrintHTTPHeader unless $TAGSLIST;
  &PrintHTMLHeader("$html Tags List");
  &Jprint(qq|<h2>$html</h2>\n|, q|<dl><dt>All of TAGs<dd>|);
  foreach $tag (sort split(/\|/o, $emptyTags), split(/\|/o, $pairTags)) {
    my $tagn = $xhtml? lc($tag): $tag;
    &Jprint(qq|<a href="#$tag">&lt;$tagn&gt;</a>\n|) if $tag =~ /^\w/;
  }
  &Jprint(qq|<br><br><dt><a href="#Mnemonic">Character Mnemonic Entities</a>\n|,
          qq|</dl>\n|);

  &Jprint(qq|<hr>\n<dl>\n|);
  foreach $tag (keys %tagsElements) {
    next unless $tag =~ /^\w/o;
    my $ent = $tagsElements{$tag};
    next if $ent =~ /^%/o;
    $ent = &ExpandInternalElements($ent);
    foreach (split(/\|/o, $ent)) {
      if (/^($emptyTags|$pairTags)$/) {
        if ($tagsParents{$_} eq '') {
          $tagsParents{$_} = $tag;
        } elsif ($tag !~ /^($tagsParents{$_})$/) {
          $tagsParents{$_} .= '|'.$tag;
        }
      }
    }
  }
  foreach $tag (sort split(/\|/o, $emptyTags), split(/\|/o, $pairTags)) {
    next unless $tag =~ /^\w/o;
    local(@pcdata, $nonpcdata);
    my $tagn = "&lt;$tag&gt;";
    my $pair = $tag =~ /^($pairTags)$/;
    if ($xhtml) {
      $pair = $pair && $tagsElements{$tag};
      $tagn = $pair? '&lt;'.lc($tag).'&gt;':
                     '&lt;'.lc($tag).' /&gt;';
    }
    &Jprint(qq|<dt><a name="$tag">|, ($tag =~ /^($omitStartTags)$/)?
            qq|<font color="$gray">$tagn</font>|: $tagn);
    if ($pair) {
      $tagn = '&lt;/'.($xhtml? lc($tag): $tag).'&gt;';
      &Jprint((($tag =~ /^($omitEndTags)$/)?
              qq|<font color="$gray"> - $tagn</font>|: qq| - $tagn|));
    }
    &Jprint(qq|</a><br>\n|);
    if ($tagsAttributes{$tag}) {
      &Jprint(qq|<dd><dl><dt>Attributes\n|);
      foreach $attr (sort keys %{$tagsAttributes{$tag}}) {
        &Jprint('<dd>', $xhtml? lc($attr): $attr);
        local($val) = $tagsAttributes{$tag}->{$attr};
        if ($val =~ /=(.*)/o) {
          $val = $1;
          &Jprint(qq| = $val|);
        } else {
          if ($val =~ /^%(.*)/o) {
            my $ref = $refParams{$1};
            $ref = $1 if $ref =~ /^\(\?i\)(.*)/o;
            $ref =~ s/\(\?:/\(/og;
            my $OLStyle = ($rule =~ /^(imode|jsky|doti)/)? '1|a|A': '1|a|A|i|I';
            if ($ref =~ /^($charData)$/o) {
              $val = $ref;
            } elsif ($ref eq '[\x20-\x7E]') {
              $val = '<cite>character</cite>';
            } elsif ($ref eq '\d+') {
              $val = 'NUMBER';
            } elsif ($ref eq '\d+[%]?' || $ref eq '\d+%?') {
              $val = '<cite>number</cite>[<cite>%</cite>]';
            } elsif ($ref eq '\d+(pt)?') {
              $val = '<cite>number</cite>[<cite>pt</cite>]';
            } elsif ($ref eq '\d+(\.\d+\*)?') {
              $val = '<cite>decimal</cite>';
            } elsif ($ref eq '(\d+(\s*,\s*|\s+))+\d+') { # coord
              $val = '<cite>number</cite>[, <cite>number</cite>]...';
            } elsif ($ref eq '\d+(\.\d+)?(\*|%)?') { # MultiLength
              $val = '<cite>*</cite>|<cite>number</cite>[<cite>*</cite>|<cite>%</cite>]';
            } elsif ($ref eq '-1|\d+') {
              $val = '<cite>-1</cite>|<cite>number</cite>';
            } elsif ($ref eq '((\d+[*%]?|\*)\s*,\s*)*(\d+[*%]?|\*)' || # MultiLengths
                     $ref eq '((\d+(\.\d+)?(\*|%)?|\*)\s*,\s*)*(\d+(\.\d+)?(\*|%)?|\*)') {
              $val = '<cite>*</cite>|<cite>number</cite>[<cite>*</cite>|<cite>%</cite>] [, <cite>*</cite>|<cite>number</cite>[<cite>*</cite>|<cite>%</cite>]]...';
            } elsif ($ref eq '(GET|POST)(\s*,\s*(GET|POST))*') { # HTTP-Methods
              $val = 'getpost[, getpost]...';
            } elsif ($ref eq '\w+') {
              $val = '<cite>0..9 A..Z a..z</cite>';
            } elsif ($ref eq '[0-9#\*\/,]') {
              $val = '<cite>0..9 # * , /</cite>';
            } elsif ($ref eq '[0-9#\*]') {
              $val = '<cite>0..9 # *</cite>';
            } elsif ($ref eq '[0-9]') {
              $val = '<cite>0..9</cite>';
            } elsif ($ref eq '[1-9]') {
              $val = '<cite>1..9</cite>';
            } elsif ($ref eq '[1-7]') {
              $val = '<cite>1..7</cite>';
            } elsif ($ref eq '[+|-]?[1-7]') {
              $val = '<cite>[+|-]1..7</cite>';
            } elsif ($ref eq '[^\s,]+(\s*,\s*[^\s,]+)*') { # face
              $val = '<cite>name</cite>[, <cite>name</cite>]...';
            } elsif ($ref eq '\d+|BORDER') { # border
              $val = '[<cite>number</cite>]';
            } elsif ($ref eq '[A-Z]{1,8}(-[A-Z]{1,8})*') { # lang
              $val = '<cite>lang</cite>';
            } elsif ($ref eq '&URL') {
              $val = '<cite>URL</cite>';
            } elsif ($ref eq '&LIStyle') {
              $val = $OLStyle.'|'.$tagsAttributes{'UL'}->{'TYPE'};
            } elsif ($ref eq '&OLStyle') {
              $val = $OLStyle;
            } elsif ($ref =~ /^#\[0\-9A\-F\]\{6\}\|?(.*)/) { # color
              $val = '<cite>#rrggbb</cite>';
              $val .= '|<a href="#Colors"><cite>colors</cite></a>' if $colors = $1;
            } elsif ($ref =~ /^infinite\|\[1\-9\]\|\[1\-4\]\[0\-9\]\|50/) { # viblength
              $val = '<cite>1..50</cite>|INFINITE';
            } elsif ($ref eq 'CDATA+') {
              $val = 'CDATA';
            } elsif ($ref eq 'NUMBER+') {
              $val = '<cite>1..</cite>';
            } else {
              ($val = $ref) =~ s/\\//og;
            }
          }
          if ($val =~ /^($charData)$/o) {
            $val = "<cite>"."\L$val"."</cite>";
          }
          if ($attr ne $val) {
            $val =~ s/(\w|\d|>)\|/$1 \| /og;
            if ($val =~ /^\[(.+)\]$/o) { &Jprint(qq| [= $1]|); }
            else { &Jprint(qq| = $val|); }
          }
        }
        &Jprint(qq|\n|);
      }
      &Jprint(qq|</dl>\n|);
    }
    if ($pair) {
      &Jprint(q|<dd><dl><dt>Contents<dd>|);
      my $ent = $tagsElements{$tag};
      my $last;
      $ent = ($ent =~ /^%(.*)/o)? $refParams{$1}: &ExpandInternalElements($ent);
      foreach (sort split(/\|/o, $ent)) {
        next unless /^[\w#]/;
        if (/^($emptyTags|$pairTags)$/) {
          if ($last ne $_) {
            my $tagn = $xhtml? lc: $_;
            &Jprint(qq|<a href="#$_">&lt;$tagn&gt;</a>\n|);
            $nonpcdata++;
            $last = $_;
          }
        } else {
          push(@pcdata, $_);
        }
      }
      if (@pcdata) {
        &Jprint(q|<dd>|) if $nonpcdata;
        foreach (sort @pcdata) {
          if ($last ne $_) {
            &Jprint(qq|$_\n|);
            $last = $_;
          }
        }
      }
      &Jprint(qq|</dl>\n|);
    }
    if ($tagsParents{$tag}) {
      &Jprint(q|<dd><dl><dt>Parents<dd>|);
      my $ent = $tagsParents{$tag};
      foreach (sort split(/\|/o, $ent)) {
        next unless /^[\w#]/;
        my $tagn = $xhtml? lc: $_;
        &Jprint(qq|<a href="#$_">&lt;$tagn&gt;</a>\n|);
      }
      &Jprint(qq|</dl>\n|);
    }
    &Jprint(qq|<br>\n|);
  }
  &Jprint(qq|</dl>\n|);

  if ($colors) {
    &Jprint(qq|<hr><dl><dt><a name="Colors" href="${HTMLDIR}colors.html">Color Values</a><dd>\n|);
    $colors =~ s/\|/ \| /og;
    &Jprint(qq|\U$colors|, qq|\n</dl>\n|);
  }

  $len = 0;
  foreach (keys(%refEntities)) { $len = length if $len < length; }
  $len += 6;
  &Jprint(qq|<hr><dl><dt><a name="Mnemonic">Character Mnemonic Entities</a><dd><pre>\n|);
  foreach (sort { ($diga) = $refEntities{$a} =~ /&#(\d+);/o;
                  ($digb) = $refEntities{$b} =~ /&#(\d+);/o; $diga <=> $digb;
                } keys(%refEntities)) {
    my $ent = $refEntities{$_};
    $ent =~ /(?:&#38;)?&#(\d+);/o;
    my $dig = $1;
#   $dig = 0x20 unless $dig >= 0x20 && $dig <= 0x7E;
    $elen = 16-length($ent);
    $ent = sprintf("%-${len}s  %s", "&$_;", $ent);
    $ent =~ s/&/&amp;/og;
    $ent =~ s/</&lt;/og;
    $ent =~ s/>/&gt;/og;
    &Jprint($ent, ' ' x $elen, "&#$dig;\n");
  }
  &Jprint(qq|</pre></dl>\n|);
  &PrintHTMLFooter;
  &CloseTAGSLIST;
}
exit(0);

sub Jprint
{
# if ($myCODE ne $outCODE) {
    foreach (@_) { print &Jconvert($_, $outCODE, $myCODE); }
# } else {
#   print @_;
# }
}

##################################################

sub RuleName
{
  my $rule = shift;
  my $name = ${$doctypes{$rule}}{'abbr'};
  $name =~ s/([^\d\.])([\d\.]+)/$1 $2/o;
  $name =~ s/([\d\.]+)([^\d\.x])/$1 $2/o;
  $name =~ s/Navigator|Communicator/Mozilla/o;
  $name =~ s/WebExplorer/WebExp/o;
  &Jprint(qq|<th><a href="${CGIROOT}${CGI_NAME}?HTMLVersion=$rule">$name</a></th>|);
}

sub PrintTag
{
  my($n, $tag, $rule, $ptag) = @_;
  &Jprint(($n&1)? qq|<tr bgcolor="$altrowcolor">|: '<tr>', $n?
          qq|<td align="right">$n</td><td align="center" nowrap>&lt;<strong><a name="$tag" href="${CGIROOT}${CGI_NAME}?Element=$tag">|:
          qq|<td><td align="center">&lt;<strong><a href="${CGIROOT}${CGI_NAME}#$tag">|,
          lc($tag),
          qq|</a></strong>&gt;</td>|);
  foreach $rule (sort { ${$doctypes{$a}}{'order'} <=> ${$doctypes{$b}}{'order'} }
                 keys %doctypes) {
    &Jprint(q|<td align="center">|);
    my $mark = ($tag =~ /^($pair{$rule})$/)?  '◎':
               ($tag =~ /^($empty{$rule})$/)? '○': '×';
    if ($tag =~ /^($deprecatedTag{$rule})$/) {
      &Jprint(qq|<font color="$gray">[$mark]</font>|);
    } else {
      &Jprint($mark);
    }
    &Jprint(q|</td>|);
  }
  &Jprint(qq|</tr>\n|);
}

##################################################
# #NNN 形式の内部要素を展開する

sub ExpandInternalElements
{
  my $elem = shift;
  $elem =~ s/($internalElem)/&ExpandInternalElements($tagsElements{$1})/oge;
  $elem;
}

##############################################################
# HTML ヘッダ部分を出力する (PrintHeaderという関数は既存)

sub PrintHTTPHeader
{
  print qq|Content-Type: text/html; charset=$CHARSET\x0D\x0A\x0D\x0A| unless $nocgi;
}
sub PrintHTMLHeader
{
  my $title = shift;
  my $brclear = $bannerCommercial? '<br clear="all">': '';
  &Jprint(<<EndOfHTMLHeader);
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="ja"><head>
<meta http-equiv="Content-Type" content="text/html; charset=$CHARSET">
<link rel="stylesheet" type="text/css" href="${HTMLDIR}htmllint.css">
<link rel="contents" href="${HTMLDIR}tagslist.html">
<title>$title</title></head>
<body bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#660066" alink="#FF0000">
<div align="center" class="nav">$bannerCommercial
[<a href="${HTMLDIR}index.html">about</a>]
[<a href="${HTMLDIR}sitemap.html">sitemap</a>]
[<a href="${HTMLDIR}$gw">gateway</a>]
[<a href="${HTMLDIR}tagslist.html">tagslist</a>]$brclear
</div><hr>
EndOfHTMLHeader
}

##############################################################
# HTML フッタ部分を出力する

sub PrintHTMLFooter
{
  &Jprint(<<EndOfHTMLFooter);
<hr>
<div align="center">
<address>This page was generated by $CGI_NAME $VERSION<br>
1997-2006 \&#xA9; by <!--a href="mailto:k16\@chiba.email.ne.jp"-->k16\@chiba.email.ne.jp<!--/a--></address></div>
<hr><div align="center" class="nav">$bannerCommercial
[<a href="${HTMLDIR}index.html">about</a>]
[<a href="${HTMLDIR}sitemap.html">sitemap</a>]
[<a href="${HTMLDIR}$gw">gateway</a>]
[<a href="${HTMLDIR}tagslist.html">tagslist</a>]
</div>
</body>
</html>
EndOfHTMLFooter
}

##############################################################

sub SelectTAGSLIST
{
  my $file = shift;
  if ($TAGSLIST) {
    $tagslist = $TAGSLIST.$file.'.html';
    if ((stat($tagslist))[9] > $RULETIME) {
      &EchoHTML($tagslist) and exit(0);
      undef $TAGSLIST;
    } else {
      if (open TAGSLIST, ">$tagslist") {
        select TAGSLIST;
      } else {
        undef $TAGSLIST;
      }
    }
  }
}

sub CloseTAGSLIST
{
  if ($TAGSLIST) {
    close TAGSLIST;
    chmod 0764, $tagslist if $UNIX;
    select STDOUT;
    &EchoHTML($tagslist);
  }
}

sub EchoHTML
{
  my $html = shift;
  if (open HTML, $html) {
    $| = 1;
    &PrintHTTPHeader;
    print $_ while <HTML>;
    close HTML;
    return 1;
  }
  0;
}
