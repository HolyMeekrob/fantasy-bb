module Account.Profile.Rest exposing (saveProfile)

import Account.Profile.Types as Types exposing (Msg)
import Common.Rest exposing (put)
import Common.Types exposing (User)
import Http
import Json.Decode exposing (succeed)
import Json.Encode as Encode


saveProfile : User -> Cmd Msg
saveProfile user =
    let
        url =
            "/ajax/account/user"

        data =
            Encode.object
                [ ( "email", Encode.string user.email )
                , ( "bio", Encode.string user.bio )
                ]
                |> Http.jsonBody
    in
        put url data (succeed True)
            |> Http.send Types.ViewProfile
