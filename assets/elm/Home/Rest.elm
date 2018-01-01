module Home.Rest exposing (fetchUser)

import Common exposing (userDecoder)
import Home.Types as Types exposing (Msg)
import Http


fetchUser : Cmd Msg
fetchUser =
    let
        url =
            "http://localhost:4000/ajax/account/user"
    in
        Http.get url userDecoder
            |> Http.send Types.SetUser
