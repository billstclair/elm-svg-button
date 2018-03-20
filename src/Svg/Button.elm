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


module Svg.Button
    exposing
        ( Button
        , Content(..)
        , Location
        , Msg
        , MsgWrapper
        , render
        , renderBorder
        , renderOverlay
        , simpleButton
        , update
        )

import Svg exposing (Svg, g, rect)
import Svg.Attributes
    exposing
        ( alignmentBaseline
        , fill
        , fontSize
        , height
        , opacity
        , stroke
        , strokeOpacity
        , strokeWidth
        , textAnchor
        , width
        , x
        , y
        )
import Svg.Events exposing (onClick)


{-| Opaque internal message.
-}
type Msg
    = Click


type alias MsgWrapper msg =
    Msg -> msg


type Content msg
    = TextContent String
    | SvgContent (Svg msg)


type alias Location =
    ( Float, Float )


{-| Button state.
-}
type Button
    = Button
        { size : Location
        }


{-| Create a simple, rectanglar button.

It sends a `msg` when clicked or tapped.

The `view` function draws a two-pixel wide, black border around it. Your drawing function should leave room for that, or it will be overlaid.

-}
simpleButton : ( Float, Float ) -> Button
simpleButton size =
    Button
        { size = size
        }


{-| Call this to process a message created by your wrapper.

The `Bool` in the return value is true if this message should be interpreted as a click on the button.

-}
update : Msg -> Button -> ( Bool, Button, Cmd msg )
update msg button =
    case msg of
        Click ->
            ( True, button, Cmd.none )


{-| Render a button's outline, your content, and the mouse-sensitive overlay.

You will usually call this, instead of renderOutline and renderOverlay.

-}
render : Location -> Content msg -> MsgWrapper msg -> Button -> Svg msg
render ( xf, yf ) content wrapper button =
    case button of
        Button but ->
            let
                ( xs, ys ) =
                    ( toString xf, toString yf )

                ( wf, hf ) =
                    but.size

                ( ws, hs ) =
                    ( toString wf, toString hf )
            in
            g
                [ x xs
                , y ys
                , width ws
                , height hs
                ]
                [ renderBorder button
                , renderContent content button
                , renderOverlay wrapper button
                ]


{-| Draw a button's transparent, mouse/touch-sensitive overlay.

You should call this AFTER drawing your button, so that the overlay is the last thing drawn. Otherwise, it may not get all the mouse/touch events.

-}
renderOverlay : MsgWrapper msg -> Button -> Svg msg
renderOverlay wrapper (Button button) =
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
        , onClick <| wrapper Click
        ]
        []


{-| Draw a button's border.

You should call this BEFORE drawing your button, so that its opaque body does not cover your beautiful drawing.

-}
renderBorder : Button -> Svg msg
renderBorder (Button button) =
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


renderContent : Content msg -> Button -> Svg msg
renderContent content (Button button) =
    g []
        [ let
            ( xf, yf ) =
                button.size
          in
          case content of
            TextContent string ->
                Svg.text_
                    [ fill "black"
                    , fontSize <| toString (yf / 2)
                    , x <| toString (xf / 2)
                    , y <| toString (yf / 2)
                    , textAnchor "middle"
                    , alignmentBaseline "middle"
                    ]
                    [ Svg.text string ]

            SvgContent svg ->
                svg
        ]
