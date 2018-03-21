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
        , RepeatTime(..)
        , checkSubscription
        , disableSelection
        , getState
        , normalRepeatTime
        , render
        , renderBorder
        , renderOverlay
        , repeatingButton
        , setState
        , simpleButton
        , update
        )

import Debug exposing (log)
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
        , transform
        , width
        , x
        , y
        )
import Svg.Events exposing (onClick, onMouseDown, onMouseOut, onMouseOver, onMouseUp)
import Task
import Time exposing (Time)
import TouchEvents exposing (Touch, onTouchEnd, onTouchMove, onTouchStart)


{-| Opaque internal message.
-}
type Msg msg state
    = MouseDown (Button state) (MsgWrapper msg state)
    | MouseOut (Button state) (MsgWrapper msg state)
    | MouseUp (Button state) (MsgWrapper msg state)
    | TouchStart (Button state) (MsgWrapper msg state)
    | TouchEnd (Button state) (MsgWrapper msg state)
    | Repeat (Button state) (MsgWrapper msg state)
    | Subscribe Time (Button state) (MsgWrapper msg state)


getState : Button state -> state
getState (Button button) =
    button.state


setState : state -> Button state -> Button state
setState state (Button button) =
    Button
        { button | state = state }


type alias MsgWrapper msg state =
    Msg msg state -> msg


type Content msg
    = TextContent String
    | SvgContent (Svg msg)


type alias Location =
    ( Float, Float )


type alias Size =
    ( Float, Float )


{-| Button state.
-}
type Button state
    = Button
        { size : Size
        , repeatTime : RepeatTime
        , delay : Time
        , enabled : Bool
        , state : state
        , touchAware : Bool
        }


{-| Create a simple, rectanglar button.

It sends a `msg` when clicked or tapped.

The `view` function draws a two-pixel wide, black border around it. Your drawing function should leave room for that, or it will be overlaid.

-}
simpleButton : Size -> state -> Button state
simpleButton =
    repeatingButton NoRepeat


{-| First arg to `repeatingButton`.

`RepeatTimeWithInitialDelay initial subsequent`

-}
type RepeatTime
    = NoRepeat
    | RepeatTime Time
    | RepeatTimeWithInitialDelay Time Time


{-| Like `simpleButton`, but repeats the press periodically.
-}
repeatingButton : RepeatTime -> Size -> state -> Button state
repeatingButton repeatTime size state =
    Button
        { size = size
        , repeatTime = repeatTime
        , delay = 0
        , enabled = True
        , state = state
        , touchAware = False
        }


repeatDelays : RepeatTime -> ( Time, Time )
repeatDelays repeatTime =
    case repeatTime of
        NoRepeat ->
            ( 0, 0 )

        RepeatTime delay ->
            ( delay, delay )

        RepeatTimeWithInitialDelay delay nextDelay ->
            ( delay, nextDelay )


normalRepeatTime : RepeatTime
normalRepeatTime =
    RepeatTimeWithInitialDelay
        (500 * Time.millisecond)
        (100 * Time.millisecond)


{-| Call this to process a message created by your wrapper.

The `Bool` in the return value is true if this message should be interpreted as a click on the button.

-}
update : Msg msg state -> ( Bool, Button state, Cmd msg )
update msg =
    case log "msg" msg of
        Subscribe _ button _ ->
            ( False, button, Cmd.none )

        TouchStart button wrapper ->
            case button of
                Button but ->
                    let
                        ( initialDelay, delay ) =
                            repeatDelays but.repeatTime

                        button2 =
                            Button
                                { but
                                    | touchAware = True
                                    , enabled = True
                                    , delay = delay
                                }
                    in
                    ( initialDelay > 0
                    , button2
                    , repeatCmd initialDelay button2 wrapper
                    )

        MouseDown button wrapper ->
            case button of
                Button but ->
                    let
                        ( initialDelay, delay ) =
                            repeatDelays but.repeatTime

                        button2 =
                            Button
                                { but
                                    | enabled = True
                                    , delay = delay
                                }
                    in
                    ( initialDelay > 0 && not but.touchAware
                    , button2
                    , repeatCmd initialDelay button2 wrapper
                    )

        MouseOut button wrapper ->
            case button of
                Button but ->
                    let
                        button2 =
                            Button
                                { but
                                    | enabled = False
                                    , delay = 0
                                }
                    in
                    ( False
                    , button2
                    , repeatCmd 0 button2 wrapper
                    )

        TouchEnd button wrapper ->
            case button of
                Button but ->
                    let
                        button2 =
                            Button
                                { but
                                    | enabled = False
                                    , delay = 0
                                }
                    in
                    ( but.enabled && but.touchAware && but.delay <= 0
                    , button2
                    , repeatCmd 0 button2 wrapper
                    )

        MouseUp button wrapper ->
            case button of
                Button but ->
                    let
                        button2 =
                            Button
                                { but
                                    | enabled = False
                                    , delay = 0
                                }
                    in
                    ( but.enabled && not but.touchAware && but.delay <= 0
                    , button2
                    , repeatCmd 0 button2 wrapper
                    )

        Repeat button wrapper ->
            case button of
                Button but ->
                    ( True
                    , button
                    , repeatCmd but.delay button wrapper
                    )


repeatCmd : Time -> Button state -> MsgWrapper msg state -> Cmd msg
repeatCmd delay button wrapper =
    case button of
        Button but ->
            let
                task =
                    Task.succeed (Subscribe delay button wrapper)
            in
            Task.perform wrapper task


checkSubscription : Msg msg state -> Maybe ( Time, Msg msg state )
checkSubscription msg =
    case msg of
        Subscribe delay button wrapper ->
            Just ( delay, Repeat button wrapper )

        _ ->
            Nothing


{-| Render a button's outline, your content, and the mouse-sensitive overlay.

Does this by sizing an SVG `g` element at the `Location` you pass and the size of the `Button`, and calling `renderBorder`, `renderContent`, and `renderOverlay` inside it.

-}
render : Location -> Content msg -> MsgWrapper msg state -> Button state -> Svg msg
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
                [ transform ("translate(" ++ xs ++ " " ++ ys ++ ")")
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
            --++ "-webkit-touch-callout: none;"
            -- Prevent resizing text to fit
            -- https://stackoverflow.com/questions/923782
            ++ "webkit-text-size-adjust: none;"


{-| Draw a button's transparent, mouse/touch-sensitive overlay.

You should call this AFTER drawing your button, so that the overlay is the last thing drawn. Otherwise, it may not get all the mouse/touch events.

-}
renderOverlay : MsgWrapper msg state -> Button state -> Svg msg
renderOverlay wrapper (Button button) =
    let
        but =
            Button button

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
        , onTouchStart (\touch -> wrapper <| TouchStart but wrapper)
        , onMouseDown (wrapper <| MouseDown but wrapper)
        , onTouchEnd (\touch -> wrapper <| TouchEnd but wrapper)
        , onMouseUp (wrapper <| MouseUp but wrapper)
        , onMouseOut (wrapper <| MouseOut but wrapper)
        , disableSelection
        ]
        []


{-| Draw a button's border.

You should call this BEFORE drawing your button, so that its opaque body does not cover your beautiful drawing.

-}
renderBorder : Button state -> Svg msg
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


renderContent : Content msg -> Button state -> Svg msg
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
