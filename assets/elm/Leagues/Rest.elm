module Leagues.Rest exposing (initialize)

import Common.Rest exposing (userRequest)
import Json.Decode exposing (Decoder, int, list)
import Json.Decode.Pipeline exposing (decode, required)
import Http exposing (Request, toTask)
import Leagues.Types as Types exposing (League, Msg)
import Task


leaguesRequest : Request (List League)
leaguesRequest =
    let
        url =
            "/ajax/leagues"
    in
        Http.get url (list leagueDecoder)


initialize : Cmd Msg
initialize =
    Task.map2
        (\user leagues -> ( user, leagues ))
        (toTask userRequest)
        (toTask leaguesRequest)
        |> Task.attempt Types.SetInitialData


leagueDecoder : Decoder League
leagueDecoder =
    decode League
        |> required "id" int
