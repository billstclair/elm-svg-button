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
import Svg.Button as Button exposing (Button, Content(..), render, simpleButton)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }


type alias Model =
    { cnt : Int
    , button : Button
    }


type Msg
    = ButtonMsg Button.Msg


init : ( Model, Cmd Msg )
init =
    { cnt = 0
    , button = simpleButton ( 500, 100 )
    }
        ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ButtonMsg msg ->
            let
                ( isClick, button, cmd ) =
                    Button.update msg
            in
            { model
                | button = button
                , cnt =
                    if isClick then
                        model.cnt + 1
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
                [ width "500", height "100" ]
                [ Button.render
                    ( 0, 0 )
                    (TextContent "Increment")
                    ButtonMsg
                    model.button
                ]
            ]
        ]
