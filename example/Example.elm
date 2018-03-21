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


type Increment
    = Increment
    | Decrement


type alias ButtonMessage =
    Button.Msg Msg Increment


type alias Model =
    { cnt : Int
    , incrementButton : Button Increment
    , subscription : Maybe ( Time, ButtonMessage )
    }


type Msg
    = ButtonMsg ButtonMessage


init : ( Model, Cmd Msg )
init =
    { cnt = 0
    , incrementButton = repeatingButton normalRepeatTime ( 500, 100 ) Increment
    , subscription = Nothing
    }
        ! []


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
                    in
                    { model
                        | incrementButton =
                            case getState button of
                                Increment ->
                                    button

                                _ ->
                                    model.incrementButton
                        , cnt =
                            if isClick then
                                case getState button of
                                    Increment ->
                                        model.cnt + 1

                                    Decrement ->
                                        model.cnt - 1
                            else
                                model.cnt
                    }
                        ! [ cmd ]


view : Model -> Html Msg
view model =
    div [ style [ ( "margin-left", "50px" ) ] ]
        [ p [ style [ ( "font-size", "50px" ) ] ]
            [ text "Count: "
            , text <| toString model.cnt
            ]
        , p []
            [ svg
                [ width "500", height "200" ]
                [ Button.render
                    ( 0, 0 )
                    (TextContent "Repeating Increment")
                    ButtonMsg
                    model.incrementButton
                , Button.render
                    ( 0, 98 )
                    (TextContent "Decrement")
                    ButtonMsg
                    (simpleButton ( 500, 100 ) Decrement)
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
