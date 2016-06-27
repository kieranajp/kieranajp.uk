+++
date = "2015-02-09T15:31:52+00:00"
title = "Using Promises in existing jQuery projects"
strap = "It's possible to make use of Promises even if you have a legacy jQuery application - here's how."
+++


The traditional way of doing async in JS was with callbacks:

```js
function doSomethingThatTakesAWhile(callback) {
    // blah blah blah doing some work that will take a few seconds

    // We'll simulate this taking a while with the timeout
    setTimeout(function () {
        callback('done');
    }, 5000)
}

// Then use the function with:
doSomethingThatTakesAWhile(function (val) {
    alert(val); // 'done'... eventually
});
```

This falls down badly when you need a lot of things done, each of which takes a while:

```js
function doSomething(callback) {
    setTimeout(function () {
        callback();
    }, 5000)
}

function doSomethingElse(callback) {
    setTimeout(function () {
        callback();
    }, 3000);
}

doSomething(
    doSomethingElse(
        function () {
            alert('done');
            // this is nicknamed the pyramid of doom because of all the nesting you end up with
        }
    )
);
```

There are some major problems here:
- Code is difficult to read / refactor
- Tasks have to happen in sequence
- Handling errors is difficult - what happens if one task fails? You need a ton of try/catch handlers.

To get round this we can use "promises". Promises are just functions that don't return immediately. Instead, they return an object of type `promise` and then later, they return a *second* time with their actual return value.

So basically, when you call the function, it says "I promise to run and I'll let you know what my result is in a sec"

Using jQuery's promises, you could do something like this:

```js
function doSomething() {
    var d = $.Deferred();
    return setTimeout(function () {
        if (errorOccurred) {
            return d.reject();
        }

        return d.resolve();
    }, 5000)

    return d.promise(); // This is the Promise object that's returned immediately, basically saying "I will get back to you with the real return value soon"
}

function doSomethingElse(callback) {
    var d = $.Deferred();
    return setTimeout(function () {
        if (errorOccurred) {
            return d.reject();
        }

        return d.resolve();
    }, 3000)

    return d.promise();
}

$.when(
    doSomething(),
    doSomethingElse()
).then(function (something, somethingElse) {
    // here we have the return values passed as function args, if we need them
    alert('done'); 
}).catch(function (error) {
    console.error(error); // if any error at all occurred, we can deal here
});
```

Not only is this much neater code than callback hell, but it will run in 5 seconds rather than 8 seconds (5000 + 3000ms) because `doSomething()` and `doSomethingElse()` are run in parallel. We can also catch any errors with our one error handler on the end.
