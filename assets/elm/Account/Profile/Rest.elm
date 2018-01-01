module Account.Profile.Rest exposing (fetchUser)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common exposing (User)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, optional, required)


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
        |> required "email" string
        |> optional "bio" string "No bio"
        |> required "avatar" string
