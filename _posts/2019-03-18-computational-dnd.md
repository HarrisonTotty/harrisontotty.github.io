---
layout: post
title: "Computational Dungeons & Dragons"
---

I play Dungeons and Dragons (shocker, I know) - as fun as D&D is however, the flow of gameplay is often interrupted with extended periods of tedious calculation, particularly if you're the DM. You should then find it no surprise that I've built up quite an array of programs and workflows to streamline the D&D experience so that I can spend _more time playing_ and _less time calculating_.


# Rolling Dice

Rolling physical dice is _fun_. I try to roll physical dice whenever I can, however some calculations with dice are just plain tedious, and that's where the computer comes in. Take for example, the process of rolling the ability score values of a new character in D&D 5E:

> Roll six sets of _4d6_, summing the highest three numbers of each set.

I've written numerous programs and scripts to facilitate the dice-rolling process, but the latest iteration was a Python script I wrote called [roll](https://github.com/HarrisonTotty/roll). `roll` essentially works by first concatenating all positional arguments into a single string and then replacing all substrings of the form `\d*[dD]\d+` with their "rolled" results. I distinguish `XdY` from `XDY` such that `XdY` will compute the sum of the results, whereas `XDY` will only return the list of results. The resulting string itself is then computed via the Python interpreter via an `eval()` call. This is so the user can embed valid Python into their "roll string". For example:

```bash
$ roll 'sum(h(3D8, 2))' + 3d6 + 2
```

which essentially flows like so:

```python
roll_str = 'sum(h(3D8, 2)) + 3d6 + 2'

# ... replacement code here ...

repl_roll_str = 'sum(h([3, 6, 2], 2)) + (11) + 2'

print(str(eval(repl_roll_str)))
```

In the above example, `h(l, n)` is an alias for `highest(l, n)`, which is a function that returns a list containing the highest `n` integers in the list `l`. 

`roll` even allows some customization by providing the script with a YAML configuration file containing key-value maps between substrings in the given roll string, and the effective roll string to replace. Coming back to our tedious ability score example, this lets us define

```yaml
ability_scores: >-
  [sum(h(4D6,3)), sum(h(4D6,3)), sum(h(4D6,3)), sum(h(4D6,3)), sum(h(4D6,3)), sum(h(4D6,3))]
```

in a file called `roll.yaml` and then execute

```bash
$ roll -c roll.yaml 'ability_scores'
```

which might return something like

```
[10, 11, 10, 16, 13, 18]
```

If we plan on using the same configuration file most of the time, we can just set the `ROLL_CONFIG_FILE` environment variable instead of passing `-c roll.yaml` to the script. There are a few other convenient things the script can do as well, like displaying verbose and colored output.


# Looting Treasure

Loot tables are a pain, which is why I created a sort-of sister program to `roll` called [loot](https://github.com/HarrisonTotty/loot). Like `roll` (and like 90% of the other CLI programs I write for some reason), `loot` makes use of YAML configuration files, however they are much more front-and-center to the script's functionality. Let's first take a look at an example configuration file to make sense of what the script does:

```yaml
# Example Loot Configuration File
# -------------------------------

# The "quality" of the item
quality:
  - name: "shoddy quality"
    weight: 2
  - name: "mundane quality"
    weight: 3
  - "fine quality"
  
# ---------- Loot Table ----------
loot:
  # ----- Gold Coins -----
  - name: "gold"
    weight: 3
    loot:
      - name: "Gold Coins (1d6 + 1)"
        weight: 2
      - name: "Gold Coins (1d8 + 2)"
        weight: 3
      - name: "Gold Coins (1d10 + 4)"
        weight: 2
      - "Gold Coins (1d12 + 7)"
  
  # ----- Weapons -----
  - name: "weapon"
    types: quality
    loot:
      - name: "A dagger"
        weight: 2
      - "A longsword"
```

Essentially, the script crawls through the various layers of items within the `loot` key, randomly selecting which path it takes at each layer, which is augmented by assigning an optional `weight` to the entry. When it reaches an entry which is just a string or doesn't contain its own `loot` key, it prints the item. If the parent of the item specifies a `types` key, the script will also roll for the specified type, appending the result to the end of the selected item in parentheses. An output of a run on the above configuration file may look something like:

```
$ loot -C 3
Gold Coins (1d6 + 1)
A dagger (shoddy quality)
Gold Coins (1d8 + 2)
```

Note that the `-C` argument specifies the number of times to roll for loot. The script also allows you to specify a particular sub-table via the `-t` argument:

```
$ loot -C 3 -t weapon
A dagger (fine quality)
A dagger (mundane quality)
A longsword (mundane quality)
```

Take a look at the [full example configuration file](https://github.com/HarrisonTotty/loot/blob/master/loot.yaml) (and the one that I use for my campaigns) for a better idea.


# Generating Worlds

As a frequent DM, I often have to generate statistics and maps for the worlds that I create, which is another task I find tedious. I won't go that in-depth here, as I am still in the process of building a new set of tools to facilitate world generation, but I will talk a bit about what I have built in the past and what online tools I currently use.

As far as map generation is concerned, back in 2017 I wrote a simple terrain generation notebook in Mathematica that utilized weighted edge [Voronoi meshes](https://en.wikipedia.org/wiki/Voronoi_diagram), partly inspired by [this blog post](http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/), as well as [this one](https://mewo2.com/notes/terrain/):

![voronoi mesh generation](https://pbs.twimg.com/media/C8p95FQXoAAKIu6.jpg:large)

I suggest reading the above posts for more information on procedural map generation. Perhaps in the future I'll update this section when I develop a new version of the above tool.

Another fantastic tool for generating maps, factions, plots, items, and pretty much everything else you can think of, is [Dwarf Fortress](http://www.bay12games.com/dwarves/). In fact, it's _such_ a good tool for this that I'll probably write about it in its own blog post.


# Useful Links

Here's a random assortment of useful links that I frequently use.

## Procedural Generation

* https://squeakyspacebar.github.io/2017/07/12/Procedural-Map-Generation-With-Voronoi-Diagrams.html
* https://azgaar.github.io/Fantasy-Map-Generator/
* https://gmworldmap.com/

## Misc Random Generators & Tools

* https://donjon.bin.sh/
* http://1-dot-encounter-planner.appspot.com/
* http://kobold.club/fight/#/encounter-builder
* https://homebrewery.naturalcrit.com/
* http://chaoticshiny.com/merchgen.php 
