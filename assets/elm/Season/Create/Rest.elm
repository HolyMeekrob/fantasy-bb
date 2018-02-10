module Season.Create.Rest exposing (fetchUser)

import Season.Create.Types as Types exposing (Model, Msg)
import Common.Types exposing (userDecoder)
import Http


fetchUser : Cmd Msg
fetchUser =
    let
        url =
            "/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send Types.SetUser
