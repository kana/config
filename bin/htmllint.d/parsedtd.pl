#!/usr/local/bin/perl

# Simple DTD Parser for HTML ##########################

# HTML の DTD を読んで、HTML-lint が使用する情報を出力する。
# この出力をそのまま使用してもよいが、たいていは、Perl の正規表現を利用した値に
# 加工したり、DTD 中のコメントを反映させたりしてから使用する。
# HTML-lint で使用するこれらの情報は、wilbur.rul 等ファイル名が固定されているので
# 必要ならば調整する必要がある。

# history : 0.00 1997/06/06 着手
#           0.10 1997/06/23 最初のリリース
#           0.11 1997/06/29 細かいバグ修正
#           0.12 1997/07/01 %tagsAttributes は不要
#           0.13 1997/07/08 Cougar
#           0.14 1997/07/11 %includeTags が出力されていなかった
#           0.15 1997/07/26 Arena
#           0.16 1997/08/18 %tagsAttributes 復活、(%REF) がうまく展開されていない
#           0.17 1997/08/20 ATTLIST が空のときの処理
#           0.18 1997/08/21 別の特定 DTD の参照処理
#           0.19 1997/09/05 最後に 1; 出力
#           0.20 1997/10/02 Cougar 09/17
#           0.21 1998/02/03 HTML4.0 Frameset
#           0.22 1998/02/24 Mozilla 3.0/4.0
#           0.23 1998/03/07 Deprecated な要素の抽出 / 変数名変更
#           0.24 1998/03/20 %attrValues のキー区切りを / に変更
#           0.25 1998/07/07 &Doctype
#           0.26 1999/05/01 ISO15445 のための調整
#           0.27 1999/07/29 IE5 は属性名に下線を使っている
#           0.28 1999/09/11 HTML 4.01 / -i
#           0.29 1999/10/28 IE50 XMLNS:namespace
#           0.30 1999/11/01 %attrValues 廃止、%tagsAttributes に統合
#           0.31 2000/01/30 XHTML 1.0
#           0.32 2000/03/26 XHTML 1.1
#           0.33 2000/12/20 <? ... ?> 無視
#           0.34 2000/12/25 属性値をDTDどおりに出力
#           0.35 2001/01/13 (A+,B)+
#           0.36 2001/02/24 (A*|B*|C*) != (A|B|C)*
#           0.37 2001/03/13 binmode STDOUT
#           0.38 2008/02/19 HTML+ ISOlat1 ISOnum ISOdia SDATA 調整
#           0.39 2008/12/29 Undefined parameter entity を die から warn に
$VERSION = '0.39';

# Copyright (c) 1997 ISHINO Keiichiro. All rights reserved.

require 5.000;

$dump_token  = 0;  # 読んだ全トークンを出力
$dump_mark   = 0;  # 読んだマーク宣言を出力
$dump_result = 1;  # 解析結果を出力

$ignore_FIXED = 0;

$html = 'HTML';

# Token Patterns
$markDcl = '(<!(SGML|DOCTYPE|ELEMENT|ATTLIST|ENTITY|NOTATION|SHORTREF|USEMAP|\[|--)|<\?)';
$nameChr    = '[A-Za-z0-9\.\-_:]';
$nameStr    = '[A-Za-z:]'.$nameChr.'*';
$digits     = '[0-9]+';
$refParam   = '%'.$nameStr.';?';
$entToken   = '#PCDATA|RCDATA|CDATA|EMPTY|ANY';
$attToken   = '#FIXED|#REQUIRED|#CURRENT|#IMPLIED|#CONREF';
$sectStatus = 'CDATA|RCDATA|IGNORE|INCLUDE|TEMP';
$charData   = 'CDATA|NUMBER|NUMBERS|NAME|NAMES|NMTOKEN|NMTOKENS|NUTOKEN|NUTOKENS'.
              '|ENTITY|ENTITIES|ID|IDREF|IDREFS|NOTATION';
$nameSep    = '/';  # $nameChr に含まれないもの %attrValues のキー区切りでもある
{
  local(@tmp);
  foreach (split(/\|/, $charData)) { push (@tmp, $_.'\.'); }
  $refInnerParam = join('|', @tmp); # 内部的に一時使用
}

# Mark Dispacher
%dispatchDTD = (
#   '<!SGML'     => 'SkipEndOfMark',
    '<!DOCTYPE'  => 'Doctype',
    '<!ELEMENT'  => 'Element',
    '<!ATTLIST'  => 'Attlist',
    '<!ENTITY'   => 'Entity',
#   '<!NOTATION' => 'SkipEndOfMark',
#   '<!SHORTREF' => 'SkipEndOfMark',
#   '<!USEMAP'   => 'SkipEndOfMark',
    '<!\['       => 'MarkSection',
    '<!--'       => 'Comment',
    '<\?'        => 'Declaration',
);

