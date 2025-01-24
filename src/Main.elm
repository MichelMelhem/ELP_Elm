module Main exposing (main)

import Browser
import Html exposing (Html, div, text)


main =
    Browser.sandbox { init = init, update = update, view = view }


init =
    {}


type Msg
    = NoOp


update msg model =
    model


view model =
    div [] [ text "Hello, World!" ]
