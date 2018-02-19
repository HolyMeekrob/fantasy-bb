module Players.Show.Rest exposing (initialize)

import Players.Show.Types as Types exposing (Player, Msg)
import Common.Rest exposing (userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, int, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Task


playerRequest : Int -> Request Player
playerRequest id =
    let
        url =
            "/ajax/players/" ++ toString id
    in
        Http.get url playerDecoder


initialize : Int -> Cmd Msg
initialize id =
    Task.map2
        (\user player -> ( user, player ))
        (toTask userRequest)
        (toTask <| playerRequest id)
        |> Task.attempt Types.SetInitialData


playerDecoder : Decoder Player
playerDecoder =
    decode Player
        |> required "id" int
        |> required "firstName" string
        |> required "lastName" string
        |> optional "nickname" (nullable string) Nothing
        |> optional "hometown" (nullable string) Nothing
        |> optional "birthday" (nullable string) Nothing
