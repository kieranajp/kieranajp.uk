+++
date = "2016-07-21T23:08:17+02:00"
draft = "true"
strap = "It's possible to write a lot of tests without testing anything useful at all. Don't."
title = "Writing Tests is Easy, Actually Testing Things is Hard"
+++

Having tests in your software, especially in larger or more critical projects, is a Good Thing™. When modifying functionality or even just performing a refactor, getting red in your test suite helps you understand the scope of your changes, and can often help prevent bugs being introduced elsewhere in the software.

Except when you don't get red; shit's just broken and you're none the wiser.

I'm not talking about missing test coverage - there are a number of other mistakes that can lead to this, and ultimately to bugs in production. And - spoiler alert - I think that 100% code coverage is an unachievable goal. (More on that story later).

![image](bbc.jpg "More on that story later")

The other side of this coin is having an overly pedantic test suite. Sure, you've got "the coverage", but if every little change you make to your code breaks a dozen tests then you lose the ability to iterate quickly and actually ship code. Actual bugs get lost in the noise of inconsequentially failing tests - a "boy who cried wolf" scenario.

There's a few things you can think of while building you application and its test suite, however, to help avoid these problems.


## Test realistic inputs

This is the most common mistake I see in test design. When creating a test, it's common to create a class and provide dummy data to it. I work in procurement, so let's take a delivery to a fulfilment center as an example (shoutout #team-pro!):

```php
class Delivery
{
    public function __construct(DeliveryDate $arrivalDate, Price $price, array $items)
    {
       // ...
    }
}

class DeliveryTest extends \PHPUnit_Framework_Test_Case
{
    public function testDeliveryIsCreatedSuccessfully()
    {
        $delivery = new Delivery(
            new DeliveryDate(new \DateTimeImmutable('now')),
            new Price(1.0, Currency::fromString('EUR')),
            []
        );

        $this->assertInstanceOf(Delivery::class, $delivery);
    }
}
```

However, realistically a delivery isn't going to be delivered precisely now - it'll likely not have a precise time at all. It's not likely to have a price of exactly €1, and it's certainly not going to have no items.

Corners were cut. Mistakes were made.

!["Mistakes were made"]()

Choose realistic values to test with, and your tests will be more likely to match what happens in normal use of your application. Better yet, choose _random_ values to test with. 

### Test for failure!

I think this may be the thing I see missed out most in test suites, especially when test-driven design isn't used: tests that expect things to break. Taking our `Delivery` example from above, in a real application I would expect to see a test like this:

```php
public function testDeliveryDateValidation()
{
    $this->expectException(InvalidDeliveryDateException::class);

    new Delivery(
        new DeliveryDate(new \DateTimeImmutable('-2 days')),
        new Price(mt_rand(0, mt_getrandmax()) / 100, Currency::fromString('EUR')),
        []
    );
}
```

In this case, the values of `Price` and the `items` array don't matter as the validation should fail and throw an exception before the `Delivery` object is created properly. After all, a truck can't travel back in time and be delivered in the past.

Think very carefully about what would constitute an invalid state in an object in your domain, and make sure you don't allow such a state to be created. For example, a `Price` should not be negative, and this `items` array being empty is probably invalid. Having tests to ensure you've covered these scenarios is a critical safety net to prevent nasty bugs and invalid data being stored in your database. Believe me: you do not want invalid data stored in your database.

### 100% code coverage is a fallacy

Consider the tests you'd write for the following methods:

```php
class Delivery
{
    // ...

    public function getPrice() : Price
    {
        return $this->price;
    }

    public function setPrice(Price $price) : Delivery
    {
        $this->price = $price;

        return $this;
    }
}
```

Seriously, as far as my code coverage report goes, I'm quite happy for methods such as these to stay red. PHP - especially with the type hints - is dealing with everything for us, and `Price` should have its own tests and validation to ensure it's a valid value object.

"100% code coverage" means you've tested the pointless things like getters and setters; not a crime in itself, but possibly a "bad test smell". More importantly, however, "100% code coverage" is honestly unattainable.

With code as with language, context is king. While you may test every line of code, realistically there is absolutely no way you'll ever test every context, every _scenario_ that may occur in your application. Testing every line of code for one or two scenarios doesn't even get you 1% of the way there.

Bugs will happen, and when they do, after reproducing your first instinct should be to write a test that exhibits the bug state. Whether that's a unit test or a behavioural test with something like [Behat]() is immaterial; the fact is that now you have that scenario covered, and you can guard against a regression in future.

Anecdotally, I've had an interesting experience in training a helpdesk team to deliver bug reports to me in story format. These stories can then be immediately run as a Behat test (with some minimal tweaking, granted), which not only makes reproducing the error much easier, but gives you the test for free.

## My pet peeve: "spellchecker" tests

Mocking is a grand thing, and without it, proper unit tests are very hard to achieve (hush, all you fancy [monkey patchers]()!). But something that really drives me up the wall is _over-mocking_. There are two code smells for this: overuse of `Prophecy\Argument` (or similar, depending on your mock framework), and tests without assertions or regard for a method's return value.

Luckily, I can show both in a single example:

```php
class Delivery
{
    const ALLOWED_DELIVERY_RANGE_IN_HOURS = 4;

    public function getExpectedLatestArrivalTime()
    {
        $time = $this->arrivalDate->getTime();

        return $time->addHours(self::ALLOWED_DELIVERY_RANGE_IN_HOURS);
    }
}


class DeliveryTest extends \PHPUnit_Framework_Test_Case
{
    public function testLatestArrivalTime()
    {
        $time = $this->prophesize(DeliveryTime::class);
        $time->addHours(Prophecy\Argument::type('int'))->shouldBeCalled();

        $arrivalDate = $this->prophesize(DeliveryDate::class);
        $arrivalDate->getTime()->shouldBeCalled()->willReturn($time->reveal());

        (new Delivery(
            $arrivalDate,
            new Price(1.0, Currency::fromString('EUR')),
            []
        ))->getExpectedLatestArrivalTime();
    }
}
```

_What is even being tested here?_ 😠 All this test is checking for is that certain methods are being run - it's not making any checks of input or output.

Firstly, in a lot of cases, unless there's a queue or database interaction going on or you're calling a [God class](), mocking may be completely unnecessary. Yes, you might not be testing an individual method anymore, but you're still testing a discrete unit of code.

But let's assume that in this case, for whatever reason, `DeliveryDate` needs to be mocked. We can still write a far better test than this by again, actually testing for realistic values. We also shouldn't ignore the return value in our tests. So our test becomes something like:

```php
class DeliveryTest extends \PHPUnit_Framework_Test_Case
{
    public function testLatestArrivalTime()
    {
        $arrivalDate = $this->prophesize(DeliveryDate::class);
        $arrivalDate->getTime()->shouldBeCalled()->willReturn(new DeliveryTime('14:00'));

        $time = (new Delivery(
            $arrivalDate,
            new Price(1.0, Currency::fromString('EUR')),
            []
        ))->getExpectedLatestArrivalTime();

        $this->assertEquals(new DeliveryTime('18:00'), $time);
    }
}
```

Much better for my blood pressure! We now have a test that isn't mocking _everything_, which means that it's actually testing some of `DeliveryTime` as well. Maybe it's not testing a single unit anymore, but it's not a spellchecker test! We provide an input - here '14:00' - and expect an output ('18:00'). No more use of `Argument`! Bonus points if you use a [DataProvider]() or some element of randomness to test more times, and ensure your code is correct in more scenarios, not just this neat and tidy one.

## Go forth and test!

It's worth checking your existing test suites for signs of the problems I've outlined above. Having a test suite that checks realistic, random values - and doesn't just ignore values by being a spellchecker - is a crucial part of being able to maintain and extend software. The minute you start to exhibit a bug that should have been caught by tests but wasn't because of the wrong values, or because of over-mocking, you start to mistrust your test suite. And that's a Bad Thing. A test suite you don't trust can be as bad as no tests at all.

!["A team that trusts is a team that triumphs!"]()
