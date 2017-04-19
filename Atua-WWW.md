# Atua-WWW: A Gopher Server for the Web

Atua is a gopher server written in Retro. This is a variation which
talks to HTTP clients instead of Gopher clients. It's intended to
allow those without a Gopher client to access my Gopherspace.

This will get run as an inetd service, which keeps things simple as it
prevents needing to handle socket I/O directly.

# Features

Atua is a minimal server targetting the the basic Gopher0 protocol. It
supports a minimal gophermap format for indexes and transfer of static
content.

Atua-WWW translates the Gophermap into HTML with minimal formatting.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

# Script Prelude

Atua-WWW uses Retro's *rre* interface layer. Designed to run a single
program then exit, this makes using Retro as a scripting language
possible.

````
#!/home/crc/retro12/bin/rre
drop
````

# Configuration

Atua needs to know:

- the path to the files to serve
- the name of the index file
- The maximum length of a selector
- The maximum file size

````
'/home/crc/atua s:keep 'PATH const
'/gophermap     s:keep 'DEFAULT-INDEX const
#1024  'MAX-SELECTOR-LENGTH const
#65535 #4 * 'MAX-FILE-SIZE const
````

# I/O Words

Retro only supports basic output by default. The RRE interface that
Atua uses adds support for files and stdin, so we map these to words
and provide some other helpers.

*Console Output*

The Gopher protocol uses tabs and cr/lf for signficant things. To aid
in this, I define output words for tabs and end of line.

````
:eol  (-)  ASCII:CR putc ASCII:LF putc ;
````

*Console Input*

Input lines end with a cr, lf, or tab. The `eol?` checks for this.
The `gets` word could easily be made more generic in terms of what
it checks for. This suffices for a Gopher server though.

````
:getc (-c) `1001 ;
:eol? (c-f)
  [ ASCII:CR eq? ] [ ASCII:LF eq? ] [ ASCII:SPACE eq? ] tri or or ;
:gets (a-)
  buffer:set
  [ getc dup buffer:add eol? not ] while ;
````

*File I/O*

Retro's file I/O words are still under development. This is similar
to the iOS `file:` namespace, but there are some small differences.

````
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
````

# An HTML Namespace

````
:html:tt  (q-)  '<tt> puts call '</tt> puts ;
:html:br  (-)   '<br> puts ;
````

# Gopher Namespace

Atua uses a `gopher:` namespace to group the server related words.

````
{{
````

First up are buffers for the selector string and the file buffer. The
variables and buffers are kept private.

````
'Selector d:create
  MAX-SELECTOR-LENGTH n:inc allot
:buffer here ;
````

Next up, variables to track information related to the requested
selector. Atua will construct filenames based on these.

````
'Requested-File var
'Requested-Index var
````

`FID`, the file id, tracks the open file handle that Atua uses
when reading in a file. The `Size` variable will hold the size of
the file (in bytes).

````
'FID var
'Size var
'Mode var
````

I use a `Server-Info` variable to decide whether or not to display
the index footer. This will become a configurable option in the
future.

````
'Server-Info var
````

These are just simple accessor words to aid in overall readability.

````
:requested-file  (-s)  @Requested-File  ;
:requested-index (-s)  @Requested-Index ;
````

````
:with-path (-s)
  PATH &Selector s:chop s:append ;
:construct-filenames (-)
  with-path s:keep !Requested-File
  with-path '/gophermap s:append s:keep !Requested-Index
;
````

A *gophermap* is a file that makes it easier to handle Gopher menus.
Atua's gophermap support covers:

- comment lines

  Comment lines are static text without any tabs. They will be
  reformatted according to protocol and sent.

- selector lines

  Any line with a tab is treated as a selector line and is transferred
  without changing.

````
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
````

The internal helpers are now defined, so switch to the part of the
namespace that'll be left exposed to the world.

````
---reveal---
````

An information line gets a format like:

  i...text...<tab><tab>null.host<tab>port<cr,lf>

The `gopher:i` displays a string in this format. It's used later for
the index footer.

````
:gopher:i (s-)
  [ puts ] html:tt html:br eol ;
````

The `gopher:icon` displays an indicator for menu items.

````
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
````

````
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
````

````
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
````

In a prior version of this I used `puts` to send the content. That
stopped at the first zero value, which kept it from working with
binary data. I added `gopher:send` to send the `Size` number of
bytes to stdout, fixing this issue.

````
:gopher:send (p-)
  @Size [ fetch-next putc ] times drop ;
````

The only thing left is the top level server.

````
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
````

Close off the helper portion of the namespace.

````
}}
````

And run the `gopher:server`.

````
gopher:server
reset
````
