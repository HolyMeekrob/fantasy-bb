module Teams.Show.Rest exposing (initialize)

import Common.Rest exposing (userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Teams.Show.Types as Types exposing (Msg, Player, Team)
import Task


teamRequest : Int -> Request Team
teamRequest id =
    let
        url =
            "/ajax/teams/" ++ toString id
    in
        Http.get url teamDecoder


initialize : Int -> Cmd Msg
initialize id =
    Task.map2
        (\user team -> ( user, team ))
        (toTask userRequest)
        (toTask <| teamRequest id)
        |> Task.attempt Types.SetInitialData


playerDecoder : Decoder Player
playerDecoder =
    decode Player
        |> required "id" int
        |> required "name" string
        |> required "points" int


teamDecoder : Decoder Team
teamDecoder =
    decode Team
        |> required "id" int
        |> required "name" string
        |> required "ownerId" int
        |> required "ownerName" string
        |> required "points" int
        |> required "players" (list playerDecoder)
        |> required "canEdit" bool
