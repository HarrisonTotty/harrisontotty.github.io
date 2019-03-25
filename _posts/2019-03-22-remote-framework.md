---
layout: post
title: "The Remote Execution Framework"
---

If there's one thing you'll learn from these blog posts, it's that I am an incredibly picky individual when it comes to my computational tool set. Whether it's the workflow of my desktop environment, or the scripts that run on the various servers under my management, or even the function names in the API of a common library, I will basically rewrite anything that doesn't precisely conform to my liking. It's both a blessing and a curse I suppose, since I waste quite a bit of time over my nitpicking. Today I want to share the product of one such circumstance, a project I call my [Remote Execution Framework](https://github.com/HarrisonTotty/remote-framework).

As a member of the Web Systems team at Wolfram Research, I commonly find myself executing commands on a wide variety of remote hosts. A good portion of these hosts already have "remote execution frameworks" like [Fabric](http://www.fabfile.org/), [Salt](https://www.saltstack.com/), and [Ansible](https://www.ansible.com/) installed or supported, however many do not. Furthermore, each of the following systems suffers from one or more of the following issues:

* They are time consuming to set-up, either from the administrator's end, or from the system's end.
* They do _too much_. I don't want to install an entire service architecture just to run `puppet agent --disable` on 64 hosts _once_ because of some dumb fire.
* They require a service to be installed on the remote machine, or additional dependencies to be installed.
* They require a non-trivial amount of time to learn the various usages and terms (looking at you, Salt). This is basically the first point, but fight me.

Now to be perfectly clear here, _I enjoy each of the above tools_. I've used all of the tools above (as well as others), and they are _far superior_ to my remote execution framework in terms of possibilities etc. However, they are not _universally great_ (_no tool should ever claim that it is universally great - that's just a lie_). This is where my remote execution framework comes in: _it's really good at being really simple and lightweight_.


# A Basic Example

Let's start with a basic example. The core component of my framework is the script called `remote`, which is your conduit into awesomeness. Let's say we want to run `puppet agent --disable` on those 64 servers I mentioned above. Well, with `remote` it's as easy as the following, with no configuration required:

```bash
$ remote server{1..64}.example.com -u root -p -c 'puppet agent --disable'
```

The above should be pretty self-explanatory. `-u root` specifies that we should connect as the `root` user, while `-p` specifies that we should be prompted for a password (as opposed to specifying a certificate, etc.).

However, even I think that command's too long. With my remote framework, you can create aliases for hosts or collections of hosts through what I call a _target specification_ in a configuration YAML file called `~/remote.yaml`:

```yaml
targets:
  servers:
    hosts:
      - 'server[1-64].example.com'
    user: 'root'
```

Now we can re-write the above command into:

```bash
$ remote servers -p -c 'puppet agent --disable'
```

Looking better! Now `puppet agent --disable` is not a complex command to run, but if we wanted we could even alias _it_ by specifying what I call a _task_ definition in the same configuration file:

```yaml
targets:
  servers:
    hosts:
      - 'server[1-64].example.com'
    user: 'root'
tasks:
  puppet_off:
    cmd: 'puppet agent --disable'
```

In the remote framework, _tasks_ are distinguished between arbitrary commands, so we need to pass the `-r` argument to the script instead of `-c`. So the command has now been shortened into:

```bash
$ remote servers -p -r puppet_off
```

Next, we'll see how this feature can be expanded to more complex tasks.


# Complex Tasks

Okay that last example was a little silly. But what if you wanted to run something a bit more complex? What if you wanted to essentially execute a complex shell script on each of the above hosts? Luckily, task specifications in my script support multi-line strings and arguments. Let's say we want to define a task that deleted all files given to it. We might write something like the following (in the same config file from our previous example):

```yaml
targets:
  servers:
    hosts:
      - 'server[1-64].example.com'
    user: 'root'
tasks:
  del:
    desc: 'Deletes the specified path(s) on the specified target server(s).'
    cmd: |
      if [ "$#" -eq 0 ]; then
        echo 'Please specify one or more files to delete.'
        exit 1
      fi
      for f in $@; do
        if [ ! -e "$f" ]; then
          echo "$f does not exist on the local filesystem, skipping path."
        else
          rm -rf "$f"
          if [ "$?" -ne 0 ]; then
            echo "Unable to delete $f."
            exit 1
          fi
        fi
      done
```

Note that we also added a description to the task with the `desc` key. This is so that we can remember what it does when we run

```
$ remote --list-tasks
del  :  Deletes the specified path(s) on the specified target server(s).
```

We can now invoke this new task to delete `/root/foo.txt` and `/tmp/bar.txt` on all of our servers with the following command:

```bash
$ remote servers -p -r 'del:/root/foo.txt:/tmp/bar.txt'
```

Pretty neat huh?


## Wrapping Up

There are a lot of other neat things `remote` supports, like colored output, event logging, and file redirection detection. If you're interested in learning more, I wrote a hefty amount of documentation in the repository's [README](https://github.com/HarrisonTotty/remote-framework/blob/master/README.md) and [configuration file documentation](https://github.com/HarrisonTotty/remote-framework/blob/master/CONFIGURATION.md). The script also naturally has its share of bugs and "non-intuitive" behaviors, all of which are laid-out at the top of the README. I don't really expect anyone apart from myself and close friends using the script, but I'd love to hear if anyone else find it interesting or useful.
