###
Copyright (c) 2014, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

module.exports = ($, templateName, options, cb) ->
  try
    $("gm-box").each ->
      $box = $(this)
      $table = $("<table style='width: 100%;'></table>")

      pt = pr = pb = pl = 0
      if paddingRaw = $box.attr "padding"
        $box.attr "padding", null
        paddings = paddingRaw.split(/\s+/).map (num) -> parseInt(num, 10)
        switch paddings.length
          when 1
            pt = pr = pb = pl = paddings[0]
          when 2
            [pt, pr] = paddings
            [pb, pl] = paddings
          when 3
            [pt, pr, pb] = paddings
            pl = pr
          when 4
            [pt, pr, pb, pl] = paddings

      for k, v of $box[0].attribs
        $table.attr k, v

      if pt
        row = $("<tr></tr>")
        row.append $("<td style='line-height:0;' height='#{pt}' width='#{pl}'>&nbsp;</td>") if pl
        row.append $("<td style='line-height:0;' height='#{pt}'>&nbsp;</td>")
        row.append $("<td style='line-height:0;' height='#{pt}' width='#{pr}'>&nbsp;</td>") if pr
        $table.append row

      row = $("<tr></tr>")
      row.append $("<td style='line-height:0;' width='#{pl}'>&nbsp;</td>") if pl
      contentTd = $("<td></td>")
      contentTd.append $box.contents()
      row.append contentTd
      row.append $("<td style='line-height:0;' width='#{pr}'>&nbsp;</td>") if pr
      $table.append row

      if pb
        row = $("<tr></tr>")
        row.append $("<td style='line-height:0;' height='#{pb}' width='#{pl}'>&nbsp;</td>") if pl
        row.append $("<td style='line-height:0;' height='#{pb}'>&nbsp;</td>")
        row.append $("<td style='line-height:0;' height='#{pb}' width='#{pr}'>&nbsp;</td>") if pr
        $table.append row
      $box.after $table
      $box.remove()

  catch e
    return cb(e)

  cb(null, $)
