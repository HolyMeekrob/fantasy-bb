module Leagues.Create.Rest exposing (createLeague)

import Http exposing (jsonBody)
import Json.Decode exposing (Decoder, int)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Leagues.Create.Types as Types exposing (League, Model, Msg)


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


leagueDecoder : Decoder League
leagueDecoder =
    decode League
        |> required "id" int
