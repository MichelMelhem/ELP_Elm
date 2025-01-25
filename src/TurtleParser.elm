module TurtleParser exposing (read)

import Instruction exposing (Instruction(..))
import Parser exposing (..)


read : String -> Result (List DeadEnd) (List Instruction)
read input =
    run programParser input


programParser : Parser (List Instruction)
programParser =
    sequence
        { start = "["
        , separator = ","
        , end = "]"
        , spaces = spaces
        , item = instructionParser
        , trailing = Optional
        }


instructionParser : Parser Instruction
instructionParser =
    oneOf
        [ repeatParser
        , forwardParser
        , leftParser
        , rightParser
        ]


repeatParser : Parser Instruction
repeatParser =
    succeed Repeat
        |. token "Repeat"
        |. spaces
        |= int
        |. spaces
        |= lazy (\_ -> bracketed programParser)


bracketed : Parser (List a) -> Parser (List a)
bracketed parser =
    symbol "["
        -- Parse the opening bracket
        |> andThen
            (\_ ->
                parser
                    |. symbol "]"
             -- Parse the closing bracket
            )


forwardParser : Parser Instruction
forwardParser =
    succeed Forward
        |. token "Forward"
        |. spaces
        |= int


leftParser : Parser Instruction
leftParser =
    succeed LeftTurn
        |. token "Left"
        |. spaces
        |= int


rightParser : Parser Instruction
rightParser =
    succeed RightTurn
        |. token "Right"
        |. spaces
        |= int


spaces : Parser ()
spaces =
    chompWhile (\c -> c == ' ' || c == '\t')
