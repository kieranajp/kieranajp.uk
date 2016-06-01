+++
date = "2015-08-08T19:41:52+01:00"
title = "A devenv that doesn't suck"
strap = "An open-source hack to create a zero-config, multi-site development environment."
+++


You shouldn't be using MAMP. Or XAMPP, or WAMP. Or installing Ruby, Node.JS, or Python on your computer to develop sites with.

In fact, you should be able to develop without installing any sort of runtime on your machine at all. That's why I've worked on [this Vagrant machine hack](https://github.com/kieranajp/ansible) to make life easier for setting up development environments.

> Even with Docker and all it's shininess just round the corner, I stand behind this as a great solution to managing multiple small sites with zero-config. Read on!

I'm not going to wax poetic about _why_ - [that's](https://www.vagrantup.com/docs/why-vagrant/) [been](http://gratzc.github.io/it-works-on-my-machine-chef-vagrant/#/automate-all-the-things-begin) [done](http://www.jedi.be/blog/2011/09/06/vagrant-devopsdays-mountainview/). In a nutshell, however you're running your (especially interpreted-language) applications on your own MacBook or Windows PC is _not_ the same as how they'll be run on the server. The operating system is likely different, the available libraries and versions of these are different. Your colleagues may well be running a totally different setup again - cue the cries of _"well, it works on **my** machine"_!

No, what you want to do is _virtualise_ - run your development environment locally on a virtual machine with the same operating system and software as your end server.

This is a solved problem with Vagrant and providers such as [Ansible](https://www.ansible.com/) and [Chef](https://www.chef.io/); what's harder is having as nice of a development experience as tools like MAMP Pro give us when it comes to spinning up a new website. With MAMP Pro, it's pretty much turnkey; with Vagrant or even Vagrant-based setups like [Laravel Homestead](https://laravel.com/docs/5.2/homestead), there's some config to do up-front - at the very least changing your `/etc/hosts` file and setting up a new site in Apache or Nginx.

That's a very long-winded segway into [my hacky little project](https://github.com/kieranajp/ansible). This is a Vagrant box and an Ansible provisioner that sets up a PHP5 / Apache VM to be (hopefully) autonomous - by following a folder structure convention and doing some magic with Apache's [`VirtualDocumentRoot`](https://httpd.apache.org/docs/current/vhosts/mass.html), we can easily spin up a new (though somewhat opinionated) PHP website.

The crux of it is this: When you have the VM running, creating a folder with the name of your site (let's say `example`), and inside that a `public_html` folder (which will act as your document root) will set up a new website for you available at (in this case) `http://example.vg` with PHP and MySQL raring to go. No changes to your hostsfile, no editing YAML files (sorry Homestead!) - it's as simple as creating two folders.

To set this up, you'll need Vagrant and Virtualbox installed, and then you can clone down the repository and `vagrant up`. You'll also need to install `dnsmasq` - this provides the magic that prevents you from having to edit `/etc/hosts` by running a DNS server locally that sends all requests to `.vg` (for VaGrant) domains to your VM. After the initial setup, it's that simple - I and a couple of others have been running this without a hiccup for several months now. For bonus points, you can install the [Vagrant Manager](http://vagrantmanager.com) OS X menubar application, which is perfect for the terminal-allergic.

I'm hesitant to even call it an "open-source project" as most of it is instructions for how to set this up on your own computer (to automate this, you'd have to trust me with `sudo`, and you probably shouldn't do that!).

If you try it out, please let me know! And if you do run into any problems I'll be happy to take a look - just open an issue on the repository and I'll get back to you.

Enjoy!
