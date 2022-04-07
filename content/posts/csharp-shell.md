---
title: "Writing a very simple shell in C#"
categories: [programming]
tags: [c#, shells]
---

## Writing a very simple shell in C# *Oct 31 2017*

A few months ago I stumbled across a very interesting post by Stephen Brennan detailing the specifics for [implementing a shell in C](https://brennan.io/2015/01/16/write-a-shell-in-c/).  It is a very illuminating post into something that many programmers believe is sort of magic (at least, beginning programmers).  I thought it might be worthwhile to write a short post about implementing a similar shell in C#.  This will be a text based shell like `cmd.exe`, not graphical one like `explorer.exe`. Although, it should be noted that both of these programs are indeed shells albeit a different type.

### What is a shell?

> In computing, a shell is a user interface for access to an operating system‘s services. In general, operating system shells use either a command-line interface(CLI) or graphical user interface (GUI), depending on a computer’s role and particular operation. It is named a shell because it is a layer around the operating system kernel.

Above is the definition of a shell according to Wikipedia.  While you can often times access the services of an operating system through programs other than shells, they will usually give the user the most straightforward option for interacting with the operating system.  In addition to giving the user programs for interaction with the operating system, they also often provide the user with scripting capabilities.  Examples of scripting capabilities include batch files in Windows and the bash command language in Unix-like operating systems.

Both of the above examples are text shells.  However, there are also graphical shells, as mentioned above.  Examples include explorer.exe on Windows and the X window manager on Unix-like systems.  Operating systems, more often than not, use a combination of both types of shells.

### How do shells work?

Shells run on a very basic loop, not too dissimilar to a programming language’s REPL.  But, instead of a read-evaluate-print loop, they follow more of a *read-parse-execute* loop.  Initially, after the shell have started up and input has been given by the user, the shell will take the input and determine the command and the arguments passed to the command.  Next, the command is executed, and the loop starts over.  When executing commands, shells will start up a new process instead of running the command inside the same process as the shell.  This allows for commands to easily be created as separate programs and run within the shell.  In addition, this method of execution keeps the shell from having to rely on the commands that are executing.

[Here](/images/shell-example.gif) is an example animation of a program being executed in a shell and subsequently being added to the process list.  This example is done using WSL. (I’m currently using the word process informally.  Technically, Windows systems have the concept of a process and Unix systems only have the concept of threads.  Unix threads can have child and parent threads.  On Windows systems, all threads live inside a process.)



### Building the shell

We are building a very simple text based shell using C# (as suggested by the title).  By simple, I mean very simple.  We will not be implementing any scripting functionality.  I might do a separate post on that, though, because I think it would be interesting to talk about.  But, no, we will just be implementing a shell that will take a command (that does not have arguments), find the associated program for that command, and execute that program in a separate process.

The skeleton of this project is pretty sparse.

```csharp
public class Shell
{
    private Dictionary<string, string> Aliases = new Dictionary<string, string>();
    public void Run() { }
    public int Execute(string input) { }
}
```

The `Aliases` dictionary will be used to hold commands and their corresponding programs. Adding this was a pretty arbitrary decision on my part, but I felt like having aliases. It wouldn’t be too hard to implement an alias method that allowed the user to add their own aliases.

`Run` is the entry point to our shell. It will start the loop up and gather user input.

```csharp
public void Run()
{
    string input = null;

    do
    {
        Console.Write("$ ");
        input = Console.ReadLine();
        Execute(input);
    } while (input != "exit");
}
```

`Execute` is where we will fire up new processes and run our program. First, we check our dictionary of `Aliases`. If we cannot find the given command, we write a helpful error message and return 1, the standard integer to indicate failure. However, if we do find a matching alias, we start a new process with the alias’s corresponding program’s path. After the program finishes executing, we exit the process and return 0, the standard indication for success.

```csharp
public int Execute(string input)
{
    if (Aliases.Keys.Contains(input))
    {
        var process = new Process();
        process.StartInfo = new ProcessStartInfo(Aliases[input])
        {
            UseShellExecute = false
        };

        process.Start();
        process.WaitForExit();

        return 0;
    }

    Console.WriteLine($"{input} not found");
    return 1;
}
```

That’s about all that goes in to it. It would be nice to have at least one program to try out with it, so how about we write `ls`.

```csharp
class Program
{
    static void Main(string[] args)
    {
        var files = Directory.GetFiles(Directory.GetCurrentDirectory());

        foreach (var file in files)
        {
            Console.WriteLine(file);
        }
    }
}
```

And lastly, we need to add `ls` to our list of aliases.

```csharp
private Dictionary<string, string> Aliases = new Dictionary<string, string>
{
    { "ls", @".\ListDirectories.exe" }
};
```

### Wrapping up

As you can see, writing a shell isn’t as complicated as many would believe. There are a lot of things we could have done to make our shell much nicer, but I’m a bit tired at the moment and just wanted to make sure I got something out this week for you all to read. I do think it would be a great exercise to try and improve this project (in the many many ways possible) and would love to see what some of you come up with.

[Code can be found on GitHub](https://github.com/willharrison/ProgrammingWithWill/tree/master/Shell).