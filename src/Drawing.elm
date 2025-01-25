module Drawing exposing (display)

import Instruction exposing (Instruction(..))
import Svg exposing (Svg, line, svg)
import Svg.Attributes exposing (stroke, strokeWidth, viewBox, x1, x2, y1, y2)


type alias Line =
    { x1 : Float
    , y1 : Float
    , x2 : Float
    , y2 : Float
    }


type alias TurtleState =
    { x : Float
    , y : Float
    , angle : Float
    }


display : List Instruction -> Svg msg
display instructions =
    let
        initialTurtle =
            { x = 0, y = 0, angle = 0 }

        ( lines, _ ) =
            processInstructions instructions initialTurtle []

        bbox =
            computeBoundingBox lines

        padding =
            10

        svgMinX =
            bbox.minX - padding

        svgMinY =
            -bbox.maxY - padding

        svgMaxX =
            bbox.maxX + padding

        svgMaxY =
            -bbox.minY + padding

        viewBoxStr =
            String.fromFloat svgMinX
                ++ " "
                ++ String.fromFloat svgMinY
                ++ " "
                ++ String.fromFloat (svgMaxX - svgMinX)
                ++ " "
                ++ String.fromFloat (svgMaxY - svgMinY)
    in
    svg
        [ viewBox viewBoxStr
        , Svg.Attributes.width "500"
        , Svg.Attributes.height "500"
        ]
        (List.map lineToSvg lines)


processInstructions : List Instruction -> TurtleState -> List Line -> ( List Line, TurtleState )
processInstructions instructions turtle lines =
    case instructions of
        [] ->
            ( lines, turtle )

        instr :: rest ->
            let
                ( newLines, newTurtle ) =
                    processInstruction instr turtle
            in
            processInstructions rest newTurtle (lines ++ newLines)


processInstruction : Instruction -> TurtleState -> ( List Line, TurtleState )
processInstruction instruction turtle =
    case instruction of
        Forward distance ->
            let
                angleRad =
                    degrees turtle.angle

                dx =
                    toFloat distance * cos angleRad

                dy =
                    toFloat distance * sin angleRad

                newX =
                    turtle.x + dx

                newY =
                    turtle.y + dy

                newLine =
                    { x1 = turtle.x
                    , y1 = turtle.y
                    , x2 = newX
                    , y2 = newY
                    }
            in
            ( [ newLine ], { turtle | x = newX, y = newY } )

        LeftTurn degrees ->
            ( [], { turtle | angle = turtle.angle - toFloat degrees |> normalizeAngle } )

        RightTurn degrees ->
            ( [], { turtle | angle = turtle.angle + toFloat degrees |> normalizeAngle } )

        Repeat n children ->
            let
                loop i currentTurtle accLines =
                    if i <= 0 then
                        ( accLines, currentTurtle )

                    else
                        let
                            ( childLines, childTurtle ) =
                                processInstructions children currentTurtle []
                        in
                        loop (i - 1) childTurtle (accLines ++ childLines)

                ( repeatedLines, newTurtle ) =
                    loop n turtle []
            in
            ( repeatedLines, newTurtle )


normalizeAngle : Float -> Float
normalizeAngle angle =
    let
        remainder =
            angle - 360 * toFloat (floor (angle / 360))
    in
    if remainder < 0 then
        remainder + 360

    else
        remainder


computeBoundingBox : List Line -> { minX : Float, maxX : Float, minY : Float, maxY : Float }
computeBoundingBox lines =
    let
        coords =
            List.concatMap (\line -> [ ( line.x1, line.y1 ), ( line.x2, line.y2 ) ]) lines

        xs =
            List.map Tuple.first coords

        ys =
            List.map Tuple.second coords
    in
    { minX = Maybe.withDefault 0 (List.minimum xs)
    , maxX = Maybe.withDefault 0 (List.maximum xs)
    , minY = Maybe.withDefault 0 (List.minimum ys)
    , maxY = Maybe.withDefault 0 (List.maximum ys)
    }


lineToSvg : Line -> Svg msg
lineToSvg l =
    line
        [ x1 (String.fromFloat l.x1)
        , y1 (String.fromFloat -l.y1)
        , x2 (String.fromFloat l.x2)
        , y2 (String.fromFloat -l.y2)
        , stroke "black"
        , strokeWidth "1"
        ]
        []
