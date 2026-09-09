## Terminal multiplexer

#### Introduction

`tmux` is a terminal **multiplexer**. It lets you use a single environment to launch multiple terminals, or windows, each running its own process or program.

You can divide your terminal windows into horizontal or vertical panes, which means you can run two or more programs on the same screen side by side

You can also detach from a session, meaning you can leave your environment running in the background.

Since tmux uses a client-server model, you can control windows and panes from a central location or even jump between multiple sessions from a single terminal window.

This client-server model also lets you create scripts and interact with tmux from other windows or applications. 

#### Start tmux

To start tmux, just type `tmux`

At the bottom of the window is the status line. By default, it shows the tmux session number, the window index, the name of the program that’s currently running, your host name, and the date and time. 

You can run multiple tmux sessions on your machine at the same time, and each session can have multiple windows, so the status line indicates where you are. 

> To close the tmux session, type exit in the session itself, or press Ctrl+d. This will close tmux and then return you to the standard terminal session

#### Named sessions

It is better to stay organized, you can create a named-session

```bash
tmux new-session -s name
tmux new -s name # shorter version
```

#### Command prefix

You need a way to tell `tmux` that the command you’re typing is meant for tmux and not for the underlying application. This combination is called the **command prefix**. 

> [Warning]
> It’s important to note that you don’t hold all these keys down together. Instead, first press Ctrl-b simultaneously, release those keys, and then immediately press the key for the command you want to send to tmux.

#### Detaching and Attaching Sessions

A `tmux` session is a **persistent workspace** that groups windows and panes together and continues running in the background even after you disconnect.
 
> Sessions survive SSH drops, network changes, and terminal closures.

To **detach** a session and send it to the background press `Prefix + d`.
To **attach** a session to the foreground you must known what session do you want to attach.

```bash
tmux list-sessions
tmux ls # shorter version
```
If you only have one session running you can just pass the `attach` command. If you have more you can choose it with the `-t` option.

```bash
tmux attach
tmux attach -t name-session
```

#### See also:

https://pragprog.com/titles/bhtmux3/tmux-3/
https://tmux.app/sessions/
