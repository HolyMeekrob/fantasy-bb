module Players.Create.Rest exposing (createPlayer)

import Common.Date exposing (date, dateToString, encodeDate)
import Common.Rest exposing (encodeMaybe)
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder, int)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Players.Create.Types as Types exposing (CreatedPlayer, Model, Msg)


createPlayer : Model -> Cmd Msg
createPlayer model =
    let
        url =
            "/ajax/players"

        player =
            model.player

        data =
            Encode.object
                [ ( "firstName", Encode.string player.firstName )
                , ( "lastName", Encode.string player.lastName )
                , ( "nickname", encodeMaybe Encode.string player.nickname )
                , ( "hometown", encodeMaybe Encode.string player.hometown )
                , ( "birthday", encodeMaybe encodeDate player.birthday )
                ]
                |> jsonBody
    in
        Http.post url data newPlayerDecoder
            |> Http.send Types.PlayerCreated


newPlayerDecoder : Decoder CreatedPlayer
newPlayerDecoder =
    decode CreatedPlayer
        |> required "id" int
