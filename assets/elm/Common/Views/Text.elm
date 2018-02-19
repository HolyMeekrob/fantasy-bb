module Common.Views.Text exposing (playerName)


playerName : String -> String -> Maybe String -> String
playerName firstName lastName nickname =
    let
        nick =
            case nickname of
                Just name ->
                    "\"" ++ name ++ "\""

                Nothing ->
                    ""
    in
        [ firstName, nick, lastName ]
            |> List.filter (\str -> not (String.isEmpty str))
            |> String.join " "
