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
        , getState
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


type alias State =
    ( Operation, Int )


type alias ButtonMessage =
    Button.Msg Msg State


type alias Model =
    { cnt : Int
    , incrementButton : Button State
    , decrementButton : Button State
    , subscription : Maybe ( Time, ButtonMessage )
    }


type Msg
    = ButtonMsg ButtonMessage


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
        repeatingButton normalRepeatTime buttonSize ( Increment, 0 )
    , decrementButton =
        repeatingButton normalRepeatTime buttonSize ( Decrement, 1 )
    , subscription = Nothing
    }
        ! []


setButton : Button State -> Model -> Model
setButton button model =
    let
        ( _, idx ) =
            Button.getState button
    in
    if idx == 0 then
        { model | incrementButton = button }
    else if idx == 1 then
        { model | decrementButton = button }
    else
        model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ButtonMsg msg ->
            case Button.checkSubscription msg of
                Just subscription ->
                    let
                        ( time, _ ) =
                            subscription
                    in
                    { model
                        | subscription =
                            if time <= 0 then
                                Nothing
                            else
                                Just subscription
                    }
                        ! []

                Nothing ->
                    let
                        ( isClick, button, cmd ) =
                            Button.update msg

                        ( operation, _ ) =
                            getState button

                        mdl =
                            setButton button model
                    in
                    { mdl
                        | cnt =
                            if isClick then
                                case operation of
                                    Increment ->
                                        model.cnt + 1

                                    Decrement ->
                                        model.cnt - 1
                            else
                                model.cnt
                    }
                        ! [ cmd ]


makeSimpleButton : Operation -> Button State
makeSimpleButton operation =
    simpleButton
        buttonSize
        ( operation, -1 )


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
                    ButtonMsg
                    (makeSimpleButton Increment)
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
                    ButtonMsg
                    (makeSimpleButton Decrement)
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
