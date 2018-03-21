This directory contains an example of using the `Svg.Button` module.

# Running the example

You can run it with `elm reactor` from the main `elm-svg-button` directory (not this `example` directory):

    $ cd .../elm-svg-button
    $ elm reactor
    
Then aim your browser at http://localhost:8000/example/Example.elm.

The example displays a "Count", and has two buttons, "Repeating Increment" and "Decrement". The "Repeating Increment" button will increment the count when you press it, and then, after a 0.5 second delay, increment it again every 0.1 seconds. The "Decrement" button will decrement the count once each time you click it.

The example will work in a touch screen browser, but you'll need to start `elm reactor` differently:

    $ elm reactor -a 0.0.0.0

Then you can aim your mobile device's browser at http://n.n.n.n:8000/example/Example.elm, where `n.n.n.n` is your computer's IP address on your local network (from e.g. `ifconfig en0` in MacOS, `ip addr` in Linux, or some control panel in Windows).

# Coding repeating buttons

The top-level [`README`](../) shows how to code a non-repeating button. Repeating buttons take a little more work, since they have changing state that you need to store in your `Model`, and you need to subscribe to `Time` updates.



