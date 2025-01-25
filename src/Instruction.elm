module Instruction exposing (Instruction(..))


type Instruction
    = Forward Int
    | LeftTurn Int
    | RightTurn Int
    | Repeat Int (List Instruction)
