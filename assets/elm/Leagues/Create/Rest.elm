module Leagues.Create.Rest exposing (createLeague, initialize)

import Common.Rest exposing (userRequest)
import Http exposing (Request, jsonBody, toTask)
import Json.Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Leagues.Create.Types as Types exposing (League, Model, Msg, Season)
import Task


initialize : Cmd Msg
initialize =
    Task.map2
        (\user seasons -> ( user, seasons ))
        (toTask userRequest)
        (toTask getPossibleSeasons)
        |> Task.attempt Types.SetInitialData


getPossibleSeasons : Request (List Season)
getPossibleSeasons =
    let
        url =
            "/ajax/seasons/upcoming"
    in
        Http.get url (list seasonDecoder)


createLeague : Model -> Cmd Msg
createLeague model =
    let
        url =
            "/ajax/leagues"

        data =
            Encode.object
                [ ( "name", Encode.string model.name ) ]
                |> jsonBody
    in
        Http.post url data leagueDecoder
            |> Http.send Types.LeagueCreated


seasonDecoder : Decoder Season
seasonDecoder =
    decode Season
        |> required "id" int
        |> required "title" string


leagueDecoder : Decoder League
leagueDecoder =
    decode League
        |> required "id" int
