# hubot-mtg

this script lets hubot show mtg card image.
- specified card image
- random card image
- standard/modern/edh card image(wip)
- momir basic pick(wip) 

See [`src/mtg.coffee`](src/mtg.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-mtg --save`

Then add **hubot-mtg** to your `external-scripts.json`:

```json
[
  "hubot-mtg"
]
```

## Sample Interaction

```
user1>> cast mountain
hubot>> http://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=Mountain#.jpg
```
