module Account.Profile.Rest exposing (fetchUser, saveProfile)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Rest exposing (put)
import Common.Types exposing (userDecoder)
import Http
import Json.Decode exposing (succeed)
import Json.Encode as Encode


fetchUser : Cmd Msg
fetchUser =
    let
        url =
            "/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send Types.SetUser


saveProfile : String -> Cmd Msg
saveProfile bio =
    let
        url =
            "/ajax/account/user"

        data =
            Encode.object
                [ ( "bio", Encode.string bio ) ]
                |> Http.jsonBody
    in
        put url data (succeed True)
            |> Http.send Types.ViewProfile
