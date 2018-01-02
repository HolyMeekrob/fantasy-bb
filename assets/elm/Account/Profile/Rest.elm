module Account.Profile.Rest exposing (fetchUser)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Types exposing (userDecoder)
import Http


fetchUser : Cmd Msg
fetchUser =
    let
        url =
            "http://localhost:4000/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send Types.SetUser
