Title: Dokuen 0.0.7, Now with Linux Support
Date:  2012-05-29 19:00:02
Id:    13b92
Tags:  Dokuen, Heroku

When I released [Dokuen](https://github.com/peterkeen/dokuen) [last week](/2012-05-20-dokuen-update.html) I had no idea it would get as much press as it did. I'm excited that so many people want to give it a shot. To that end, <strike>v0.0.6</strike>v0.0.7 has rudimentary Ubuntu support, along with revised Mac support. See below for the changes.

--fold--

Here's the list of changes:

### Process Management

The first version of Dokuen used a LaunchDaemon to start up an instance of `foreman` for each application. This was fine but didn't scale very far. This new version manages processes itself, using `foreman` more as a library. Each process becomes it's own daemon, launched by `dokuen boot`, `dokuen scale`, or `dokuen deploy`.

### Port Management

Dokuen will now manage your app's ports for you, so you don't have to worry about it. If you're not using a wildcard CNAME you'll need to put entries in your hosts file for each app.

### Revised Mac Install

Because there's no need for a custom LaunchDaemon per app, just one global one that launches off all of the application daemons. 

### Linux Support

I've included a rudimentary ubuntu upstart script. All it does is run `dokuen boot`, just like on Mac. If you're not using ubuntu, feel free to write up an init script and submit a pull request on github.

*Questions? Comments? Leave a comment below or [email me](mailto:pete@bugsplat.info). I'm also loitering in `#dokuen` on `freenode` if you feel like chatting.*
