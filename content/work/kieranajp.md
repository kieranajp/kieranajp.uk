+++
date  = "2016-05-26T23:49:51+02:00"
draft = true
title = "kieranajp.uk"
strap = "Autopsy of the site you're reading right now!"
site  = "https://kieranajp.uk"
link_text = "You're looking at the finished product!"
+++

Having had the same website - with very outdated information, a five-year old design, and a ridiculously out-of-date version of my CV available on it, it had become long past time for me to get myself a replacement, from scratch.

I actually went through two iterations to get to the site you're reading right now. The first was an all-singing, all-dancing, flavour-of-the-month website with React.js and react-router, css-modules, isomorphism, and all that good stuff. In the end, however, I decided to pare all that back, temporarily, to build a more simple version using the [Hugo static site builder](https://gohugo.io) to allow me to iterate more quickly and, importantly, deploy more easily.

The first approach was perhaps me jumping the gun a little and overengineering the solution. However I'm not a fan of throwing the baby out with the bathwater, so a lot of it lives on in the Hugo site, in the learnings I took from the project, and of course in the [annals of Git](https://github.com/kieranajp/websitev3), ready to be applied as a progressive enhancement in the future.

## The New Shiny

I enjoy working on the front-end (when I'm not fighting with `npm`), and I'm a huge fan of React. From a performance point of view and from the end user's point of view, I don't believe React really adds much over any other JavaScript implementation. However its developer experience is second to none when it comes to JavaScript. 

It's becoming widely regarded in frontend-land to break down everything into smaller and smaller components, whether you're working with Vue, Knockout, Polymer, or (god forbid) Angular; but React I find does the best job in _encouraging_ the developer to think in terms of tiny, reusable components. 

It's this encouragement that got me to start breaking down my initial wireframes down into distinct web components. I knew I needed a basic header and footer with links, and I knew I wanted to have distinct blog posts and case studies; I also knew that they wouldn't make the initial release, but I wanted to have them designed and component-ified anyway. 