----------------------------------------------------------------------
--
-- Example.elm
-- Svg.Button example
-- Copyright (c) 2018 Bill St. Clair <billstclair@gmail.com>
-- Some rights reserved.
-- Distributed under the MIT License
-- See LICENSE.txt
--
----------------------------------------------------------------------


module SvgButtonExample exposing (Model, Msg(..), Operation(..), buttonHeight, buttonSize, init, main, operate, subscriptions, update, view)

import Browser
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (style)
import Svg exposing (Attribute, Svg, svg)
import Svg.Attributes
    exposing
        ( alignmentBaseline
        , fill
        , fontSize
        , height
        , textAnchor
        , width
        , x
        , y
        )
import Svg.Button as Button
    exposing
        ( Button
        , Colors
        , Content(..)
        )
import Time exposing (Posix)


main =
    Browser.element
        { init = \() -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Operation
    = Increment
    | Decrement


type alias Model =
    { cnt : Int
    , incrementButton : Button () Msg
    , decrementButton : Button () Msg
    , subscription : Maybe ( Float, Button.Msg, Operation )
    }


type Msg
    = SimpleButtonMsg Button.Msg Operation
    | ButtonMsg Button.Msg Operation


buttonSize : Button.Size
buttonSize =
    ( 500, 100 )


buttonHeight : Float
buttonHeight =
    Tuple.second buttonSize


cmdNone : model -> ( model, Cmd msg )
cmdNone msg =
    ( msg, Cmd.none )


repeatingColors : Colors
repeatingColors =
    let
        colors =
            Button.defaultColors
    in
    { colors
        | background = "lightblue"
        , text = "green"
    }


init : ( Model, Cmd Msg )
init =
    cmdNone
        { cnt = 0
        , incrementButton =
            Button.repeatingButton
                Button.normalRepeatTime
                buttonSize
                ()
                |> Button.setColors repeatingColors
        , decrementButton =
            Button.repeatingButton
                Button.normalRepeatTime
                buttonSize
                ()
                |> Button.setColors repeatingColors
        , subscription = Nothing
        }


operate : Bool -> Operation -> Model -> Model
operate isClick operation model =
    if not isClick then
        model

    else
        { model
            | cnt =
                case operation of
                    Increment ->
                        model.cnt + 1

                    Decrement ->
                        model.cnt - 1
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SimpleButtonMsg m operation ->
            let
                ( isClick, _, _ ) =
                    Button.update (\bm -> SimpleButtonMsg bm operation)
                        m
                        simpleButton
            in
            cmdNone <| operate isClick operation model

        ButtonMsg m operation ->
            let
                button =
                    case operation of
                        Increment ->
                            model.incrementButton

                        Decrement ->
                            model.decrementButton
            in
            case Button.checkSubscription m button of
                Just ( time, m2 ) ->
                    cmdNone
                        { model
                            | subscription =
                                if time <= 0 then
                                    Nothing

                                else
                                    Just ( time, m2, operation )
                        }

                Nothing ->
                    let
                        ( isClick, button2, cmd ) =
                            Button.update (\bm -> ButtonMsg bm operation) m button

                        mdl =
                            case operation of
                                Increment ->
                                    { model | incrementButton = button2 }

                                Decrement ->
                                    { model | decrementButton = button2 }
                    in
                    ( operate isClick operation mdl, cmd )


simpleButton : Button () Msg
simpleButton =
    Button.simpleButton buttonSize ()


triangularButtonSize : Button.Size
triangularButtonSize =
    ( 166, 120 )


triangularButtonWidth =
    triangularButtonSize |> Tuple.first


triangularButtonHeight =
    triangularButtonSize |> Tuple.second


triangularColors : Colors
triangularColors =
    let
        colors =
            Button.defaultColors
    in
    { colors
        | background = "purple"
    }


triangularButton : Button.TriangularButtonDirection -> Button () Msg
triangularButton direction =
    Button.simpleButton triangularButtonSize ()
        |> Button.setColors triangularColors
        |> Button.setTriangularButtonRenderers direction


view : Model -> Html Msg
view model =
    div [ style "margin-left" "50px" ]
        [ p [ style "font-size" "50px" ]
            [ text "Count: "
            , text <| String.fromInt model.cnt
            ]
        , p []
            [ svg
                [ width "500", height (String.fromFloat <| 4 * buttonHeight) ]
                [ Button.render
                    ( 0, 0 )
                    (TextContent "Increment")
                    (\m -> SimpleButtonMsg m Increment)
                    simpleButton
                , Button.render
                    ( 0, buttonHeight - 2 )
                    (TextContent "Repeating Increment")
                    (\m -> ButtonMsg m Increment)
                    model.incrementButton
                , Button.render
                    ( 0, 2 * (buttonHeight - 2) )
                    (TextContent "Repeating Decrement")
                    (\m -> ButtonMsg m Decrement)
                    model.decrementButton
                , Button.render
                    ( 0, 3 * (buttonHeight - 2) )
                    (TextContent "Decrement")
                    (\m -> SimpleButtonMsg m Decrement)
                    simpleButton
                ]
            ]
        , p []
            [ svg
                [ width "500", height "500" ]
                [ Button.render
                    ( triangularButtonWidth, 0 )
                    NoContent
                    (\m -> SimpleButtonMsg m Increment)
                    (triangularButton Button.UpButton)
                , Button.render
                    ( 0, triangularButtonHeight )
                    NoContent
                    (\m -> SimpleButtonMsg m Decrement)
                    (triangularButton Button.LeftButton)
                , Button.render
                    ( triangularButtonWidth, 2 * triangularButtonHeight )
                    NoContent
                    (\m -> SimpleButtonMsg m Increment)
                    (triangularButton Button.DownButton)
                , Button.render
                    ( 2 * triangularButtonWidth, triangularButtonHeight )
                    NoContent
                    (\m -> SimpleButtonMsg m Decrement)
                    (triangularButton Button.RightButton)
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.subscription of
        Nothing ->
            Sub.none

        Just ( time, msg, operation ) ->
            Time.every time (\_ -> ButtonMsg msg operation)
