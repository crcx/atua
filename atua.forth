#!/home/crc/retro12/bin/rre
drop
'/home/crc/atua s:keep 'PATH const
'/gophermap     s:keep 'DEFAULT-INDEX const
#1024  'MAX-SELECTOR-LENGTH const
#1000000 #4 * 'MAX-FILE-SIZE const
:eol  (-)  ASCII:CR putc ASCII:LF putc ;
:getc (-c) `1001 ;
:eol? (c-f)
  [ ASCII:CR eq? ] [ ASCII:LF eq? ] [ ASCII:HT eq? ] tri or or ;
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
  'i%s\t\tnull.host\t1 s:with-format puts eol ;
:gopher:get-selector (-)
  &Selector gets ;
(Rewrite_This:_It's_too_big)
:gopher:file-for-request (-s)
  &Mode v:off
  construct-filenames
  &Selector s:chop s:length n:-zero?
  [ @Requested-File file:exists?
    [ @Requested-File file:R file:open file:size n:positive? ] [ FALSE ] choose
    [ @Requested-File ]
    [ @Requested-Index file:exists?
      [ @Requested-Index &Server-Info v:on  ]
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
:gopher:generate-index (f-)
  file:R file:open !FID
  @FID file:size !Size
  [ buffer gopher:gets
    buffer tab? [ puts eol ] [ gopher:i ] choose
    @FID file:tell @Size lt? ] while
  @FID file:close
;
:gopher:send (p-)
  @Size [ fetch-next putc ] times drop ;
:gopher:server
  gopher:get-selector
  gopher:file-for-request
  @Server-Info
  [ gopher:generate-index
    '------------------------------------------- gopher:i
    'forthworks.com:70_/_atua_/_running_on_retro gopher:i 
    '. puts eol ]
  [ gopher:read-file gopher:send ] choose
;
}}
gopher:server
reset