# Included DTD
%includedDTD = (
   '-//IETF//ENTITIES Added Latin 1 for HTML//EN'    => 'ISOlat1HTML.ent',
   'ISO 8879-1986//ENTITIES Added Latin 1//EN//HTML' => 'ISOlat1HTML.ent',
   'ISO 8879-1986//ENTITIES Added Latin 1//EN'                  => 'isolat1.ent',
   'ISO 8879-1986//ENTITIES Numeric and Special Graphic//EN'    => 'isonum.ent',
   'ISO 8879-1986//ENTITIES Diacritical Marks//EN'              => 'isodia.ent',
#   'ISO 8879-1986//ENTITIES General Technical//EN'              =>
#   'ISO 8879-1986//ENTITIES Greek Symbols//EN'                  =>
#   'ISO 8879-1986//ENTITIES Added Math Symbols: Ordinary//EN'   =>
#   'ISO 8879-1986//ENTITIES Added Math Symbols: Relations//EN'  =>
#   'ISO 8879-1986//ENTITIES Added Math Symbols: Delimiters//EN' =>
   '-//W3C//ENTITIES Latin1//EN//HTML'               => 'HTMLlat1.ent',
   '-//W3C//ENTITIES Full Latin 1//EN//HTML'         => 'HTMLlat1.ent',
   '-//W3C//ENTITIES Symbols//EN//HTML'              => 'HTMLsymbol.ent',
   '-//W3C//ENTITIES Symbolic//EN//HTML'             => 'HTMLsymbol.ent',
   '-//W3C//ENTITIES Special//EN//HTML'              => 'HTMLspecial.ent',
   '-//W3C//DTD HTML 4.0 Transitional//EN'           => 'html40-loose.dtd',
   '-//W3C//DTD HTML 4.01 Transitional//EN'          => 'html401-loose.dtd',
   '-//W3C//ENTITIES Latin 1 for XHTML//EN'          => 'xhtml-lat1.ent',
   '-//W3C//ENTITIES Symbols for XHTML//EN'          => 'xhtml-symbol.ent',
   '-//W3C//ENTITIES Special for XHTML//EN'          => 'xhtml-special.ent',
);

# SDATA entity [xxx]
%sdataEntities = (
  'ndash'  => '&#8211;',
  'mdash'  => '&#8212;',
  'ensp'   => '&#8194;',
  'emsp'   => '&#8195;',
  'hellip' => '&#8230;',
  'vellip' => '&#8942;',
  'thinsp' => '&#8201;',
  'coprod' => '&#8720;',
  'prod'   => '&#8719;',
  'sum'    => '&#8721;',
);

##################################################
# メインループ

if ($ARGV[0] eq '-i') {
  shift;
  $ignore_DEPRECATED = 1; # 強制的に Deprecated = IGNORE とする
}
if ($ARGV[0] ne '-d') {
  # DTD から規則ファイルを作る
  print "usage: parsedtd.pl [-i] dtdfile>rulefile\n",
        "       parsedtd.pl -d include.rul ignore.rul\n" unless @ARGV;
  while (@ARGV > 0) {
    local($file) = shift(@ARGV);
    if ($file eq '-') {
      *DTD = *STDIN;
      &GetDTD;
    } else {
      &ReadDTD($file, 1);
    }
  }
} else {
  # 規則ファイルから Deprecated な要素を抽出する
  shift;
  $loose  = shift;
  $strict = shift;
  if ($strict eq '') {
    print "usage: deprecated.pl loose.rul strict.rul\n";
    exit(0);
  }
  do $strict;
  &ExpandInternalElementsAll;
  $strictTags = join('|', $emptyTags, $pairTags);
  %strictElements = %tagsElements;
  %strictAttributes = %tagsAttributes;
# %strictValues = %attrValues;
  do $loose;
  &ExpandInternalElementsAll;

  $deprecatedTags = '';
  foreach (sort(split(/\|/, $emptyTags), split(/\|/, $pairTags))) {
    unless (/^($strictTags)$/) {
      $deprecatedTags = Join('|', $deprecatedTags, $_);
    }
  }
  &EchoValue('deprecatedTags', $deprecatedTags);

  %deprecatedElems = ();
  foreach $key (sort keys %tagsElements) {
    next if $key =~ /^($deprecatedTags)$/o;
    foreach (sort split(/\|/, $tagsElements{$key})) {
      next if /^($deprecatedTags|CDATA|RCDATA)$/o;
      $deprecatedElems{$key} = Join('|', $deprecatedElems{$key}, $_)
                                      unless /^($strictElements{$key})$/;
    }
  }
  &EchoArray('deprecatedElems', \%deprecatedElems);

  %deprecatedAttrs = ();
  foreach $key (sort keys %tagsAttributes) {
    next if $key =~ /^($deprecatedTags)$/o;
    foreach (sort keys %{$tagsAttributes{$key}}) {
      $deprecatedAttrs{$key} = Join('|', $deprecatedAttrs{$key}, $_)
                                      unless $strictAttributes{$key}->{$_};
    }
  }
  &EchoArray('deprecatedAttrs', \%deprecatedAttrs);

  %deprecatedVals = ();
  foreach $key (sort keys %tagsAttributes) {
    next if $key =~ /^($deprecatedTags)$/o;
    foreach $attr (keys %{$tagsAttributes{$key}}) {
      next if $attr =~ /^($deprecatedAttrs{$key})$/;
      my $val = $tagsAttributes{$key}->{$attr};
      next if $val =~ /^%/o;
      my $strict = $strictAttributes{$key}->{$attr};
      foreach (sort split(/\|/, $val)) {
        $deprecatedVals{$key}->{$attr} = Join('|', $deprecatedVals{$key}->{$attr}, $_)
                                                                 unless /^($strict)$/;
      }
    }
  }
  &EchoArrayArray('deprecatedVals', \%deprecatedVals);
}
exit(0);

##################################################
# DTD を読む。

