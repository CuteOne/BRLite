# Bad Rotations Light, or BRLite for short.

## First and foremost, Licensing.  

BRLite is not traditional open source software.  It is licensed under the AGPLv3 License with a Common Clause that specifically prohibts this source code, or any derived work of this body of code from being used in any commercial sense.  i.e. you vibe coders that think you'll make it rich by selling this code can't.  The license DOES NOT preclude you from creating rotation elements that are 100% your own and selling those as they are not part of this body of work.  

## Secondly, Risk

Using this software involves a level of risk to your digital assets.  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS". (See License File) It is 100% developed as a learning exercise and, really, should never be used in a live environment.  Get yourself some TrinityCore action and use it there :)

## Supported Tools

This software currently requires NilName as it's the only software of that nature I currently have available to me.  It should work with any other tool providing that the tool has the ability to support an Object Manager, JSON File reading, general unlocking, and Click-To-Move functionality.  If you really want your tool wired up feel free to contribute, or message me.

## Required Libraries

The current full build of BadRotations requires a fairly old DieselLib for UI development.  This library is not maintained and as such has been manually patched progressively throughout the years.  It's not very nice to play with when it comes to the various versions out there.  As such I have decided to utilize a different UI library named AbstractFramework.  It is available for all versions of retail from 11.1.0 onward, and all flavors of retail such as classic, mop, etc.  You must install this library yourself -- it's not included here.  BRLite will ensure it's loaded and notify you if it can't find the library.  

***NOTE: Make sure you install the Abstract Framework for your specific Client Version: ***  
[Abstract Framework UI Library](https://www.curseforge.com/wow/addons/abstract-framework/files/all)

All of the other libraries are included in this package, and adhere to the license of the original creators. This includes LibDataBroker-1.1, LibDBIncon-1.0, and LibStub.

# What is BRLite?

BRLite is simply a light-weight redeveloped version of the traditional BadRotations without a lot of the overhead.  It is designed to do one thing only, provide you with combat rotations.  Well it does a touch more than that but we'll get to that in a minute.

## Core Development principals

    - Only the minimal of items will be tracked.  If we can determine something dynamically using standard API we try to do so.  We try to avoid creating large tables that require regular iteration and use CPU cycles.  let the standard API call into the game's engine do that as it's much faster.  An example of this is how we track buffs. Yes there's a table made in the Player object but it's just a table of what buffs we are looking for and associated helper functions.  When we go to check if a buff is up we don't rely on cached info and just call the API.  Hopefully this will reduce memory and CPU load requirements over the previous version that cached everything.
  
    - Only Combat Rotation and Related features will be supported.  The only exception here is a fishing module I threw in because, well, you know, fishing.
    - No Heal-bot stuff.  Once this code base stabilizes I'll probably work on a Healing specific version but the level of crap you have to track for a good heal bot is out-of-control.
    - Code must support ALL versions of WOW from 11.1.0 onward. To do this you'll notice that Spells, Auras, and Talents are defined inside of the rotation (Or not, as Cata/Mop don't have the same Talent stuff).  Where there are API changes that the bot itself uses we'll proxy that out by version.  Each rotation will have a Minimum and Maximum TOC version that it supports.  So yes, you can run this on your private 11.1.5 server with one rotation, and use the same code base to load it up under Retail MOP. It would just be a different rotation.
    - Intellisense.  All core objects have Intellisense notations where possible.  This helps all you vibe coders create rotations.
    - One core object to rule them all.  the BR object is the root object.  All other components, like say logging, are referenced there.  The code base is so small compared to BR that doing  ```local log = br.Logging``` seemed so much easier than using a module loader, and we don't really have dynamically loaded modules here.
   

# Installing

after you install NN or your tool of choice place this code inside of the 'Scripts' directory in a directory called '***BRLite***'.  This is really important.  These unlockers require a bootstrap and our bootstrap needs to know where to go to find the source code.

Once you've put that there then either copy or create a symbolic link to the specific unloader into the scripts file.  For example you could do this inside of an Administrator Powershell window:

```
PS D:\WOW\NN_BRLite\scripts> New-Item -ItemType SymbolicLink -Path _BRLiteLoader.lua -Target ./BRLite/unlocker/_BRLiteLoader_Nn.lua
```

then when you pull newer versions of the source code you'll not need to worry about updating the bootstrapper; it's symbolically linked and just a reference to the sources file.

## Do you want a step by step? ugh.. ok.

    1. Install NN or whatever, following all the instructions for that tool.  I can't help you there.
    2. Once installed open a PowerShell script as administrator (You'll need to learn to do this anyway, most unlockers require command line admin access)
    3. cd into the Scripts Directory
    4. git clone repository BRLite (this will download source code into folder named BRLite)
    5. Run the Symbolic Link command shown above.
    6. Start NN (or your unlocker)  I really hoped you renamed it but TBH Big Brother can see through that crap now.
    7. Look in chat dialog for anthing amiss.
   

# The Rotation, Broken Down

I'm going to go through a rotation file so you know what parts are what. Hopefully YOU can contribute by building rotations.  Rotations are the life-blood of a bot and they really do take a while to build. Mostly because testing requires you to level through a character and that process isn't just a few hours, sometimes it's DAYS of working on getting a character's rotation where you want it. And that's nothing compared to tweaking a rotation up enough to handle Heroic, then M+ crap.  Ugh.

So 



