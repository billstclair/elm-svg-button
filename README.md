[billstclair/elm-svg-button package](http://package.elm-lang.org/packages/billstclair/elm-svg-button/latest) at elm-lang.org

The `Html.Button` is a nice thing, but it is often very small on the small screen. For interactive games, I prefer to draw my own buttons with SVG.

This library automates the button part of an SVG button, so you can focus on its size and appearance. It works in standard computer browsers, with a mouse, or portable browsers, with touch. It supports buttons that auto-repeat as long as the mouse or finger is held down, and buttons that fire once each time they're clicked/tapped.

The [`example`](https://github.com/billstclair/elm-svg-button/tree/master/example) directory contains a working, elm-reactor-friendly, example.

So far, the library supports one basic button appearance, a rectangle with a two-pixel wide black border. I intend to allow you to customize the border and button shape. If you need that, please let me know, so I can prioritize those changes.

A button has user state, which you usually use to encode what it does (for repeating buttons, it also needs to encode the button's identity). But you can put anything you need there, and read and update it as necesssary (with `Svg.Button.getState` and `Svg.Button.setState`).

    type Operation
        = Increment
        | Decrement

As one of your `Msg` options, you need a wrapper for the button messages:

    type Msg
      = ...
      | ButtonMsg (Svg.Button.Msg Msg Operation)
      ...
    
Your model needs to store repeating buttons, but not simple buttons, and your update function needs to update the model when it receives messages containing them. See the example for how to code a repeating button, and for how to use `Svg.Button.getState` to process a click. This README documents only simple buttons.
    
In your `update` function:

    case msg of
        ...
        ButtonMsg m ->
            let
                ( isClick, button, _ ) =
                    Svg.Button.update m

                operation =
                    Svg.Button.getState button
            in
            operate isClick operation model
        ...

Where `operate` would be a function you defined to actually do the operation.

Use `Svg.Button.Content` to define the button's appearance:

    pressMeContent : Svg.Button.Content
    pressMeContent =
        Svg.Button.TextContent "Press Me"

Define a simple increment button:

    incrementButton : Svg.Button.Button Operation
    incrementButton =
        Svg.Button.simpleButton (100, 50) Increment

In your `view` function:

    Svg [...]
        [ ...
        , Svg.Button.render
              (x, y)
              pressMeContent
              ButtonMsg
              incrementButton
        ...
        ]

Bill St. Clair<br/>
20 March, 2018

