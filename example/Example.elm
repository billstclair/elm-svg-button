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


module Example exposing (..)

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
        , Content(..)
        , normalRepeatTime
        , render
        , repeatingButton
        , simpleButton
        )
import Time exposing (Time)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Operation
    = Increment
    | Decrement


type WhichButton
    = IncrementButton
    | DecrementButton


type alias State =
    ( Operation, WhichButton )


type alias Model =
    { cnt : Int
    , incrementButton : Button State
    , decrementButton : Button State
    , subscription : Maybe ( Time, Button.Msg Msg State )
    }


type Msg
    = SimpleButtonMsg (Button.Msg Msg Operation)
    | ButtonMsg (Button.Msg Msg State)


buttonSize : Button.Size
buttonSize =
    ( 500, 100 )


buttonHeight : Float
buttonHeight =
    Tuple.second buttonSize


init : ( Model, Cmd Msg )
init =
    { cnt = 0
    , incrementButton =
        repeatingButton
            normalRepeatTime
            buttonSize
            ( Increment, IncrementButton )
    , decrementButton =
        repeatingButton
            normalRepeatTime
            buttonSize
            ( Decrement, DecrementButton )
    , subscription = Nothing
    }
        ! []


setButton : Button State -> Model -> Model
setButton button model =
    let
        ( _, idx ) =
            Button.getState button
    in
    case idx of
        IncrementButton ->
            { model | incrementButton = button }

        DecrementButton ->
            { model | decrementButton = button }


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
        SimpleButtonMsg msg ->
            let
                ( isClick, button, _ ) =
                    Button.update msg

                operation =
                    Button.getState button
            in
            operate isClick operation model ! []

        ButtonMsg msg ->
            case Button.checkSubscription msg of
                Just ( time, msg ) ->
                    { model
                        | subscription =
                            if time <= 0 then
                                Nothing
                            else
                                Just ( time, msg )
                    }
                        ! []

                Nothing ->
                    let
                        ( isClick, button, cmd ) =
                            Button.update msg

                        ( operation, _ ) =
                            Button.getState button

                        mdl =
                            setButton button model
                    in
                    operate isClick operation mdl
                        ! [ cmd ]


makeSimpleButton : Operation -> Button Operation
makeSimpleButton operation =
    simpleButton
        buttonSize
        operation


view : Model -> Html Msg
view model =
    div [ style [ ( "margin-left", "50px" ) ] ]
        [ p [ style [ ( "font-size", "50px" ) ] ]
            [ text "Count: "
            , text <| toString model.cnt
            ]
        , p []
            [ svg
                [ width "500", height (toString <| 4 * buttonHeight) ]
                [ Button.render
                    ( 0, 0 )
                    (TextContent "Increment")
                    SimpleButtonMsg
                    (simpleButton buttonSize Increment)
                , Button.render
                    ( 0, buttonHeight - 2 )
                    (TextContent "Repeating Increment")
                    ButtonMsg
                    model.incrementButton
                , Button.render
                    ( 0, 2 * (buttonHeight - 2) )
                    (TextContent "Repeating Decrement")
                    ButtonMsg
                    model.decrementButton
                , Button.render
                    ( 0, 3 * (buttonHeight - 2) )
                    (TextContent "Decrement")
                    SimpleButtonMsg
                    (simpleButton buttonSize Decrement)
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.subscription of
        Nothing ->
            Sub.none

        Just ( time, msg ) ->
            Time.every time (\time -> ButtonMsg msg)
