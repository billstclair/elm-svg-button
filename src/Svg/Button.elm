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


module Svg.Button exposing (Button, Msg, render, renderOutline, simpleButton, update)

import Svg exposing (Svg, rect)
import Svg.Attributes
    exposing
        ( fill
        , height
        , opacity
        , stroke
        , strokeOpacity
        , strokeWidth
        , width
        , x
        , y
        )
import Svg.Events exposing (onClick)


{-| Opaque internal message.
-}
type Msg
    = Click


{-| Button state.
-}
type Button msg
    = Button
        { size : ( Float, Float )
        , msgWrapper : Msg -> msg
        }


{-| Create a simple, rectanglar button.

It sends a `msg` when clicked or tapped.

The `view` function draws a two-pixel wide, black border around it. Your drawing function should leave room for that, or it will be overlaid.

-}
simpleButton : ( Float, Float ) -> (Msg -> msg) -> Button msg
simpleButton size wrapper =
    Button
        { size = size
        , msgWrapper = wrapper
        }


{-| Call this to process a message created by your wrapper.

The `Bool` in the return value is true if this message should be interpreted as a click on the button.

-}
update : Msg -> Button msg -> ( Bool, Button msg, Cmd msg )
update msg button =
    case msg of
        Click ->
            ( True, button, Cmd.none )


{-| Draw a button's transparent, mouse/touch-sensitive overlay.

You should call this AFTER drawing your button, so that the overlay is the last thing drawn. Otherwise, it may not get all the mouse/touch events.

-}
render : Button msg -> Svg msg
render (Button button) =
    let
        ( w, h ) =
            button.size

        ws =
            toString w

        hs =
            toString h
    in
    Svg.rect
        [ x "0"
        , y "0"
        , width ws
        , height hs
        , opacity "0"
        , onClick <| button.msgWrapper Click
        ]
        []


{-| Draw a button's border.

You should call this BEFORE drawing your button, so that its opaque body does not cover your beautiful drawing.

-}
renderOutline : Button msg -> Svg msg
renderOutline (Button button) =
    let
        ( w, h ) =
            button.size

        ws =
            toString (w - 2)

        hs =
            toString (h - 2)
    in
    Svg.rect
        [ x "1"
        , y "1"
        , width ws
        , height hs
        , stroke "black"
        , fill "white"
        , strokeWidth "2"
        , opacity "1"
        , strokeOpacity "1"
        ]
        []
