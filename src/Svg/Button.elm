----------------------------------------------------------------------
--
-- Button.elm
-- SVG Buttons
-- Copyright (c) 2018 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module Svg.Button exposing (Button, Msg, render, simpleButton, update)

import Svg exposing (Svg)


{-| Opaque internal message.
-}
type Msg
    = Nop


{-| Button state.
-}
type Button msg
    = Button
        { size : ( Float, Float )
        , msgWrapper : Msg -> msg
        }


{-| Create a simple, rectanglar button.

It will send a `msg` when clicked or tapped.

The `view` function will draw a two-pixel wide, black border around it. Your drawing function should leave room for that, or it will be overlaid.

-}
simpleButton : ( Float, Float ) -> (Msg -> msg) -> Button msg
simpleButton size wrapper =
    Button
        { size = size
        , msgWrapper = wrapper
        }


{-| Call this to repond to a message created by your wrapper.
-}
update : Msg -> Button msg -> ( Button msg, Cmd msg )
update msg button =
    button ! []


{-| Draw a button's border and transparent, mouse/touch-sensitive overlay.

You should call this AFTER drawing your button, so that the overlay is the last thing drawn. Otherwise, it may not get all the mouse/touch events.

-}
render : Button msg -> Svg msg
render button =
    Svg.g [] []
