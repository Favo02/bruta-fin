// generate a PDF to share with trusted contact
// (each contact gets one page)

// fill with encrypted file
#let file = "<encrypted-file-encoded-in-base64>"

// fill with shards
#let shards = (
  "1-<shard1>",
  "2-<shard2>",
  "3-<shard3>",
  "4-<shard4>",
  "5-<shard5>",
)

// fill with instructions/link
#let instructions = "https://github.com/Favo02/bruta-fin"

#set page(paper: "a4", margin: 1cm)
#set text(size: 18pt)

#let linebreaks(body) = {
  let chunks = range(0, body.len(), step: 60).map(i => body.slice(i, calc.min(i + 60, body.len())))
  chunks.join("\n")
}

#for (i, shard) in shards.enumerate() [
  #set align(center)

  #if i != 0 {
    pagebreak()
  }

  #datetime.today().display() -- #instructions

  #raw(linebreaks(file))

  #raw(linebreaks(shard))
]
