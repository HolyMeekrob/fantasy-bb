module Seasons.Show.Rest exposing (initialize)

import Seasons.Show.Types as Types exposing (Houseguest, Msg, Season)
import Common.Rest exposing (userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, int, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Task


seasonRequest : Int -> Request Season
seasonRequest id =
    let
        url =
            "/ajax/season/" ++ toString id
    in
        Http.get url seasonDecoder


initialize : Int -> Cmd Msg
initialize id =
    Task.map2
        (\user season -> ( user, season ))
        (toTask userRequest)
        (toTask <| seasonRequest id)
        |> Task.attempt Types.SetInitialData


seasonDecoder : Decoder Season
seasonDecoder =
    decode Season
        |> required "id" int
        |> required "title" string
        |> required "start" string
        |> optional "houseguests" (list houseguestDecoder) []

houseguestDecoder : Decoder Houseguest
houseguestDecoder =
    decode Houseguest
        |> required "id" int
        |> required "firstName" string
        |> required "lastName" string
        |> optional "nickname" (nullable string) Nothing
