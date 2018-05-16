module Leagues.Show.Rest exposing (initialize)

import Common.Rest exposing (userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Leagues.Show.Types as Types exposing (League, Msg, Team)
import Task


leagueRequest : Int -> Request League
leagueRequest id =
    let
        url =
            "/ajax/leagues/" ++ toString id
    in
        Http.get url leagueDecoder


initialize : Int -> Cmd Msg
initialize id =
    Task.map2
        (\user league -> ( user, league ))
        (toTask userRequest)
        (toTask <| leagueRequest id)
        |> Task.attempt Types.SetInitialData


teamDecoder : Decoder Team
teamDecoder =
    decode Team
        |> required "id" int
        |> required "name" string
        |> required "ownerId" int
        |> required "ownerName" string
        |> optional "logo" string ""


leagueDecoder : Decoder League
leagueDecoder =
    decode League
        |> required "id" int
        |> required "name" string
        |> required "teams" (list teamDecoder)
        |> required "canEdit" bool