sub ReadDTD
{
  local($file, $die) = @_;
  if ($file ne '') {
    local(*DTD);
    my $ln = $.+0;
    warn "$ln: Open '$file'\n";
    if (open(DTD, "<$file")) {
      &GetDTD;
      close DTD;
      warn "$ln: Close '$file'\n";
    } elsif ($die) {
      die qq|Can't open "$file".\n|;
    } else {
#     warn qq|Can't open "$file".\n|;
      print qq|# Can't open "$file".\n|;
    }
  }
}

sub GetDTD
{
  $enterDTD++;
  TOKEN:
  while (&GetToken(-1)) {
    foreach $mark (keys(%dispatchDTD)) {
      if ($token =~ /^$mark$/) {
        die $@ unless eval('&'.$dispatchDTD{$mark});
        next TOKEN;
      }
    }
    if ($token =~ /^$refParam$/o) {
      my $ref = &ExtendRefParam($token);
      my $inc = $includedDTD{$ref};
      &ReadDTD($inc? $inc: $ref);
      next TOKEN;
    }
    warn "$.: Unsupported mark declaration '$token'\n";
    &SkipEndOfMark;
  }
  $enterDTD--;
  &EchoResults if $dump_result && !$enterDTD;
}

##################################################
# 結果の出力

sub EchoResults
{
  binmode STDOUT;
  print "#======= ELEMENTS =======\n";
  {
    local(@empty, @pair, @ostart, @oend, @cdata);
    local(%onceonly, %required);
    local(%exclude, %include);
    local(@model0, %model1, @model2, %modelx);
    foreach $name (sort(keys(%elements))) {
      local($value) = $elements{$name};
      if (substr($value, 2) eq 'EMPTY' && substr($value, 1, 1) eq 'O') {
        push(@empty, $name);
        next;
      }
      push(@pair,   $name) unless $name =~ /^#$digits$/o;
      push(@ostart, $name) if substr($value, 0, 1) eq 'O';
      push(@oend,   $name) if substr($value, 1, 1) eq 'O';
      $value = substr($value, 2);
      while ($value =~ /\s+(\-|\+)\((($nameChr|#|\|)+)\)/o) {
        $exclude{$name} = $2 if $1 eq '-';
        $include{$name} = $2 if $1 eq '+';
        $value = $`.$';
      }
      if ($value =~ /^\((($nameChr|#|\|)+)\)(\*|\+)$/o) {
        $model1{$name} = $1;
        push(@model0, $name) if $3 eq '*'&& $name !~ /^#$digits$/o;
      } elsif ($value =~ /^($refInnerParam)/o) {
        $model1{$name} = '%'.$';
        push(@model0, $name) if $value =~ /^R?CDATA/o;
      } elsif ($value =~ /^(R?CDATA|ANY)$/o) {
        $model1{$name} = $value;
        push(@model0, $name);
      } elsif ($value eq 'EMPTY') {
        push(@model0, $name);
      } else {
        $modelx{$name} = $value;
      }
    }
    foreach $name (keys(%modelx)) {
      local($value) = $modelx{$name};
      if ($value =~ /^\(([^\(\)]+)\)\*?$/o) {
        $value = $1;
        local($sep) = ($value =~ /(,|&|\|)/o)? $1: '&';
        $sep = '\|' if $sep eq '|';
        local(@tags) = split(/$sep/, $value);
        local($tag, $tname);
        local(@once, @twice, @req, @nseq, @seq, @val);
        foreach $tag (@tags) {
          if ($tag =~ /^(#?$nameChr+)(\?|\+|\*)?$/o) {
            $tname = $1;
            my $post = $2;
            if ($tname ne '#PCDATA' && (!$post || $post eq '?')) {
#             foreach (@once) {
#               if ($_ eq $tname) {
#                 push(@twice, $_);
#                 last;
#               }
#             }
              push(@once, $tname);
            }
            if ($tname ne '#PCDATA' && $sep ne '\|' && (!$post || $post eq '+')) {
              push(@req,  $tname);
            }
            push(@nseq, $tname) if $sep eq '&';
            push(@seq,  $tname) if $sep eq ',';
            push(@val,  $tname);
            delete $modelx{$name};
          }
        }
#       if (@twice) {
#         my $twice = &Ujoin(@twice);
#         my @tmp;
#         foreach (@once) {
#           push(@tmp, $_) unless /^($twice)$/;
#         }
#         @once = @tmp;
#       }
        $onceonly{$name} = &Join('|', @once) if @once;
        $required{$name} = &Ujoin(@req) if @req;
        if ($sep eq '&') {
          $model1{$name} = &Ujoin(@nseq) if @nseq;
        } elsif ($sep eq ',') {
          $model1{$name} = &Join('|', @seq) if @seq;
          push(@model2, $name);
        } else {
          $model1{$name} = &Ujoin(@val) if @val;
        }
      }
    }
    foreach $name (keys(%exclude)) {
      if ($model1{$name}) {
        local(%tmp);
        grep($tmp{$_}++, split(/\|/, $exclude{$name}));
        $model1{$name} =
          join('|', grep(!$tmp{$_}, split(/\|/, $model1{$name})));
#       delete $exclude{$name};
      }
    }
    foreach (keys(%include)) {
      if ($model1{$_}) {
        $model1{$_} .= '|'.$include{$_} if $include{$_} !~ /^($model1{$_})$/;
      } else {
        $model1{$_} = $include{$_};
      }
    }
    foreach $tag (@pair, @empty) {
      my $ok = 0;
      foreach (keys(%model1)) {
        if ($tag =~ /^($model1{$_})$/i) {
          $ok = 1;
          last;
        }
      }
      if (!$ok && $tag ne $html) {
        warn "warning: Unrefered element '$tag'\n";
#       undef($attributes{$tag});
        push(@unref, $tag);
      }
    }
    $unrefs = &Ujoin(@unref);
    # よくわからなかった要素モデルのタグ
    if (scalar keys %modelx) {
      foreach (keys %modelx) { warn "warning: Unknown style element '$_'\n"; }
      &EchoArray('unknownStyleElements', \%modelx);
    }
    # 終了タグのない空タグ
    &EchoValue('emptyTags', &Xjoin(@empty));
    # 組みタグ
    &EchoValue('pairTags', &Xjoin(@pair));
    # 薦められないタグ
    &EchoValue('deprecatedTags', &Xjoin(@deprecate));
    # 開始タグ省略可
    &EchoValue('omitStartTags', &Xjoin(@ostart));
    # 終了タグ省略可
    &EchoValue('omitEndTags', &Xjoin(@oend));
    # 要素が空でもよいタグ
    &EchoValue('maybeEmpty', &Xjoin(@model0));
    # 要素中に現われなければならないタグ
    &EchoArray('requiredTags', \%required);
    # 要素中に１度だけ現われてよいタグ
    &EchoArray('onceonlyTags', \%onceonly);
    # 要素に順序どおりに書くタグ
    &EchoValue('sequencialTags', &Xjoin(@model2));
    # 要素に書けるタグ
    &EchoArray('tagsElements', \%model1);
    # 排除タグ要素
    &EchoArray('excludedElems', \%exclude);
    # 追加タグ要素
    &EchoArray('includedElems', \%include);
  }
  print "#======= ATTRIBUTES =======\n";
  {
    local(%attrs, %avalues, %required);
    foreach $name (sort(keys(%attributes))) {
      local($value) = $attributes{$name};
      while ($value =~ m#^([^/]+)/([^/]+)/([^/]*)/?#o) {
        local($att, $val, $def) = ($1, $2, $3);
        $value = $';
        my $fixed = '';
        if ($def eq '#FIXED') {
          $value =~ m#^"([^"]*)"/?#o;
          $fixed = $1;
#         $fixed = uc($fixed) if $fixed =~ /^($val)$/i;
          $value = $';
          next if $ignore_FIXED;
          next if $att =~ /^(SDAFORM|SDARULE|SDAPREF|SDASUFF|SDASUSP)$/i;
        } elsif ($def eq '#REQUIRED') {
          $required{$name} = &Join('&', $required{$name}, $att);
        }
        $attrs{$name} = &Join('|', $attrs{$name}, $att);
        $val = '%'.$' if $val =~ /^($refInnerParam)/o;
        $val = $1 if $val =~ /\(([^\(\)]+)\)$/o;
        $val .= "=$fixed" if $fixed ne '';
#       $avalues{$name.$nameSep.$att} = $val;
        $avalues{$name}{$att} = $val;
      }
    }
    # 属性一覧
#   &EchoArray('tagsAttributes', \%attrs);
    &EchoArrayArray('tagsAttributes', \%avalues);
    # 必須属性
    &EchoArray('requiredAttrs', \%required);
  }
  print "#======= ENTITIES =======\n";
  # 実体参照
  &EchoArray('refEntities', \%generalEntities);
  # パラメタ参照
  &EchoArray('refParams', \%parameters);

  print "\n1;\n";
}

sub EchoArrayArray
{
  my ($name, $array) = @_;
  print "\%$name = (\n";
  foreach $aname (sort keys %$array) {
    my $maxlen;
    foreach (keys %{$$array{$aname}}) {
      $maxlen = length($_) if $maxlen < length($_);
    }
    print("  '$aname' => {\n");
    foreach (sort keys %{$$array{$aname}}) {
      &EchoValue($_, $$array{$aname}->{$_}, $maxlen, 4);
    }
    print("  },\n");
  }
  print ");\n";
}

sub EchoArray
{
  local($name, $array) = @_;
  local($maxlen);
  foreach $aname (keys(%$array)) {
#   $aname =~ s/:XMLNS:/[^:]+:.+/og;
#   $aname = '[^:]+:.+' if $aname eq ':XMLNS:';
    $maxlen = length($aname) if $maxlen < length($aname);
  }
  print "\%$name = (\n";
  foreach $aname (sort(keys(%$array))) {
    &EchoValue($aname, $$array{$aname}, $maxlen);
  }
  print ");\n";
}

sub EchoValue
{
  local($name, $value, $offset, $offset2) = @_;
# $name  =~ s/:XMLNS:/[^:]+:.+/og;
# $name = '[^:]+:.+' if $name eq ':XMLNS:';
  $value =~ s/:XMLNS:/[^:]+:.+/og;
  local($term, $sep);
  if ($offset) {
    $offset -= length($name);
    $offset2 = 2 unless $offset2;
    $name = sprintf("%${offset2}s'%s'%${offset}s => ", '', $name, '');
    $term = ',';
  } else {
    $name = '$'.$name.' = ';
    $term = ';';
  }
  $sep = ($value =~ /&/o)? '&': '|';
  $offset = length($name);
  while (length($value) > 76-$offset) {
    local($splitline) = rindex($value, $sep, 76-$offset);
    last if $splitline == -1;
    print $name, "'", substr($value, 0, $splitline), "'.\n";
    $name =~ s/\S/ /og;
    $value = substr($value, $splitline);
  }
  print $name, "'$value'$term\n";
}

##################################################
# <!ENTITY [%] ent-name [type] "content">
# <!ENTITY [%] ent-name PUBLIC "content" SYSTEM "file">
# 多重定義しているときは後ろが無視される。

sub Entity
{
  local($param, $ename, $type, $content, $end);
  $ename = &GetToken(0);
  if ($param = ($ename eq '%')) {
    # parameter entity
    $ename = &GetToken(0);
  }
  die "$.: Illegal entity name $ename\n"
    unless $ename =~ /^($nameStr)/o;
  if (&SkipComment !~ /^("|')/o) {
    $type = &GetToken(0);
    die "$.: Illegal parameter entity content $content\n"
      if &SkipComment !~ /^("|')/o;
  }
  $content = &GetToken(0);
  if (!$param && $ename eq 'nontab') {
    # きたないやり方
    $content = ' ';
    print stderr "$ename == '$content'\n";
  }
  if ($param) {
    if (defined($paramEntities{$ename})) {
      warn "$.: Already defined parameter entity '$ename'\n";
    } else {
      $paramEntities{$ename} = $content;
      print "$./%ENTITY/$ename/$paramEntities{$ename}\n" if $dump_mark;
      if ($type eq 'PUBLIC' && $content =~ m#^-//W3C//#) {
        my $file = &GetToken(0);
        if ($file ne '' && $file ne '>') {
          $file = &GetToken(0) if $file eq 'SYSTEM';
          unless ($file =~ m#/#) {
            $paramFile{$ename} = $file;
          } elsif ($file =~ m#^http://.*/([^/]+)$#) {
            $paramFile{$ename} = $1;
          }
        } else {
          &UnGetToken;
        }
      }
    }
    do { $end = &GetToken(0); } while $end ne '>';
  } else {
    if ($type eq '' || $type eq 'CDATA') {
    } elsif ($type eq 'STARTTAG') {
      $content = '<'.$content.'>' unless $content =~ /^<.+>$/o;
    } elsif ($type eq 'ENDTAG') {
      $content = '</'.$content.'>' unless $content =~ /^<\/.+>$/o;
    } elsif ($type eq 'PUBLIC') {
      $content = &GetToken(0); # 暫定
    } elsif ($type eq 'SDATA') {
      if ($content =~ /^\[(\S+)\s*\]$/) {
        $content = $sdataEntities{$1} if $sdataEntities{$1};
      }
    } else {
      warn "$.: Unknown entity type '$type'\n";
      $content = '';
    }
    if ($content ne '') {
      if (defined($generalEntities{$ename})) {
        warn "$.: Already defined general entity '$ename'\n";
      } else {
        if ($content =~ /^&#x(.+);$/) {
          $content = '&#'.hex($1).';';
        }
        $generalEntities{$ename} = $content;
        print "$./ENTITY/$ename/$generalEntities{$ename}\n" if $dump_mark;
      }
    }
    $end = &GetToken(0);
  }
  die "$.: Illegal entity declaration\n" if $end ne '>';
  1;
}

#########################################################
# <!ELEMENT elem-name omit-start omit-end entity-model>

sub Element
{
  local($ename, $start, $end, $entity);
  $ename = &GetToken(1);
  die "$.: Illegal element name: $ename\n"
    unless $ename =~ /^($nameStr|\(.+)$/o;
  &SkipComment;
  if ($line =~ /^[-O]/) {
    $start = &GetToken(0);
    die "$.: Illegal start omitting\n"
      unless $start =~ /^[-O]$/o;
    $end = &GetToken(0);
    die "$.: Illegal end omitting\n"
      unless $end =~ /^[-O]$/o;
  } else {
    $start = $end = '-';
  }
  $entity = &GetToken(2);
  die "$.: Illegal entity model: $entity\n"
    unless $entity =~ /^($entToken|($refInnerParam)$nameStr|\(.+)$/o;
  if ($entity =~ /^\(/o) {
    &ElementGroup($entity);
    while (&GetToken(0) =~ /^(\-|\+)$/o) {
      local($addsub) = $1;
      die "$.:Illegal group subscription\n" unless &GetLine =~ /^\(/o;
      $line = $';
      $entity .= ' '.$addsub.&GetGroup(1);
      if ($line =~ /^\*/) { $line = $'; }
    }
    &UnGetToken;
  }
  die "$.: Illegal element declaration\n" unless &GetToken(0) eq '>';
  $ename  =~ s/[\(\)]//og;
  $ename  =~ tr/[a-z]/[A-Z]/;
  $entity =~ tr/[a-z]/[A-Z]/ unless $entity =~ /^($refInnerParam)/o;
  foreach (split(/[\|,]/, $ename)) {
    die "$.: Already defined element '$_'\n" if defined($elements{$_});
    $elements{$_} = $start.$end.$entity;
    push(@deprecate, $_) if $deprecated;
  }
  print "$./ELEMENT/$ename/$start/$end/$entity\n" if $dump_mark;
  1;
}

sub ElementGroup
{
  ($entity) = @_;
  # (#PCDATA) --> (#PCDATA)*
  $entity =~ s/^\(#PCDATA\)$/$&\*/o;
  # (OPTION+) --> (OPTION)+
  $entity =~ s/^\((#?$nameChr+)(\+|\*)\)$/\($1\)$2/o;
  # ((...)*) --> (...)*
  $entity = $1 if $entity =~ /\((\([^\(\)]+\)[\?\*\+]?)\)/o;
  # (A|(B|C)|D)* --> (A|B|C|D)*
  substr($entity, 1, length($1)) =~ s/[\(\)]//og
    if $entity =~ /^\(([^&,\?\*\+]+)\)[\?\*\+]?$/o;
  # (A+,B)+ --> (A|B)+   -- 暫定 (HTML+)
  if ($entity =~ /^\((.+)\+,(.+)\)\+$/o) {
    $entity = "($1|$2)+";
  }
  # (A|(B|C)*|D)* --> (A|B|C|D)*
  if ($entity =~ /^\((.+)\)\*$/o) {
    $entity = $1;
    if ($entity =~ /\((.+)\)(\*|\+)/) {
      substr($entity, length($`), length($&)) = $1;
    }
    $entity = '('.$entity.')*';
  }
  # (...|A*|...)* --> (...|A|...)*
  if ($entity =~ /^\((.+)\)(\*|\+)$/o) {
    local(@tags) = split(/\|/, $1);
    local($rep) = "\\$2";
    local(@tmp, $tag);
    while ($tag = pop(@tags)) {
      last unless $tag =~ /^(#?$nameChr+)$rep?$/o;
      push(@tmp, $1);
    }
    $entity = '('.&Ujoin(@tmp).')'.substr($rep, 1) unless $tag;
  }
  # (A*|B*|C*) --> (A|B|C)*  間違いだが都合でこのように展開しておく
  if ($entity =~ /^\(([^\(,&\)]+)\)$/o) {
    local(@tags) = split(/\|/, $1);
    local(@tmp, $tag, $rep);
    if (pop(@tags) =~ /^(#?$nameChr+)(\*|\+)$/o) {
      push(@tmp, $1);
      $rep = "\\$2";
      while ($tag = pop(@tags)) {
        last unless $tag =~ /^(#?$nameChr+)$rep$/;
        push(@tmp, $1);
      }
      $entity = '('.&Ujoin(@tmp).')'.substr($rep, 1) unless $tag;
    }
  }
  # (A,(B),C) --> (A,#N,C)
  if ($entity =~ /^\(([^\(]*\(.+\)[^\)]*)\)$/o) {
    $entity = &ElementNestGroup($1);
  }
  $entity;
}

sub ElementNestGroup
{
  ($entity) = @_;
  local($ent, $ref);
  while ($entity) {
    if ($entity =~ /^[^\(\)]+/o) {
      $ent .= $&;
      $entity = $';
    }
    if ($entity =~ /^\(/o) {
      local($eg) = '--'.uc(&ElementNestGroup($'));
      $ref = '';
      foreach (keys(%elements)) {
        if (/^#\d\d\d$/o && $elements{$_} eq $eg) {
          $ref = $_;
          last;
        }
      }
      if ($ref eq '') {
        $ref = sprintf("#%03d", $refGroup++);
        $elements{$ref} = $eg;
      }
      $ent .= $ref;
    }
    if ($entity =~ /^\)[\+\*\?]?/o) {
      $ent = &ElementGroup('('.$ent.$&);
      $entity = $';
      if ($ent =~ /[\+\*\?]$/o) {           # 0.13
        $ent = $`.'*';
        $entity = $&.$entity;
      }
      return $ent;
    }
  }
  &ElementGroup('('.$ent.')');
}

###################################################
# <!ATTLIST elem-name attr-name values default
#                     attr-name values default...>

sub Attlist
{
  local($ename, $aname, $values, $default, @attrs);
  $ename = &GetToken(1);
  die "$.: Illegal element name: $ename\n"
    unless $ename =~ /^($nameStr|\(.+)$/o;
  print "$./ATTRIBUTE/$ename" if $dump_mark;
  for (;;) {
    last if &GetToken(0) eq '>';
    &UnGetToken;
    $aname = &GetToken(1);
    die "$.: Illegal attribute name: $aname\n"
      unless $aname =~ /^($nameStr|\()$/o;
    $aname =~ tr/[a-z]/[A-Z]/;
    push(@attrs, $aname);
    $values = &GetToken(1);
    die "$.: Illegal attribute values: $values\n"
      unless $aname =~ /^($digits|$nameStr|\()$/o;
    if ($values !~ /^($refInnerParam)/o) {
      die "$.: Illegal character data type: $values\n"
        unless $values =~ /^\(/o || $values =~ /^($charData)$/o;
#     $values  =~ tr/[a-z]/[A-Z]/;
    }
    if ($values eq 'NOTATION') {
      warn "$.: Unsupported attribute style '$values'\n";
      &GetToken(1);
      $values = 'CDATA';
    }
    $values =~ s/^\(($nameStr)\)$/$1/o;
    push(@attrs, $values);
    ($default = &GetToken(0)) =~ s#/##og;
    die "$.: Illegal default attribute: $aname\n"
      unless $aname =~ /^($digits|$nameStr|$attAToken)$/o;
#   $default =~ tr/[a-z]/[A-Z]/;
    push(@attrs, $default);
    print "/$aname/$values/$default" if $dump_mark;
    warn "$.: Unsuppoertd default attribute '$aname'\n"
      unless $aname =~ /^([^#]+|#FIXED|#REQUIRED|#IMPLIED)$/o;
    if ($default eq '#FIXED') {
      die "$.: No fixed value\n" unless &SkipComment =~ /^("|')/o;
      &GetToken(0);
      print "/$token" if $dump_mark;
      push(@attrs, '"'.$token.'"') unless $ignore_FIXED;
    }
  }
  print "\n" if $dump_mark;
  $ename =~ s/(\(|\))//og;
  foreach (split(/\|/, uc($ename))) {
    if (defined($attributes{$_})) {
#     die "$.: Already defined attlist '$_'\n";
      $attributes{$_} = join('/', $attributes{$_}, @attrs);
    } else {
      $attributes{$_} = join('/', @attrs);
    }
  }
  1;
}

##################################################
# <!DOCTYPE HTML [ declaration ]>

sub Doctype
{
  $html = uc(&GetToken(0));
  &GetLine;
  if ($line =~ /^\[/o) {
    $line = $';
    &GetDTD;
    &GetLine;
    die "$.: Unterminated DOCTYPE\n" unless $line =~ /^\]>/o;
    $line = $';
  } else {
    &SkipEndOfMark;
  }
}

##################################################
# <![ status [ doc-part ]]>

sub MarkSection
{
  local($stat, $doc, $nest);
  local($deprecated) = (&SkipComment =~ /^%HTML\.Deprecated/oi);
  $stat = &GetToken(0);
  $stat = 'IGNORE' if $deprecated && $ignore_DEPRECATED;
  die "$.: Illegal section status $stat\n" unless $stat =~ /^($sectStatus)$/o;
  die "$.: Illegal section declaration $token\n" if &GetToken(0) ne '[';
  $nest = 1;
  while (&GetLine) {
    if ($line =~ /(\[|\])/o) {
      if ($1 eq '[') {
        $nest++;
      } elsif ($1 eq ']') {
        if (!--$nest) {
          $doc .= $`;
          $line = $';
          last;
        }
      }
      $doc .= $`.$&;
      $line = $';
    } else {
      $doc .= $line;
      $line = '';
    }
  }
  die "$.: Unterminated section declaration\n"
    if $nest || &GetToken(0) ne ']' || &GetToken(0) ne '>';
  if ($stat eq 'INCLUDE') {
    # とりあえず INCLUDE だけ処理する
    # しかもこれが %HTML.Deprecated ならば、特殊なマークで囲んでおく
    # GetToken はこれを見て何か処理する
    # 実際に何かされるのは !ELEMENT のみであるから、
    # !ELEMENT が直接現れないマークは処理されない
    $line = ($deprecated? '{{'.$doc.'}}': $doc).$line;
  }
  1;
}

##################################################
# <!-- ... -->

sub Comment
{
  local($ln) = $.;
  while (&GetLine) {
    if ($line =~ /----/o) {
      # HTML3.0 DTD にはこのような記述があるので、とりあえず無視してみる
      $line = $';
      next;
    }
    if ($line =~ /--/o) {
      $line = $';
      last unless $line =~ /^>/o;
      $line = $';
      return 1;
    }
    $line = '';
  }
  die "$ln: Unterminated comment declaration <!--\n";
}

##################################################
# <? ... ?>

sub Declaration
{
  local($ln) = $.;
  while (&GetLine) {
    if ($line =~ /\?>/o) {
      $line = $';
      return 1;
    }
    $line = '';
  }
  die "$ln: Unterminated declaration <?\n";
}

##################################################
# マーク宣言末まで読み飛ばす。

sub SkipEndOfMark
{
  local($ln) = $.;
  local($nest) = 0;
  while (&SkipComment) {
    if ($line =~ />/o) {
      $line = $';
      last if $nest-- == 0;
    } elsif ($line =~ /</o) {
      $line = $';
      $nest++;
    } else {
      $line = '';
    }
  }
  1;
}

##################################################
# パラメータ参照を展開する。

sub ExtendRefParam
{
  local($param) = @_;
  $param =~ /$nameStr/o; # % と ; を除く
  local($name) = $&;
  $param = ($paramFile{$name} or $paramEntities{$name}); # 空文字列かも知れない
  warn "$.: Undefined parameter entity \%$name\n" unless defined($param);
  if ($param =~ /^($charData)$/o) {
    # CDATA や NUMBER のときは実体参照を残す
    $parameters{$name} = $param;
    $param .= '.'.$name; # 接続の '.' には注意
  }
  $param;
}

##################################################
# 括弧で囲まれた群を読んで $token に追加する。
#   &GetGroup(1) | のみの群を読む
#   &GetGroup(2) フルスペックの群を読む

sub GetGroup
{
  local($ln) = $.;
  local($connect, $repeat);
  local($type) = @_; # $type = 1 or 2
  if ($type == 2) {
    $connect = '\||&|,';
    $repeat  = '\?|\*|\+';
  } else {
    $connect = '\||,'; # ',' for ISO15445
  }
  local($token) = '(';
  while (&GetLine) {
    if ($line =~ /^($refParam)/o) {
      local($rest) = $';
      $line = &ExtendRefParam($1).' '.$rest;
      next;
    }
    if ($line =~ /^\(/o) {
      $line = $';
      $token .= &GetGroup($type);
    } elsif ($line =~ /^($digits|#?$nameStr)/io) {
      $line = $';
      $token .= $1;
    } else {
      die "$.: Illegal group element: $line";
    }
    if ($repeat && $line =~ /^($repeat)/) {
      $line = $';
      $token .= $1;
    }
    last unless &GetLine;
    if ($line =~ /^\)/o) {
      $token .= ')';
      $line = $';
      # 繰り返し指示子の直前には空白がないと仮定
      # これは、次に現れるかも知れない加算演算子と区別するため
      if ($repeat && $line =~ /^($repeat)/) {
        $line = $';
        $token .= $1;
      }
      return $token;
    }
    if ($line !~ /^($connect)/) {
      die "$.: Illegal grouping operator: $line";
    }
    $line = $';
    $token .= $1;
  }
  die "$ln: Unterminated group\n";
}

##################################################
# 文字列を読んでその中身だけを返す。

sub GetString
{
  local($ln) = $.;
  local($quot) = @_; # $quot = " or '
  local($token) = '';
  while (&GetLine) {
    if ($line =~ /$quot/) {
      $line = $';
      $token .= $`;
      $token =~ s/\s/ /og;
      local($str) = '';
      while ($token =~ /($refParam)/o) {
        # 再帰的な展開はしない
        $str .= $`;
        $token = &ExtendRefParam($1).$';
      }
      return $str.$token;
    }
    $token .= $line;
    $line = '';
  }
  die "$ln: Unterminated string\n";
}

##################################################
# DTD トークンを $token に得る。
# $token が返る。EOF のときは空文字列。
#   &GetToken(0)  (...)群を解釈しない
#   &GetToken(1)  (..|..) のみの群を解釈する
#   &GetToken(2)  繰り返しを含む排除以外の群を解釈する
#   &GetToken(-1) DTDトップレベル用

sub GetToken
{
  local($type) = @_;
  $token = '';
  LINE:
  while (&SkipComment) {
    if ($line =~ /^{{/o) {
      $line = $';
      $deprecated++;
      next LINE;
    }
    if ($line =~ /^}}/o) {
      $line = $';
      $deprecated--;
      next LINE;
    }
    if ($type == -1) {
      if ($line =~ /^($markDcl|$refParam)/io) {
        $token = $1;
        $line = $';
      } elsif ($enterDTD == 1) {
        die "$.: Illegal line(1): $line";
      } else {
        $token = '';
      }
    } else {
      if ($line =~ /^($refParam)/o) {
        $line = &ExtendRefParam($1).' '.$';
        next LINE;
      }
      if ($line =~ /^($digits|#?$nameStr|\[|\]|%|\+|-|O|>)/o) {
        $line = $';
        $token = $1;
      } elsif ($line =~ /^("|')/o) {
        $line = $';
        $token = &GetString($1);
      } elsif ($type && ($line =~ /^\(/o)) {
        $line = $';
        $token = &GetGroup($type);
      } else {
        die "$.: Illegal line(2): $line";
      }
    }
    last;
  }
  print "$.:TKN> '$token'\n" if $dump_token;# && $token;
  $token;
}

##################################################
# $token を $line に戻す。

sub UnGetToken
{
  $line = $token.' '.$line;
}

##################################################
# コメントを読み飛ばす。$line を返す。

sub SkipComment
{
  LINE:
  while (&GetLine =~ /^--/o) {
    local($ln) = $.;
    $line = $';
    while (&GetLine) {
      if ($line =~ /--/o) {
        $line = $';
        next LINE;
      }
      $line = '';
    }
    die "$ln: Unterminated comment\n";
  }
  $line;
}

##################################################
# 行を $line に読む。EOF なら空文字列が返る。

sub GetLine
{
  for (;;) {
    # 先行空白を捨てる
    $line =~ s/^\s+//o;
    last if $line ne '';
    $line = <DTD>;
    last if $line eq '' && eof;
  }
  $line;
}

##################################################
# 文字列を連結する。
# join() では空文字列も連結してしまうがこれは空文字列は捨てる。

sub Join
{
  my $sep = shift;
  my $str;
  foreach (@_) {
    $str = $str? $str.$sep.$_: $_ if $_;
  }
  $str;
}

sub Ujoin
{
  my $str;
  foreach (@_) {
    $str = $str? $str.'|'.$_: $_ unless $_ =~ /^($str)$/;
  }
  $str;
}

sub Xjoin
{
  my $str;
  foreach (@_) {
    next if /^($unrefs)$/;
    $str = $str? $str.'|'.$_: $_ unless $_ =~ /^($str)$/;
  }
  $str;
}

##################################################
# #NNN 形式の内部要素を展開する

sub ExpandInternalElement
{
  my $elem = shift;
  ($elem =~ /^#\d+$/o)? &ExpandInternalElements($tagsElements{$elem}): $elem;
}

sub ExpandInternalElements
{
  my $elem = shift;
  my $ext = '';
  while ($elem =~ /#\d+/o) {
    $elem = $';
    my $precede = $`;
    $ext .= $precede.&ExpandInternalElement($&);
  }
  $ext.$elem;
}

sub ExpandInternalElementsAll
{
  foreach (keys %tagsElements) {
    next if /^#/o;
    $tagsElements{$_} = &ExpandInternalElements($tagsElements{$_});
  }
  foreach (keys %tagsElements) {
    delete $tagsElements{$_} if /^#/o;
  }
}
