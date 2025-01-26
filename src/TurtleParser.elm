module TurtleParser exposing (read)

import Instruction exposing (Instruction(..))
import Parser exposing (..)



-- Entry point for parsing a program


read : String -> Result (List DeadEnd) (List Instruction)
read input =
    run programParser input



-- Top-level parser for a list of instructions


programParser : Parser (List Instruction)
programParser =
    bracketed (Parser.lazy (\_ -> instructionParser))



-- Parser for a single instruction


instructionParser : Parser Instruction
instructionParser =
    oneOf
        [ repeatParser
        , forwardParser
        , leftParser
        , rightParser
        ]



-- Parser for the "Repeat" instruction


repeatParser : Parser Instruction
repeatParser =
    succeed Repeat
        |. token "Repeat"
        |. spaces
        |= int
        |. spaces
        |= programParser



-- Parser for a list of items within brackets


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



-- Parser for the "Forward" instruction


forwardParser : Parser Instruction
forwardParser =
    succeed Forward
        |. token "Forward"
        |. spaces
        |= int



-- Parser for the "Left" instruction


leftParser : Parser Instruction
leftParser =
    succeed LeftTurn
        |. token "Left"
        |. spaces
        |= int



-- Parser for the "Right" instruction


rightParser : Parser Instruction
rightParser =
    succeed RightTurn
        |. token "Right"
        |. spaces
        |= int



-- Parser for spaces and tabs


spaces : Parser ()
spaces =
    chompWhile (\c -> c == ' ' || c == '\t')
