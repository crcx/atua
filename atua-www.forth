#!/home/crc/retro12/bin/rre
drop
'/home/crc/atua s:keep 'PATH const
'/gophermap     s:keep 'DEFAULT-INDEX const
#1024  'MAX-SELECTOR-LENGTH const
#65535 #4 * 'MAX-FILE-SIZE const
:eol  (-)  ASCII:CR putc ASCII:LF putc ;
:getc (-c) `1001 ;
:eol? (c-f)
  [ ASCII:CR eq? ] [ ASCII:LF eq? ] [ ASCII:SPACE eq? ] tri or or ;
:gets (a-)
  buffer:set
  [ getc dup buffer:add eol? not ] while ;
#0 'file:R const
#1 'file:W const
#2 'file:A const
#3 'file:M const
:file:open  (sm-h) `118 ;
:file:close (h-)   `119 ;
:file:read  (h-c)  `120 ;
:file:write (ch-f) `121 ;
:file:tell  (ch-f) `122 ;
:file:size  (h-n)  `124 ;
:file:exists?  (s-f)
  file:R file:open dup n:-zero?
  [ file:close TRUE ]
  [ drop FALSE ] choose ;
:html:tt  (q-)  '<tt> puts call '</tt> puts ;
:html:br  (-)   '<br> puts ;
{{
'Selector d:create
  MAX-SELECTOR-LENGTH n:inc allot
:buffer here ;
'Requested-File var
'Requested-Index var
'FID var
'Size var
'Mode var
'Server-Info var
:requested-file  (-s)  @Requested-File  ;
:requested-index (-s)  @Requested-Index ;
:with-path (-s)
  PATH &Selector s:chop s:append ;
:construct-filenames (-)
  with-path s:keep !Requested-File
  with-path '/gophermap s:append s:keep !Requested-Index
;
'Tab var
:eol? [ ASCII:LF eq? ] [ ASCII:CR eq? ] bi or ;
:tab? @Tab ;
:check-tab
  dup ASCII:HT eq? [ &Tab v:on ] if ;
:gopher:gets (a-)
  &Tab v:off
  buffer:set
  [ @FID file:read dup buffer:add check-tab eol? not ] while
  buffer:get drop
;
---reveal---
:gopher:i (s-)
  [ puts ] html:tt html:br eol ;
:gopher:icon
  $0 [ '&nbsp;TXT&nbsp;&nbsp; puts ] case
  $1 [ '[DIR]_ puts ] case
  $2 [ '&nbsp;CSO&nbsp;&nbsp; puts ] case
  $3 [ '&nbsp;ERR&nbsp;&nbsp; puts ] case
  $4 [ '&nbsp;BIN&nbsp;&nbsp; puts ] case
  $5 [ '&nbsp;BIN&nbsp;&nbsp; puts ] case
  $6 [ '&nbsp;UUE&nbsp;&nbsp; puts ] case
  $7 [ '&nbsp;???&nbsp;&nbsp; puts ] case
  $8 [ '&nbsp;TEL&nbsp;&nbsp; puts ] case
  $9 [ '&nbsp;BIN&nbsp;&nbsp; puts ] case
  $I [ '&nbsp;IMG&nbsp;&nbsp; puts ] case
  $S [ '&nbsp;AUD&nbsp;&nbsp; puts ] case
  $g [ '&nbsp;GIF&nbsp;&nbsp; puts ] case
  $h [ '&nbsp;HTM&nbsp;&nbsp; puts ] case
  drop '&nbsp;???&nbsp;&nbsp; puts
;
:gopher:get-selector (-)
  &Selector gets &Selector gets ;
(Rewrite_This:_It's_too_big)
:gopher:file-for-request (-s)
  &Mode v:off
  construct-filenames
  &Selector s:chop s:length n:-zero?
  [ requested-file file:exists?
    [ requested-file file:R file:open file:size n:positive? ] [ FALSE ] choose
    [ requested-file ]
    [ requested-index file:exists?
      [ requested-index &Server-Info v:on  ]
      [ PATH '/empty.index s:append ] choose
    ] choose
  ]
  [ PATH DEFAULT-INDEX s:append &Server-Info v:on ] choose
;
:gopher:read-file (f-s)
  file:R file:open !FID
  buffer buffer:set
  @FID file:size !Size
  @Size [ @FID file:read buffer:add ] times
  @FID file:close
  buffer
;
:link
  dup fetch gopher:icon n:inc
  [ ASCII:HT [ #0 ] case ] s:map
  dup s:length over + n:inc
  '<a_href="%s">%s</a><br> s:with-format puts ;
:gopher:generate-index (f-)
  'Content-type:_text/html puts eol eol
  file:R file:open !FID
  @FID file:size !Size
  [ buffer gopher:gets
    buffer tab? [ [ link ] html:tt eol ] [ gopher:i ] choose
    @FID file:tell @Size lt? ] while
  @FID file:close
;
:gopher:send (p-)
  @Size [ fetch-next putc ] times drop ;
:gopher:server
  gopher:get-selector
  'HTTP/1.0_200_OK puts eol
  gopher:file-for-request
  @Server-Info
  [ gopher:generate-index
    [ #70 [ $_ putc ] times ] html:tt html:br eol
    'forthworks.com:80_/_atua-www_/_running_on_retro gopher:i ]
  [ gopher:read-file eol gopher:send ] choose
;
}}
gopher:server
reset
