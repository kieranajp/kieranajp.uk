+++
date = "2015-10-05T00:30:25+01:00"
title = "Throwing ideas together with System.JS"
strap = "Getting started with a new JavaScript project without getting bogged down in boilerplate hell."
+++

A huge annoyance when starting a new JavaScript project today is in the bootstrap phase. Yes, it's still perfectly possible to do something like this:

```html
<script>
// ALL THE JAVASCRIPT!!!
</script>
```

But if you've ever had to work on a site of any decent size, you'll know that doing this without any organisation system quickly becomes unmaintainable, a mess of scrolling up and down forever to find the function you want to work with.

Task runners like Grunt and Gulp help with this problem, allowing us to break up our JavaScript into smaller files and adding a compile step to concatenate them. Throwing NPM and Browserify into the mix takes this a step further, allowing us to explicitly define dependencies and share state without writing everything to the global scope, the way we're used to doing in Node.js:

```js
var _ = require('underscore');
var Parser = require('./modules/parser');
```

These tools are fantastic; I use them daily and wholeheartedly recommend them. But there's a definite problem with them, and that's the amount of initial setup required to start something with them.

If I'm just going to start tinkering with a new project, not yet knowing if it's going to be fleshed out into a working thing yet or if it's not going to work out and be forever relegated to my `~/playground` folder, I don't want to spend time setting up Grunt and Browserify, answer a short questionnaire from `npm init`, and then another from `bower init`, and then pull in libraries from Bower, and then deal with the _awful_ structure of the `bower_components` folder... I'll be bored of the idea by then. Additionally, I want to write JS code the way I like: using a module system, through some sort of transpiler to let me use a superset of the language (be that ES6, CoffeeScript, JSX, or TypeScript) - that way I don't have to rewrite half the code later once I've decided to keep tinkering.

In short, I want the code niceties of having a compiler step, without the initial set-up cost.

The solution I've found is [SystemJS](https://github.com/systemjs/systemjs). From their website:

> [SystemJS is a] Universal dynamic module loader - loads ES6 modules, AMD, CommonJS and global scripts in the browser and NodeJS. Works with both Traceur and Babel.

What does this mean? Well, by using SystemJS I can write and load in JavaScript modules no matter how they're written: Node-style `require()`, RequireJS's / AMD's `define`, new ES6-style `import`, or plain old binding to global scope (`window.$`) - it doesn't matter. I can also _use_ any libraries or modules that have been written in any of these ways. SystemJS doesn't care.

Most importantly though, with SystemJS I can write literally half a dozen lines of boilerplate and then get down to building what I want to build.

> Before I get started, please note that this is __not__ remotely production-ready - this is just how I get stuck into hacking in the fastest possible way.

Let's create a new file, `index.html`, and drop a few old-fashioned `script` tags in there:

```html
<script src="//cdnjs.cloudflare.com/ajax/libs/systemjs/0.18.4/system.js">
</script>
<script>
    System.import('app.js');
</script>
```

Here, we're simply loading in SystemJS from a CDN, in the same way I'm sure you've loaded in jQuery a hundred times in the past. Then, we're telling it to load in our JavaScript from an `app.js` file - let's create that.

```js
var lemon = require('./lemon.js');
console.log(lemon());
```

And `lemon.js`?

```js
module.exports = function () {
    return '🍋';
};
```

Bam: we've now got essentially what Browserify gives us, with no initial set-up, manual compile step, or watcher to start up and then wait for. Just refresh and go.

We could start hacking away from here as-is, but as I said above, I'd prefer to write code using a transpiler. Again, this is super-simple with SystemJS. Let's add a snippet of config before we load in `app.js`:

```html
<script src="//cdnjs.cloudflare.com/ajax/libs/systemjs/0.18.4/system.js">
</script>
<script src="//cdnjs.cloudflare.com/ajax/libs/babel-core/5.8.25/browser.js">
</script>
<script>
    System.config({
        transpiler: 'babel',
        defaultJSExtensions: true,
    });
    System.import('app.js');
</script>
```

Let's break this down: First we've loaded in Babel (an ES6/JSX transpiler), again just by dropping a CDN link in there. Then, we've given SystemJS a config object telling it to use Babel, and also to automatically add a `.js` extension to module links (so `require('./lemon.js')` above could just become `require('./lemon')`). Finally, we're going to rewrite our JavaScript to use ES6 syntax, adding a new class for fun (`lemon.js` can stay as-is, though):

```js
/* app.js */
import lemon from './lemon';
import Banana from './banana';

console.log(lemon());
console.log((new Banana()).sayHi());
```

```js
/* banana.js */
export default class Banana {
    sayHi() {
        return '🍌';
    }
}
```

Now we can hack with all the niceties that ES6 brings to the table, as well! TypeScript compilation works in much the same way, and plugins exist to load in CoffeeScript and many other filetypes as well.

Did you notice, though, that we're mixing syntaxes here? SystemJS, being a "universal" module loader, simply doesn't care that we're using ES6's `import` to load in `lemon.js`, a CommonJS module. In the same way, we could just write an "old-fashioned" JavaScript file, that just binds to the global scope (like older versions of jQuery did, for example) and still be able to load them in as if they were modularised. Look:

```js
/* app.js */
import lemon from './lemon';
import Banana from './banana';
import pineapple from './pineapple';

console.log(lemon());
console.log((new Banana()).sayHi());
console.log(pineapple());
```

```js
/* pineapple.js */
function pineapple() {
    return '🍍';
}
```

This allows you to use pretty much any library you want to, without worrying about how to pull it in and then how to list it as a dependency of a module, and then having JSHint complain because you're assuming existence of a global variable.

And just to wrap up, because this is getting long, this is how you could load in an external module, if you did need to start using libraries:

```html
<script src="//cdnjs.cloudflare.com/ajax/libs/systemjs/0.18.4/system.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/babel-core/5.8.25/browser.js"></script>
<script>
    System.config({
        transpiler: 'babel',
        defaultJSExtensions: true,
        map: {
            'lodash': '//cdnjs.cloudflare.com/ajax/libs/lodash.js/3.10.1/lodash.min.js'
        }
    });

    System.import('app.js');
</script>
```

This `map` object in SystemJS's config defines where to look for a particular import statement. So now, we can simply use Lodash as if it were an ES6 module:

```js
import _ from 'lodash';
console.log(_.VERSION);
```

And SystemJS would know to download Lodash from the CDN there and then.

As you can probably tell, I'm excited about this near-frictionless way of prototyping a client-side idea, and by being able to use a module system this early on in a project I'm finding myself naturally writing smaller, simpler components - better code - and thus getting an application to a useable state much more quickly than by doing things the old-fashioned way. Between this and new ES6 features, JavaScript just became a whole lot more fun!

