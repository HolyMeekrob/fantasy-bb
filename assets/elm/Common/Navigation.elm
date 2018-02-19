port module Common.Navigation exposing (findId, navigate)


import Regex exposing (regex)

port navigate : String -> Cmd msg

findId : String -> Int
findId url =
    let
        expr =
            regex "^.+\\/(\\d+)$"

        matches =
            Regex.find Regex.All expr url

        match =
            List.head matches
    in
        case match of
            Nothing ->
                0

            Just m ->
                m.submatches
                    |> List.map (Maybe.withDefault "")
                    |> List.head
                    |> Maybe.withDefault "0"
                    |> String.toInt
                    |> Result.withDefault 0