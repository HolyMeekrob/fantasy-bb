module Seasons.Show.Rest exposing (initialize)

import Seasons.Show.Types as Types exposing (Msg, Season)
import Common.Rest exposing (userDecoder)
import Common.Types exposing (User)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (decode, required)
import Task


fetchUser : Request User
fetchUser =
    Http.get "/ajax/account/user" userDecoder


fetchSeason : Int -> Request Season
fetchSeason id =
    let
        url =
            "/ajax/season/" ++ toString id
    in
        Http.get url seasonDecoder


initialize : Int -> Cmd Msg
initialize id =
    Task.map2
        (\user season -> ( user, season ))
        (toTask fetchUser)
        (toTask <| fetchSeason id)
        |> Task.attempt Types.SetInitialData


seasonDecoder : Decoder Season
seasonDecoder =
    decode Season
        |> required "id" int
        |> required "title" string
        |> required "start" string
