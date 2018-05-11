module Leagues.Rest exposing (initialize)

import Common.Rest exposing (userRequest)
import Json.Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Http exposing (Request, toTask)
import Leagues.Types as Types exposing (League, LeagueSummary, Msg)
import Task


leaguesRequest : Request LeagueSummary
leaguesRequest =
    let
        url =
            "/ajax/leagues/mine"
    in
        Http.get url leagueSummaryDecoder


initialize : Cmd Msg
initialize =
    Task.map2
        (\user leagues -> ( user, leagues ))
        (toTask userRequest)
        (toTask leaguesRequest)
        |> Task.attempt Types.SetInitialData


leagueSummaryDecoder : Decoder LeagueSummary
leagueSummaryDecoder =
    decode LeagueSummary
        |> optional "upcoming" (list leagueDecoder) []
        |> optional "current" (list leagueDecoder) []
        |> optional "complete" (list leagueDecoder) []


leagueDecoder : Decoder League
leagueDecoder =
    decode League
        |> required "id" int
        |> required "name" string
        |> required "teamName" string
        |> required "teamRank" int
        |> required "teamCount" int
