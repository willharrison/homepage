---
title: Using AppleScript to create snake cased strings in Dragon Dictate
categories: [programming]
tags: [applescript, dragon dictate]
date: Jul 03 2015
---

## Using AppleScript to create snake cased strings in Dragon Dictate *Jul 03 2015*

I've been trying to use Dragon Dictate to program in lately. However, there is not a lot of documentation or help online. It took a while to figure out how to do this but I have finally discovered a way to convert my speech into a snake cased string. I hope this tip helps others that are trying to do the same as I.

### Creating the Command

You want to create a command of type AppleScript. The command name should be of the following format: `Snake /!Variable!/`. Where `Snake` is the name of the command and `Variable` is the speech that follows.

Below is the code use to achieve snake cased strings. `srhandler` accepts the dictated speech as its parameter. A shell script is then invoked so that `sed` can provide global substitution. Finally we tell System Event to send the string to the editor.

```js
on srhandler(vars)
    set dictatedText to (varVariable of vars)
    set testing to do shell script "echo " & quoted form of dictatedText & " | sed \"s/ /_/g\""
    tell application "System Events" to keystroke testing
end srhandler
```