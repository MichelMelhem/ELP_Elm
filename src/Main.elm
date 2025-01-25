module Main exposing (..)

import Browser
import Drawing exposing (display)
import Html exposing (Html, button, div, text, textarea)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onInput)
import Instruction exposing (Instruction(..))
import Parser exposing (..)
import TurtleParser


type alias Model =
    { input : String
    , program : Result String (List Instruction)
    }


type Msg
    = InputChanged String
    | Parse


init : () -> ( Model, Cmd Msg )
init _ =
    ( { input = "", program = Ok [] }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged s ->
            ( { model | input = s }, Cmd.none )

        Parse ->
            let
                parsed =
                    case TurtleParser.read model.input of
                        Ok instructions ->
                            Ok instructions

                        Err deadEnds ->
                            Err (parseErrorsToString deadEnds)
            in
            ( { model | program = parsed }, Cmd.none )


parseErrorsToString : List Parser.DeadEnd -> String
parseErrorsToString deadEnds =
    List.map deadEndToString deadEnds
        |> String.join "\n"


deadEndToString : Parser.DeadEnd -> String
deadEndToString deadEnd =
    "Error at line " ++ String.fromInt deadEnd.row ++ ", col " ++ String.fromInt deadEnd.col ++ ": " ++ Parser.deadEndsToString [ deadEnd ]


view : Model -> Html Msg
view model =
    div [ style "padding" "20px" ]
        [ textarea
            [ onInput InputChanged
            , style "width" "400px"
            , style "height" "200px"
            ]
            []
        , button [ onClick Parse ] [ text "Draw" ]
        , case model.program of
            Ok instructions ->
                div []
                    [ display instructions ]

            Err err ->
                div [ style "color" "red" ] [ text err ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
