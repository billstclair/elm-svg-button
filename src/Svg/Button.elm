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


module Svg.Button exposing (Button)

import Svg exposing (Svg)


type Msg
    = Nop


type alias Button msg =
    { size : ( Float, Float )
    , msgWrapper : Msg -> msg
    }


simpleButton : ( Float, Float ) -> (Msg -> msg) -> Button msg
simpleButton size wrapper =
    { size = size
    , msgWrapper = wrapper
    }


update : Button msg -> ( Button msg, Cmd msg )
update button =
    button ! []


render : Button msg -> Svg msg
render button =
    Svg.g [] []
