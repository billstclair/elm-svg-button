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

    button : Svg.Button.Button Msg
    
In your init function:

    let size =
        (width, height)
    in
    { ...
    , button = Svg.Button.simpleButton size ButtonMsg
    , ...
    }
    
In your update function:

    case msg of
        ...
        ButtonMsg m ->
            let (button, cmd) =
                Svg.Button.update m model.button
            in
            { model | button = button } ! cmd
        ...

In your view function:

    Svg [...]
      [ g [ Svg.Attributes.x bx
          , Svg.Attributes.y by
          , Svg.Attributes.width bw
          , Svg.Attributes.height bh
          ]
          [ renderMyBeautifulButton model   -- Draw your button
          , Svg.Button.render model.button  -- Draw outline and transparent overlay
          ]
      ]

Bill St. Clair<br/>
20 March, 2018

