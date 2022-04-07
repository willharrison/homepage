---
title: "Starting out with test-driven development (Part 1: Create a test runner)"
categories: [programming]
tags: [c#, tdd]
---

## Starting out with test-driven development (Part 1: Create a test runner) *Oct 17 2017*

1. [Part 1: Create a test runner](/posts/tdd-part-1.html)
2. [Part 2: Writing code](/posts/tdd-part-2.html)

***Last Updated 10/23/2016***

Over the years I’ve found myself becoming more and more passionate about test-driven development. However, I constantly ran into the same problem over and over again: my ability to understand and use TDD could not keep pace with my desire to learn it. When looking through various blogs online, I have noticed that I’m not the only one that struggled with TDD, so I decided to write a short post about it in hopes of helping out some other aspiring developer.

### What is TDD, exactly?

TDD is a methodology for building software more-so than a methodology for testing software. I should mention, when I talk about testing in the context of TDD, I’m specifically referring to unit testing.

There’s a [good article](http://butunclebob.com/ArticleS.UncleBob.TheThreeRulesOfTdd) by [Bob Martin](http://butunclebob.com/) about TDD, and it covers the methodology in three simple points:

> 1. You are not allowed to write any production code unless it is to make a failing unit test pass.
> 2. You are not allowed to write any more of a unit test than is sufficient to fail; and compilation failures are failures.
> 3. You are not allowed to write any more production code than is sufficient to pass the one failing unit test.

Another way to think about it is **Red-Green-Refactor**. Write a failing test (red). Make the test pass (green). Clean up all the regrets you’ve made along the way (refactor).

### Why should you care?

It is extremely nice to have huge test coverage to fall back on when things start breaking, but it is not the purpose of TDD.

If TDD isn’t primarily about testing (as you would intuitively think), what is it really about? It’s about design. It’s about making sure your classes do one thing and they do it well. It’s about making sure you can switch out dependencies at run-time and not worry about everything blowing up. It’s about SOLID.

When you start writing code using TDD, you’ll notice that it’s really hard to have complex, non-injected, dependencies between classes because having these dependencies makes it very difficult to test. True, you can still have ten objects injected into the constructor of some other object, but that is easily dealt with using various methods (a post for another day).

### What we’re building.

We’re going to make a simple program that converts a number into a pyramid. For instance, if you give an input of `1`, you’ll get an output of `/\`. But, if you give an input of `5`, you’re gonna get an output of

```
    /\
   /  \
  /    \
 /      \
/        \
```

If you’ve read anything about TDD, you’ve probably come across a few words: MSTest, NUnit, xUnit, \*Unit. There are various libraries out there to help you unit test, but we’re gonna gloss over that for now and just start with the basics by writing our own test runner.  ***Never write your own test runner for production code***.

### But first, the PyramidTestRunner.

Our test runner will be **extremely** basic and only do the bare minimum. It will also only work with the bare minimum. I’ll leave it to the reader to make it more generic, as an exercise, and we’ll assume the only thing we care about testing is our `Pyramid` class.

First, we’re going to need some sort of way to determine that a method in a class is a test. I’ve decided a good and simple way of designating this is to create a custom attribute named `Test`.

```csharp
public class TestAttribute : Attribute { }
```

It doesn’t need to do anything other than decorate our methods, so we’re not doing anything else with it. Next, we need to implement a simple test runner that will take a class that we give it (`PyramidTests` in our case), loop over the methods in that class, pull out the ones that are decorated with our attribute, and invoke them.

```csharp
public class PyramidTestRunner
{
    public static void RunTests()
    {
        var testClass = new PyramidTests();

        foreach (var method in testClass.GetType().GetMethods())
        {
            if (method.IsDefined(typeof(TestAttribute)))
            {
                method.Invoke(testClass, new object[] { });
            }
        }
    }
}
```

Our class above does just what we need it to. We create an instance of the test class (`PyramidTests`), get all the methods in class, we make sure that the `TestAttribute` is defined on our method, and if so, we invoke our method without any arguments.

### Next time

I originally wanted this to be one post that encompassed everything, but after typing all of this out it looks like it’ll have to have a continuation piece. The next post will focus on implementing the actual test class and the class we’re testing against.


## Update (10/23/2016)

When I first wrote this post, I was coding everything as I went along.  I now realize that’s probably not the best way to go about it, because I left out a few things.

### Additions to the PyramidTestRunner and attributes

Nothing big here, but after running the program, I noticed it would be much nicer if we could get a stack trace when an exception occurs (aka a test fails).  This wasn’t a big change, I just wrapped the foreach with an exception block.

```csharp
// additions to test runner
try {
    // actual logic for checking a test
    Console.WriteLine("Tests succeeded");
}
catch (Exception e)
{
    Console.WriteLine("Stack Trace:");
    Console.WriteLine(e);
}
```

I also found it nice to have an attribute that allows me to ignore a test temporarily. To add this functionality, I created a new `IgnoreAttribute` class and checked that the test method was not decorated with this attribute before invoking the method.

```csharp
public class IgnoreAttribute : Attribute { }

// additions to test runner
var isTest = method.IsDefined(typeof(TestAttribute));
var isIgnored = method.IsDefined(typeof(IgnoreAttribute));
if (isTest && !isIgnored)
{
    method.Invoke(testClass, new object[] { });
}
```

### Assertions

I don’t know how I missed this, but we definitely need a way to assert that something has passed, whether that be by equality, existence, or some other condition. This is a very simple class to implement because we’re only going to focus on `Assert.IsEqual` for the time being. It would also be easy to implement other types of asserts, such as `IsNull`, `IsEmpty`, etc.

For our `Assert` class we need a `IsEqual` method that works with a string, because we know we will be testing against strings. Our equality assertion will take in string that we expect and the string that we actually have and make sure they are equal.

```csharp
public class Assert
{
    public static void IsEqual(string expected, string actual)
    {
        if (expected != actual)
        {
            Console.WriteLine("Expected");
            Console.WriteLine(expected);
            Console.WriteLine('\n');
            Console.WriteLine("Actual");
            Console.WriteLine(actual);
            throw new Exception();
        }
    }
}
```

In addition to checking for equality, if our check fails we make sure to output what was expected and what we actually got. This is just a nicety and helps debugging.
