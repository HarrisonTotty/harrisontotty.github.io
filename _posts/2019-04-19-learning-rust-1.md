---
layout: post
title: "Learning Rust: Writing A Configurable Dialog System - Part 1"
---

I've been dabbling in [Rust](https://www.rust-lang.org/) for quite some time now and wanted to share my progess in writing a configurable dialog system called `dlg`. I want this post to be part of a series, in which I walk the reader through some of the highlights and design decisions of this program's development processes. I'm going to assume that the reader has programmed _some_ Rust. At the time of this post the associated repository is still private, but hopefully I'll be able open it up here in the next few weeks or so.


# Motivation

The motivations for this program are as follows:

1. I want to create a dialog system similar to [rofi](https://github.com/davatorium/rofi) and [dmenu](https://tools.suckless.org/dmenu/), however rather than primarily being an application launcher like the previously mentioned programs, I want this program to function as a general dialog system - as a replacement for how I currently use `rofi` in my [dotfiles](https://github.com/HarrisonTotty/dotfiles).

2. I want to use this as an opportunity to build up my personal development workflow for Rust applications, as well as an opportunity to further refine my Rust programming abilities.

3. I want to record the development process to help others


# Program Description

`dlg` (I wanted to call it `dialog`, but I already use a package in Arch Linux with the same name) is a program that is used to display a configurable dialog window. The basic use-case involves piping a set of available choices to the program, in which the program will respond by printing the choice made by the user. An example shell script using the program might look like this:

```bash
#!/bin/bash
# The following script displays a list of available netctl profiles, allowing
# the user to select a profile to be started.

# Set-ups some environment variables. These will be consumed by our program, so
# that we don't have to add a bunch of long argument strings.
export DLG_LINES=16
export DLG_PROMPT='switch network profile : '

# Get the list of available profiles.
profiles="$(find /etc/netctl -maxdepth 1 -type f -printf '%f\n')"

# Display the dialog and store the selected item.
result="$(dlg --sort <<< $profiles)"

# ... do something with the selected network profile ...
```

Some things to take away from the above:

1. Possible dialog choices are piped to *STDIN* of the program.

2. The program may be configured with _either_ command-line arguments _or_ environment variables. In addition, I'd like to be able to configure the program with a dedicated configuration file.

3. The result of the selection is printed to *STDOUT*.


# Initializing Project Structure

Everyone has their own workflow for starting a project. I tend to first create a project on GitHub or GitLab and then clone the empty repository into a dedicated project folder under `~/projects`. In this case:

```bash
# ~
$ cd ~/projects

# ~/projects
$ git clone https://github.com/HarrisonTotty/dlg dlg

# ~/projects
$ cd dlg
```

_(From this point forward, we will assume that all shell commands are being executed from within `~/projects/dlg`)_

Next, let's create the overall project structure. If this were a larger project that was built from multiple custom libraries, we'd probably want to create multiple crates within the base folder and then specify a `[workspace]` section in a root `Cargo.toml` file. Such a project tree might look like this:

```
- ~/projects/dlg/
  - Cargo.toml
  - dlg-bin/
    - Cargo.toml
    - src/
      - bar.rs
      - main.rs
  - dlg-lib/
    - Cargo.toml
    - src/
      - foo.rs
      - lib.rs
```

where the contents of `~/projects/dlg/Cargo.toml` would be:

```toml
[workspace]
members = [
    "dlg-bin",
    "dlg-lib"
]
```

However, our project isn't that big (or so I currently foresee, anyways), so we'll just create a single binary crate under the root directory:

```bash
$ cargo init --name dlg --vcs none
```

We might now have a directory structure that looks like this:

```
- ~/projects/dlg/
  - Cargo.toml
  - LICENSE
  - README.md
  - src/
    - main.rs
```

Next let's clean up the default `Cargo.toml`, replacing it with the following:

```toml
[package]
authors     = ["Harrison Totty <harrisongtotty@gmail.com>"]
description = "A highly customizable dialog system written in Rust."
edition     = "2018"
name        = "dlg"
publish     = false
readme      = "README.md"
version     = "0.1.0"
```

Okay cool. We now have a basic project structure, so let's move on to dependencies.


# Determining Initial Project Dependencies

We know that this project is going to make heavy use of CLI arguments and environment variables, so we should choose a library that offers the most features in that regard. My current favorite is the [clap](https://crates.io/crates/clap) crate, so let's add it to our `Cargo.toml`:

```toml
[package]
authors     = ["Harrison Totty <harrisongtotty@gmail.com>"]
description = "A highly customizable dialog system written in Rust."
edition     = "2018"
name        = "dlg"
publish     = false
readme      = "README.md"
version     = "0.1.0"

[dependencies.clap]
features = ["color"]
version  = "2.32.0"
```

I personally like to specify Cargo dependencies in the `[dependencies.CRATE]` section format, since it makes it easier to append additional crate features and requirements. If you haven't already, I _highly_ recommend the reader check out the [Manifest Format](https://doc.rust-lang.org/cargo/reference/manifest.html) section of the [Cargo Book](https://doc.rust-lang.org/cargo/index.html).

For designing the GUI portion of the program I've decided to leverage the [azul](https://github.com/maps4print/azul) library. This was essentially a guess, so we'll see how this pans out as we get further into the project. Note that at the time of writing this post, the `azul` library does not consider itself "stable" (and thus isn't on crates.io), so we'll have to pull it directly from git. Here's where the previously discussed dependency format comes in handy again, so we'll add the following chunk to our `Cargo.toml`:

```toml
[dependencies.azul]
git = "https://github.com/maps4print/azul"
```

Finally, I would like our program to be able to read in a YAML configuration file, so we'll leverage the [yaml-rust](https://crates.io/crates/yaml-rust) crate to do that:

```toml
[dependencies.yaml-rust]
version = "0.4"
```

We may add or remove dependencies in the future, but we'll start with these.


# Getting Started!

Awesome, we're ready to start writing some code! Let's start by replacing the default contents of `~/projects/dlg/src/main.rs` with:

```rust
//! dlg - A highly customizable dialog system written in Rust.

/// The entrypoint of the program.
pub fn main() {

}
```

I think it's a good idea to leverage the `//!` and `///` docstring comments whenever possible. For those of you who are unfamiliar with Rust's built-in docstring comments, I suggest reading the [Making Useful Documentation Comments](https://doc.rust-lang.org/book/ch14-02-publishing-to-crates-io.html#making-useful-documentation-comments) and [Commenting Contained Items](https://doc.rust-lang.org/book/ch14-02-publishing-to-crates-io.html#commenting-contained-items) subsections of the [Rust Book](https://doc.rust-lang.org/book/title-page.html).

Note that we also explicitly set the `pub` keyword for `fn main()`. In our case, this is primarily so that we can review the documentation of our project via a quick call to

```bash
$ cargo doc --open
```

without also having to specify the `--document-private-items` flag.


## Parsing Command Line Arguments

The first thing we want our program to do, from a logical runtime sense, is parse command-line arguments - so let's start fleshing out that logic. I'd like to store this and other bits of what I'd consider "initialization" logic (in the sense that it pertains to logic that occurs prior to the main "substance" of the program) in its own file called `src/init.rs`. Within this file will be a function called `get_arguments` which will parse the command-line arguments and return a collection of argument values. In the `clap` crate, this corresponds to an instance of the [clap::ArgMatches](https://docs.rs/clap/2.33.0/clap/struct.ArgMatches.html) struct. We start by writing the basic layout of `src/init.rs`, which looks like the following:

```rust
//! Contains logic for initializing the program, etc.

/// Parses the command-line arguments passed to the program, returning a
/// collection of matches.
pub fn get_arguments()<'a> -> clap::ArgMatches<'a> {

}
```

In `src/main.rs`, we'll call the above function like so:

```rust
//! dlg - A highly customizable dialog system written in Rust.

// ----- Custom Modules -----
pub mod init;
// --------------------------

/// The entrypoint of the program.
pub fn main() {
    // First, let's parse the command-line arguments.
    let _args = init::get_arguments();
}
```

Note that we specify the target variable as `_args` instead of `args` so that the compiler doesn't warn us about an unused variable. We'll change this to `args` later down the road.

Now it's time to add content to the `parse_arguments()` function. The first thing I like to do is declare all of my necessary `use` statements. Unless the whole file needs the imported definitions, I like to keep these localized to individual functions. In our case, we'll be making use of the [App](https://docs.rs/clap/2.33.0/clap/struct.App.html) and [Arg](https://docs.rs/clap/2.33.0/clap/struct.Arg.html) structs, as well as the [AppSettings](https://docs.rs/clap/2.33.0/clap/enum.ArgSettings.html) enum and a few convenient macros. This gets the body of `get_arguments` to the following state:

```rust
pub fn get_arguments<'a>() -> clap::ArgMatches<'a> {
    use clap::{
        App,
        AppSettings,
        Arg,
        crate_authors,
        crate_description,
        crate_version
    };
}
```

The next step is to initialize the `clap::App` struct and begin to add argument definitions to it. Let's start by creating the struct and using the `crate_*` macros to automatically fill in some information for us:

```rust
pub fn get_arguments<'a>() -> clap::ArgMatches<'a> {
    use clap::{
        App,
        AppSettings,
        Arg,
        crate_authors,
        crate_description,
        crate_version
    };
    let argument_parser = App::new(crate_name!())
        .about(crate_description!())
        .author(crate_authors!())
        .help_message("Displays help and usage information.")
        .version(crate_version!())
        .version_message("Displays version information.")
        .settings(
            &[
                AppSettings::ColoredHelp
            ]
        );
    return argument_parser.get_matches();
}
```

Some notes about the above block of code: In Rust, `return` statements may be implied by simply ending the function body with a non-`;`-terminated expression (without the `return` keyword). I tend to be pretty fluid with this syntax, and still prefer an explicit `return` keyword when a function gets super long, which this function definitely _will_.

The next step is to add all of the option and flag definitions. This is done via additional method calls on the `clap::App` struct, so we'll remove the trailing semicolon attached to `.settings( ... );` and insert some calls to `.arg()`. This part consumes the bulk of the code for this function, so I won't show all of the entries here. Below is a code snippet of how I added the `-p`/`--prompt` option to the program:

```rust
.arg(Arg::with_name("prompt")
    .default_value("input : ")
    .env("DLG_PROMPT")
    .help("Specifies the prompt text to be displayed ...")
    .long("prompt")
    .short("p")
    .value_name("STR")
)
```

When all is said and done, after a call to `cargo run -- -h`:

```
dlg 0.1.0
Harrison Totty <harrisongtotty@gmail.com>
A highly customizable dialog system written in Rust.

USAGE:
    dlg [FLAGS] [OPTIONS]

FLAGS:
    -a, --allow-custom    Specifies that the resulting dialog supports custom user input.
    -h, --help            Displays help and usage information.
    -j, --json            Specifies that the script should expect a JSON list as input, and should a print a JSON object
                          as output.
        --sort            Specifies that the dialog entries should be sorted.
    -V, --version         Displays version information.

OPTIONS:
    -b, --border <INT>                  Specifies the width of the borders around the resulting dialog window. [env:
                                        DLG_BORDER=]
    -B, --borders <LFT RHT TOP BTM>     Specifies the width of the (individual) borders around the resulting dialog
                                        window. [env: DLG_BORDERS=]
    -C, --colors <FG BG BRD SFG SBG>    Specifies the colors of the resulting dialog window. Individual colors may be
                                        specified by their X name ("white") or hex code ("#FFFFFF"). [env: DLG_COLORS=]
    -c, --config-file <FILE>            Specifies the configuration file to load. Utilizing a dedicated configuration
                                        file allows for greater flexibility in the appearance and characteristics of the
                                        resulting dialog. [env: DLG_CONFIG_FILE=]
    -d, --dialog <NAME>                 Specifies a name of a pre-built or user-defined dialog specification to invoke.
    -f, --font <NAME:SIZE>              Specifies the overall font to utilize in the resulting dialog window. The name
                                        of this font may correspond to either a system font name or the path to the
                                        relevant font file. [env: DLG_FONT=]
    -H, --height <INT>                  Specifies the height of the resulting dialog window. May be set to "0" to imply
                                        that the resulting window should be "stretched" in the Y direction. [env:
                                        DLG_HEIGHT=]
    -l, --lines <INT>                   Specifies the number of visable selectable lines of entries in the resulting
                                        dialog window. May be set to a negative integer value to imply that the
                                        resulting dialog should function in a "dmenu"-like form, where all entries are
                                        displayed horizontally instead of vertically. If this value is set to "0", the
                                        resulting dialog will display entries in a grid-like format. [env: DLG_LINES=]
                                        [default: 16]
    -m, --message <STR>                 Specifies a message to display in the resulting dialog window. [env:
                                        DLG_MESSAGE=]
        --padding <LFT RHT TOP BTM>     Specifies the padding around the resulting dialog window. [env: DLG_PADDING=]
    -P, --position <POS>                Specifies the general position of the resulting dialog window. [env:
                                        DLG_POSITION=]  [default: center]  [possible values: bottom,
                                        bottom_left, bottom_right, center, left,
                                        right, top, top_left, top_right]
    -X, --pos-X <INT>                   Specifies the x-coordinate (of the center) of the resulting dialog window. [env:
                                        DLG_POS_X=]
    -Y, --pos-Y <INT>                   Specifies the y-coordinate (of the center) of the resulting dialog window. [env:
                                        DLG_POS_Y=]
    -p, --prompt <STR>                  Specifies the prompt text to be displayed in the resulting dialog window. [env:
                                        DLG_PROMPT=]  [default: input : ]
    -W, --width <INT>                   Specifies the width of the resulting dialog window. May be set to "0" to imply
                                        that the resulting window should be "stretched" in the X direction. [env:
                                        DLG_WIDTH=]
```


## Validating Command-Line Arguments

In addition to `clap`'s built-in argument validation, we can also add additional argument validations with the [validator()](https://docs.rs/clap/2.33.0/clap/struct.Arg.html#method.validator) method, which consumes a function of the form

```rust
Fn(String) -> Result<(), String>
```

where the input string refers to the value associated with the corresponding option.

Let's look at a definition for the `-c`/`--config-file` option described above:

```rust
.arg(Arg::with_name("config_file")
    .env("DLG_CONFIG_FILE")
    .help("Specifies the configuration file to load...")
    .long("config-file")
    .short("c")
    .validator(validate_path)
    .value_name("FILE")
)
```

We could envision `validate_path` to be the name of a function defined like so:

```rust
pub fn validate_path(path: String) -> Result<(), String> {
    match std::path::Path::new(&path).is_file() {
        true => Ok(()),
        _ => Err(String::from("Specified file doesn't exist."))
    }
}
```

However, I think it's much more convenient to utilize Rust's [Closures](https://doc.rust-lang.org/book/ch13-01-closures.html) here:

```rust
.arg(Arg::with_name("config_file")
    .env("DLG_CONFIG_FILE")
    .help("Specifies the configuration file to load...")
    .long("config-file")
    .short("c")
    .validator( | path | {
        match std::path::Path::new(&path).is_file() {
            true => Ok(()),
            _ => Err(String::from("Specified file doesn't exist."))
        }
    })
    .value_name("FILE")
)
```

Much better!


# Closing Notes

* `init::get_arguments()` _must_ define a particular lifetime. Ironically lifetimes and borrowing, some of the "flagship" features of Rust, are still not completely intuitive to me.

* Another large initial pain point is the use-case differences between `str` and `String`, although I think I am mostly comfortable with this now.
