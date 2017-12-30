module Header.Rest exposing (updateUser, logOut)

import Header.Types as Types exposing (Msg)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


updateUser : Cmd Msg
updateUser =
    let
        url =
            "http://localhost:4000/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send Types.SetUser


userDecoder : Decoder Types.User
userDecoder =
    decode Types.User
        |> required "firstName" string
        |> required "lastName" string
        |> required "avatar" string


logOut : Cmd Msg
logOut =
    let
        url =
            "http://localhost:4000/auth/logout"
    in
        Http.request
            { method = "DELETE"
            , headers = []
            , url = url
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Maybe.Nothing
            , withCredentials = False
            }
            |> Http.send Types.LogOut
