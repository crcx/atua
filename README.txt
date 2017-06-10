Atua: a Gopher Server
-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Atua is a pair of minimalistic Gopher servers written in Retro. The
primary one handles the gopher0 protocol. The other translates the
gophermaps into html and handles http/0.9.

Features:

- runs via inetd or tcpserver
- written in retro, a forth dialect
- supports simple gophermaps
- supports plain text, images, and simple binary documents

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Setting up:

You'll need Retro 12 (get it at forthworks.com/retro). Build this and
put the `rre` binary somewhere.

In the source files:

 * Atua.md
 * Atua-WWW.md

Ddjust the path to `rre` for your system and the path to your files.

Then, either use tcpserver:

    nohup tcpserver 0 80 ./atua-www.forth &
    nohup tcpserver 0 70 ./atua.forth &

Or add the apropriate entrires for your inetd configuration.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

References:

1. tcpserver is part of ucspi-tcp by D. J. Bernstein
   http://cr.yp.to/ucspi-tcp.html

2. Atua is written in Retro, my Forth dialect
   gopher://forthworks.com/retro
   http://forthworks.com/retro

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Atua is Copyright (c) 2017 by Charles Childers.

Permission to use, copy, modify, and/or distribute this software for
any purpose with or without fee is hereby granted, provided that the
above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
