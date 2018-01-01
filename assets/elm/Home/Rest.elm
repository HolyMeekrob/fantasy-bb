module Home.Rest exposing (fetchUser)

import Common exposing (User)
import Home.Types as Types exposing (Msg)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


fetchUser : Cmd Msg
fetchUser =
    let
        url =
            "http://localhost:4000/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send Types.SetUser


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "firstName" string
        |> required "lastName" string
        |> required "avatar" string
