---
title: "Starting out with test-driven development (Part 2: Writing code)"
categories: [programming]
tags: [c#, tdd]
---

## Starting out with test-driven development (Part 2: Writing code) *Oct 23, 2017*

1. [Part 1: Create a test runner](/posts/tdd-part-1.html)
2. [Part 2: Writing code](/posts/tdd-part-2.html)

**This is a two part series.  If you haven’t read the first post, I recommend you read it first.**

Now that we have a test runner, some helpful attributes, and an assert class, we can get into the guts of TDD: how to actually write code.  Remember, TDD is a methodology for writing code that relies on **Red-Green-Refactor**.  We’re going to first write a test that will fail.  We write this test because we know what we want our code to do, but we don’t know yet how we’re going to get there.  Next, we’ll write the actual code of our application and try to get the test to pass.  Lastly, we refactor and clean everything up.  After that’s done, we do it all again, until we’ve written our application.

### Naming conventions

It’s important to have a standard of naming your tests.  The number one quality of good code is the ease of future developers to pick it up and keep working on it.  If your tests are poorly named, this is going to cause a lot of pain for those future developers.  I like to stick to [Roy Osherove’s naming standards](http://osherove.com/blog/2005/4/3/naming-standards-for-unit-tests.html) when writing my tests.  You’ll also probably want to check out more of Osherove’s articles and videos (there are some great ones on YouTube) as you continue your dive into testing, he’s a great resource.

I’m sure you’ll read the article I’ve linked later, but just to keep us moving along, here is the standard set by Osherove:

> ```UnitOfWork_StateUnderTest_ExpectedBehavior```

### The PyramidTests class

As defined in the last post, we’re working on an application that will print out a pyramid of the given height when given an integer that represents the number of stories.

So, let’s start out with the simplest possible use case: a one story pyramid.  We want to have some method that when given the integer 1, we output `/\`.

How are we going to accomplish this?  We know we’ll have some object that builds the pyramid.  You might do it differently, but I’ve decided to have a `Pyramid` class that exposes a `Build` method that takes one integer, the number of stories, as a parameter.  Now that we know the type of class we want to use and the functionality that we want to expose, but currently do not, we can start writing the test.

```csharp
public class PyramidTests
{
    private Pyramid _Pyramid;

    public PyramidTests()
    {
        _Pyramid = new Pyramid();
    }

    [Test]
    public void Pyramid_GivenBuildInputOf1_Outputs1StoryPyramid()
    {
        var result = _Pyramid.Build(1);
        Assert.IsEqual(@"/\", result);
    }
}
```

A couple of things stand out here.  First off, you’ll notice that we’re instantiating our Pyramid class in the constructor of our test class.  We could just as easily instantiate this class in each test method, but we don’t want to repeat ourselves.  Secondly, you will notice that we’re using out `[Test]` attribute to let the `PyramidTestRunner` know that we will want to invoke this method as a test.  If we had decorated the method with `[Ignore]`, this particular test would be skipped.  Last, we clearly name our test using the standard defined above.  It is obvious to the future developer that this is testing the `Build` functionality in the `Pyramid` class.

In the actual meat (very expensive meat, that’s why there’s so little) of the test, we call the `Build` method with the number of stories we want to build and then assert that the method returns a result that is equal to `/\`.

### The first failing test

In a dynamic language we would now run the test and see that we have not implemented the `Pyramid` class yet and the test runner would return a valuable stack trace for us. However, since C# is a statically typed language, the compiler will not even build the project until the needed class exists. Let’s add that class now.

```csharp
public class Pyramid
{
    public string Build(int size)
    {
        return string.Empty;
    }
}
```

We’ll that looks pretty empty. Regardless, we’re just trying to get the project to build at this point, which is should.

While working on this I’ve been running without the debugger, just because I feel like I can make progress quicker in this small project. After running the project, you’ll see the following in the console window, followed by a stack trace.

```
Expected
/\


Actual
```

This makes perfect sense. Our `Build` method returns an empty string, as shown by the “actual” section of our output. This is the **Red** section of our process. The code builds and runs, but the tests fail. The next step is getting this first test to pass.

### Fixing it and continuing on

If you remember from the first post, if we’re going by Uncle Bob’s three laws of TDD, we’re only allowed to write the minimum amount of code to get this failing test to pass.

```csharp
public string Build(int size)
{
    return @"/\";
}
```

That probably looks pretty stupid to you, but if you run it you’ll see `Tests succeeded` in the console window. At this point, that’s all we care about. Our program works completely fine for the test case we’ve provided it. But, we know this isn’t all our program is going to need to do, we have tall pyramids we need to be building and 1 story isn’t going to cut it. Let’s write a test case to make sure this logic is going to work when we need to build something taller. Let’s try this program out with an input of 2.

```csharp
[Test]
public void Pyramid_GivenBuildInputOf2_Outputs2StoryPyramid()
{
    var result = _Pyramid.Build(2);
    var expected =
@" /\
/  \";
    Assert.IsEqual(expected, result);
}
```

We write up our new test case, run it, and everything breaks down.

```
Expected
 /\
/  \


Actual
/\
```

Of course it’s going to break down, we hard coded a string to output a one story pyramid. We don’t even use the `size` parameter on the `Build` method.

It’s at this point you’ll start to see some of the reasons behind this slow, methodical, process of writing code. We know for a fact that a one story pyramid can currently be build. We have that to fall back on. Anything we write from this point on must not break the first test. Yeah, we could go hard code in a two story pyramid, but then only one of our test (namely the second) will pass. We need to figure out a way to get both of the tests to pass, which is done below.

```csharp
public string Build(int size)
{
    var pyramid = new StringBuilder();
    for (var i = 0; i < size; i++)
    {
        pyramid.Append(' ', size - i - 1);
        pyramid.Append('/');
        pyramid.Append(' ', i * 2);
        pyramid.Append('\\');
        f (i != size - 1) pyramid.Append("\r\n");
    }

    return pyramid.ToString();
}
```

For our new `Build` logic, we use a `for loop` and iterate for the size. Since there will exist times a story of the pyramid will need to be offset, we first append the number of spaces needed for the offset. The size of this offset will always be one more than the story below’s offset. Next, we add the left side of the pyramid wall `/`. Depending on the story that we are building, we may need a greater width between the left and right walls. This width is equal to the current story (assume counting from the top, down) multiplied by two. We then append the right wall `\`. Lastly, we need to make sure we have a line break after each story, excluding the very bottom of the pyramid.

After implementing the above code, we can run out tests again and will be delighted to find that all tests are now passing.  For good measure, I would add at least one more test to make sure a pyramid of three stories can be successfully built.

### Wrapping up

Hopefully these two posts have helped you understand TDD a little more.  The reasoning behind it, why we do it, and how it works.  I would also like to point out that you should **never** write your own test runner.  There are many out there on the market that do a far superior job and are easy to get up and running with.  The test runner written here was merely an example used for educational purposes.

All code for this program can be found on my [GitHub](http://osherove.com/blog/2005/4/3/naming-standards-for-unit-tests.html).  Leave any comments, questions, or suggestions below.  I’m always trying to do better so if something stands out, don’t feel bad calling me out on it.