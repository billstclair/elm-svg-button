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
        , disableSelection
        , render
        , renderBorder
        , renderOverlay
        , simpleButton
        , update
        )

import Svg exposing (Attribute, Svg, g, rect, text, text_)
import Svg.Attributes
    exposing
        ( alignmentBaseline
        , fill
        , fillOpacity
        , fontSize
        , height
        , opacity
        , pointerEvents
        , stroke
        , strokeOpacity
        , strokeWidth
        , style
        , textAnchor
        , width
        , x
        , y
        )
import Svg.Events exposing (onClick)


{-| Opaque internal message.
-}
type Msg
    = Click Button


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
update : Msg -> ( Bool, Button, Cmd msg )
update msg =
    case msg of
        Click button ->
            ( True, button, Cmd.none )


{-| Render a button's outline, your content, and the mouse-sensitive overlay.

Does this by sizing an SVG `g` element at the `Location` you pass and the size of the `Button`, and calling `renderBorder`, `renderContent`, and `renderOverlay` inside it.

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


{-| An attribute to disable mouse selection of an SVG element.

`renderContent` includes this.

From <https://www.webpagefx.com/blog/web-design/disable-text-selection/>. Thank you to Jacob Gube.

-}
disableSelection : Attribute msg
disableSelection =
    style <|
        -- Firefox
        "-moz-user-select: none;"
            -- Internet Explorer
            ++ "-ms-user-select: none;"
            -- KHTML browsers (e.g. Konqueror)
            ++ "-khtml-user-select: none;"
            -- Chrome, Safari, and Opera
            ++ "-webkit-user-select: none;"
            --  Disable Android and iOS callouts*
            ++ "-webkit-touch-callout: none;"


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
        , fillOpacity "1"
        , onClick <| wrapper (Click <| Button button)
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
    g [ disableSelection ]
        [ let
            ( xf, yf ) =
                button.size

            yfo2s =
                toString (yf / 2)

            xfo2s =
                toString (xf / 2)
          in
          case content of
            TextContent string ->
                text_
                    [ fill "black"
                    , fontSize yfo2s
                    , x xfo2s
                    , y yfo2s
                    , textAnchor "middle"
                    , alignmentBaseline "middle"
                    ]
                    [ text string ]

            SvgContent svg ->
                svg
        ]
