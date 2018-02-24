module Players.Show.Rest exposing (initialize, updatePlayer)

import Players.Show.Types as Types exposing (Player, Msg)
import Common.Date exposing (date, dateToString, encodeDate)
import Common.Rest exposing (encodeMaybe, put, userRequest)
import Http exposing (Request, toTask)
import Json.Decode exposing (Decoder, int, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode
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
        |> optional "birthday" (nullable date) Nothing


updatePlayer : Player -> Cmd Msg
updatePlayer player =
    let
        url =
            "/ajax/players/" ++ toString player.id

        data =
            encodePlayer player
    in
        put url data playerDecoder
            |> Http.send Types.PlayerUpdated


encodePlayer : Player -> Http.Body
encodePlayer player =
    Encode.object
        [ ( "firstName", Encode.string player.firstName )
        , ( "lastName", Encode.string player.lastName )
        , ( "nickname", encodeMaybe Encode.string player.nickname )
        , ( "hometown", encodeMaybe Encode.string player.hometown )
        , ( "birthday", encodeMaybe encodeDate player.birthday )
        ]
        |> Http.jsonBody
