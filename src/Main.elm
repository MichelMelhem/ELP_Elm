module Main exposing (..)

-- Importation des modules nécessaires

import Browser
import Drawing exposing (display)
import Html exposing (Html, button, div, text, textarea)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onInput)
import Instruction exposing (Instruction(..))
import Parser exposing (..)
import TurtleParser



{--
Exemple d'entrée fonctionnelle :
[Repeat 2 [Forward 100, LeftTurn 90, Forward 50, LeftTurn 90], Forward 20, Repeat 36 [Forward 5, RightTurn 10], Forward 60, Repeat 36 [Forward 5, RightTurn 10]]
--}
-- Modèle principal contenant l'entrée utilisateur et le programme analysé


type alias Model =
    { input : String
    , program : Result String (List Instruction)
    }



-- Types de messages pour gérer les interactions


type Msg
    = InputChanged String
    | Parse



-- Initialisation du modèle


init : () -> ( Model, Cmd Msg )
init _ =
    ( { input = "", program = Ok [] }, Cmd.none )



-- Gestion des messages pour mettre à jour le modèle


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Mise à jour de l'entrée utilisateur
        InputChanged s ->
            ( { model | input = s }, Cmd.none )

        -- Analyse de l'entrée pour créer une liste d'instructions
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



-- Convertit les erreurs de parsing en texte lisible


parseErrorsToString : List Parser.DeadEnd -> String
parseErrorsToString deadEnds =
    List.map deadEndToString deadEnds
        |> String.join "\n"



-- Formate une erreur spécifique


deadEndToString : Parser.DeadEnd -> String
deadEndToString deadEnd =
    "Error at line " ++ String.fromInt deadEnd.row ++ ", col " ++ String.fromInt deadEnd.col ++ ": " ++ Parser.deadEndsToString [ deadEnd ]



-- Vue principale de l'interface utilisateur


view : Model -> Html Msg
view model =
    div [ style "padding" "20px" ]
        [ -- Zone de texte pour l'entrée utilisateur
          textarea
            [ onInput InputChanged
            , style "width" "400px"
            , style "height" "200px"
            ]
            []
        , -- Bouton pour lancer l'analyse
          button [ onClick Parse ] [ text "Draw" ]
        , -- Affichage des résultats : instructions ou erreurs
          case model.program of
            Ok instructions ->
                div []
                    [ display instructions ]

            Err err ->
                div [ style "color" "red" ] [ text err ]
        ]



-- Point d'entrée principal du programme


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
