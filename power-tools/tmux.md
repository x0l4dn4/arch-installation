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

#### Killing sessions

There are two ways to end a tmux session. First, you can attach to the session, stop all the programs within the session, and then type `exit` within a session.

You can also kill off sessions with the`kill-session` command.

```bash
tmux kill-session -t name-session
```

#### Working with windows

Windows are similar to tabs in terminal emulators.

When you create a new tmux session, the environment sets up an initial window for you. You can create as many as you’d like, and they will persist when you detach and reattach from the session.

```bash
tmux new -s name-session -n name-initial-window
```

To create a window in a current session, press `Prefix + c`. Creating a window like this automatically brings the new window into focus. 

To rename a window, press `Prefix + ,` and the status line changes, letting you rename the current window.

##### Moving between windows

When you only have two windows, you can quickly move between windows with `Prefix + n`, for “next window.” This cycles through the windows you have open. 

 You can use `Prefix + p` to go to the previous window.

By default, windows in `tmux` each have a number, starting at 0. You can quickly jump to the first window with `Prefix + 0`, and the second window with `Prefix + 1`.

To close a window, you can either type `exit` into the prompt in the window, or you can use `Prefix+ &`, which displays a confirmation message in the status bar before killing off the window.

If you accept, your previous window comes into focus. To completely close out the tmux session, you have to close all the windows in the session.

#### Working with panes

You can divide a window into panes so you can run multiple programs at once.

To divide down the middle of the window press `Prefix + %`
Press `Prefix + "` to split a pane in half horizontally.

To cycle through the panes, press `Prefix + o`. You can also use `Prefix`, followed by the `Up`, `Down`, `Left`, or `Right` keys to move around the panes. 

You close a pane the same way you exit a terminal session or a tmux window: you type `exit` in the pane. You can also kill a pane with `Prefix + x`, which also closes the window if there’s only one pane in that window.


#### See also:

https://pragprog.com/titles/bhtmux3/tmux-3/
https://tmux.app/sessions/
