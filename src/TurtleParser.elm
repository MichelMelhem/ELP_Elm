module TurtleParser exposing (read)

import Instruction exposing (Instruction(..))
import Parser exposing (..)



-- Point d'entrée pour analyser un programme


read : String -> Result (List DeadEnd) (List Instruction)
read input =
    run programParser input



-- Analyseur principal pour une liste d'instructions


programParser : Parser (List Instruction)
programParser =
    bracketed (Parser.lazy (\_ -> instructionParser))



-- Analyseur pour une seule instruction


instructionParser : Parser Instruction
instructionParser =
    oneOf
        [ repeatParser
        , forwardParser
        , leftParser
        , rightParser
        ]



-- Analyseur pour l'instruction "Repeat"


repeatParser : Parser Instruction
repeatParser =
    succeed Repeat
        |. token "Repeat"
        |. spaces
        |= int
        |. spaces
        |= programParser



-- Analyseur pour une liste d'éléments entourés de crochets


bracketed : Parser a -> Parser (List a)
bracketed p =
    Parser.sequence
        { start = "["
        , separator = ","
        , end = "]"
        , spaces = spaces
        , item = p
        , trailing = Optional
        }



-- Analyseur pour l'instruction "Forward"


forwardParser : Parser Instruction
forwardParser =
    succeed Forward
        |. token "Forward"
        |. spaces
        |= int



-- Analyseur pour l'instruction "LeftTurn"


leftParser : Parser Instruction
leftParser =
    succeed LeftTurn
        |. token "LeftTurn"
        |. spaces
        |= int



-- Analyseur pour l'instruction "RightTurn"


rightParser : Parser Instruction
rightParser =
    succeed RightTurn
        |. token "RightTurn"
        |. spaces
        |= int



-- Analyseur pour les espaces et les tabulations


spaces : Parser ()
spaces =
    chompWhile (\c -> c == ' ' || c == '\t')
