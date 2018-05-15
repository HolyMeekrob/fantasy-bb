module Leagues.Show.Rest exposing (initialize)

import Common.Rest exposing (userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (decode, required)
import Leagues.Show.Types as Types exposing (League, Msg)
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


leagueDecoder : Decoder League
leagueDecoder =
    decode League
        |> required "id" int
        |> required "name" string
