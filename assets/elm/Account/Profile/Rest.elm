module Account.Profile.Rest exposing (saveProfile)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Rest exposing (put)
import Http
import Json.Decode exposing (succeed)
import Json.Encode as Encode


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
