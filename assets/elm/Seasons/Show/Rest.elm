module Seasons.Show.Rest exposing (initialize, updateSeason)

import Seasons.Show.Types as Types exposing (Player, Msg, Season)
import Common.Date exposing (date, dateToString)
import Common.Rest exposing (put, userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, int, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode
import Task


seasonRequest : Int -> Request Season
seasonRequest id =
    let
        url =
            "/ajax/seasons/" ++ toString id
    in
        Http.get url seasonDecoder


initialize : Int -> Cmd Msg
initialize id =
    Task.map2
        (\user season -> ( user, season ))
        (toTask userRequest)
        (toTask <| seasonRequest id)
        |> Task.attempt Types.SetInitialData


updateSeason : Season -> Cmd Msg
updateSeason season =
    let
        url =
            "/ajax/seasons/" ++ toString season.id

        start =
            Maybe.map dateToString season.start
                |> Maybe.withDefault ""

        data =
            Encode.object
                [ ( "title", Encode.string season.title )
                , ( "start", Encode.string start )
                ]
                |> Http.jsonBody
    in
        put url data seasonDecoder
            |> Http.send Types.SeasonUpdated


seasonDecoder : Decoder Season
seasonDecoder =
    decode Season
        |> required "id" int
        |> required "title" string
        |> required "start" (nullable date)
        |> optional "players" (list playerDecoder) []


playerDecoder : Decoder Player
playerDecoder =
    decode Player
        |> required "id" int
        |> required "firstName" string
        |> required "lastName" string
        |> optional "nickname" (nullable string) Nothing
