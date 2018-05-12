module Common.String exposing (rank, toMaybe)


toMaybe : String -> Maybe String
toMaybe str =
    if (String.isEmpty str) then
        Nothing
    else
        Just str


rank : Int -> String
rank num =
    let
        rankSuffix : Int -> String
        rankSuffix n =
            case rem n 10 of
                1 ->
                    "st"

                2 ->
                    "nd"

                3 ->
                    "rd"

                _ ->
                    "th"
    in
        toString num ++ rankSuffix num
