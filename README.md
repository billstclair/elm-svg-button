The `Html.Button` is a nice thing, but it is often very small on the small screen. For interactive games, I prefer to draw my own buttons with SVG.

This library automates the button part of an SVG button, so you can focus on its size and appearance. It works in standard computer browsers, with a mouse, or portable browsers, with touch. It supports buttons that auto-repeat as long as the mouse or finger is held down, and on buttons that fire once each time they're clicked/tapped.

The [`example`](https://github.com/billstclair/elm-svg-button/tree/master/example) directory contains a working, elm-reactor-friendly, example.

To make a simple, rectangular, click-once button, with a two-pixel wide, black border...

As one of your Msg options:

    type Msg
      = ...
      | ButtonMsg Svg.Button.Msg
      ...
    
In your model:

    button : Svg.Button.Button
    
In your init function:

    let size =
        (width, height)
    in
    { ...
    , button = Svg.Button.simpleButton size
    , ...
    }
    
In your update function:

    case msg of
        ...
        ButtonMsg m ->
            let (isClick, button, cmd) =
                    Svg.Button.update m model.button
                mdl =
                    if isClick then
                        processClick model
                    else
                        model
            in
            { mdl | button = button } ! cmd
        ...

Define the button's content:

    buttonContent : Svg.Button.Content
    buttonContent =
        Svg.Button.TextContent "Press Me"

In your view function:

    Svg [...]
        [ ...
        , Svg.Button.render (x, y) buttonContent ButtonMsg model.button
        ...
        ]

Bill St. Clair<br/>
20 March, 2018

