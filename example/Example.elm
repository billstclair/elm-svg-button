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
import Svg.Button as Button exposing (Button, render, renderOutline, simpleButton)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }


type alias Model =
    { cnt : Int
    , button : Button Msg
    }


type Msg
    = ButtonMsg Button.Msg


init : ( Model, Cmd Msg )
init =
    { cnt = 0
    , button = simpleButton ( 500, 100 ) ButtonMsg
    }
        ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ButtonMsg msg ->
            let
                ( button, cmd ) =
                    Button.update msg model.button
            in
            { model
                | button = button
                , cnt = model.cnt + 1
            }
                ! []


view : Model -> Html Msg
view model =
    div []
        [ p []
            [ text "Count: "
            , text <| toString model.cnt
            ]
        , p []
            [ Svg.svg [ width "500", height "100" ]
                [ renderOutline model.button
                , Svg.text_
                    [ fill "black"
                    , fontSize "48"
                    , x "250"
                    , y "50"
                    , textAnchor "middle"
                    , alignmentBaseline "middle"
                    ]
                    [ Svg.text "Increment" ]
                , render model.button
                ]
            ]
        ]
