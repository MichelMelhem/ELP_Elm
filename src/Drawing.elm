module Drawing exposing (display)

import Instruction exposing (Instruction(..))
import Svg exposing (Svg, line, svg)
import Svg.Attributes exposing (stroke, strokeWidth, viewBox, x1, x2, y1, y2)



-- Type représentant une ligne entre deux points


type alias Line =
    { x1 : Float
    , y1 : Float
    , x2 : Float
    , y2 : Float
    }



-- État de la tortue : position (x, y) et angle actuel


type alias TurtleState =
    { x : Float
    , y : Float
    , angle : Float
    }



-- Fonction principale pour afficher les instructions sous forme de SVG


display : List Instruction -> Svg msg
display instructions =
    let
        -- État initial de la tortue
        initialTurtle =
            { x = 0, y = 0, angle = 0 }

        -- Calcul des lignes et de l'état final de la tortue
        ( lines, _ ) =
            processInstructions instructions initialTurtle []

        -- Calcul de la boîte englobante pour adapter la vue
        bbox =
            computeBoundingBox lines

        padding =
            10

        -- Ajout de marge autour du dessin
        -- Calcul des limites du SVG
        svgMinX =
            bbox.minX - padding

        svgMinY =
            -bbox.maxY - padding

        svgMaxX =
            bbox.maxX + padding

        svgMaxY =
            -bbox.minY + padding

        -- Définition du viewBox pour adapter la vue SVG
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



-- Traitement de la liste d'instructions


processInstructions : List Instruction -> TurtleState -> List Line -> ( List Line, TurtleState )
processInstructions instructions turtle lines =
    case instructions of
        [] ->
            ( lines, turtle )

        -- Fin des instructions, retourner les lignes et l'état actuel
        instr :: rest ->
            let
                -- Traiter une seule instruction
                ( newLines, newTurtle ) =
                    processInstruction instr turtle
            in
            -- Continuer avec le reste des instructions
            processInstructions rest newTurtle (lines ++ newLines)



-- Traiter une seule instruction


processInstruction : Instruction -> TurtleState -> ( List Line, TurtleState )
processInstruction instruction turtle =
    case instruction of
        -- Instruction "Forward" : dessiner une ligne
        Forward distance ->
            let
                angleRad =
                    degrees turtle.angle

                -- Convertir l'angle en radians
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

        -- Instruction "LeftTurn" : tourner à gauche
        LeftTurn degrees ->
            ( [], { turtle | angle = turtle.angle - toFloat degrees |> normalizeAngle } )

        -- Instruction "RightTurn" : tourner à droite
        RightTurn degrees ->
            ( [], { turtle | angle = turtle.angle + toFloat degrees |> normalizeAngle } )

        -- Instruction "Repeat" : répéter un bloc d'instructions
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



-- Normaliser l'angle (le maintenir entre 0 et 360 degrés)


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



-- Calcul de la boîte englobante pour ajuster les dimensions du SVG


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



-- Convertir une ligne en élément SVG


lineToSvg : Line -> Svg msg
lineToSvg l =
    line
        [ x1 (String.fromFloat l.x1)
        , y1 (String.fromFloat -l.y1) -- Inverser l'axe Y (SVG utilise un repère inversé)
        , x2 (String.fromFloat l.x2)
        , y2 (String.fromFloat -l.y2)
        , stroke "black" -- Couleur du trait
        , strokeWidth "1" -- Épaisseur du trait
        ]
        []
